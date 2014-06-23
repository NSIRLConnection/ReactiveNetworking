//
//  RNClient.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 23/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveNetworking/RNClient.h>
#import <ReactiveNetworking/RNObject.h>
#import <ReactiveNetworking/RNResponse.h>

NSInteger const RNClientErrorJSONParsingFailed = 2000;

@interface RNClient ()

@property (nonatomic, strong, readonly) Class responseClass;

@end

@implementation RNClient

- (instancetype)initWithBaseURL:(NSURL *)url responseClass:(Class)responseClass
{
    self = [super initWithBaseURL:url];
    if (self) {
        NSParameterAssert([responseClass isSubclassOfClass:RNResponse.class]);
        _responseClass = responseClass;
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [self initWithBaseURL:url responseClass:RNResponse.class];
    return self;
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass keyPaths:(NSArray *)keyPaths
{
    return [[[self
              enqueueRequest:request]
             reduceEach:^(NSHTTPURLResponse *response, id responseObject) {
                 __block id wantedObject = responseObject;
                 [keyPaths enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL *stop) {
                     wantedObject = [wantedObject valueForKeyPath:keyPath];
                 }];
                 return [[self
                          parsedResponseOfClass:resultClass fromJSON:wantedObject]
                         map:^(id parsedResult) {
                             RNResponse *parsedResponse = [[self.responseClass alloc] initWithHTTPURLResponse:response parsedResult:parsedResult];
                             NSAssert(parsedResponse != nil, @"Could not create RNResponse with response %@ and parsedResult %@", response, parsedResult);

                             return parsedResponse;
                         }];
             }]
            concat];
}

#pragma mark - Parsing

- (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseObject
{
    NSParameterAssert(resultClass == nil || [resultClass isSubclassOfClass:MTLModel.class]);

    return [RACSignal createSignal:^ id (id<RACSubscriber> subscriber) {
        void (^parseJSONDictionary)(NSDictionary *) = ^(NSDictionary *JSONDictionary) {
            if (resultClass == nil) {
                [subscriber sendNext:JSONDictionary];
                return;
            }

            NSError *error = nil;
            RNObject *parsedObject = [MTLJSONAdapter modelOfClass:resultClass fromJSONDictionary:JSONDictionary error:&error];
            if (parsedObject == nil) {
                // Don't treat "no class found" errors as real parsing failures.
                // In theory, this makes parsing code forward-compatible with
                // API additions.
                if (![error.domain isEqual:MTLJSONAdapterErrorDomain] || error.code != MTLJSONAdapterErrorNoClassFound) {
                    [subscriber sendError:error];
                }

                return;
            }

            NSAssert([parsedObject isKindOfClass:RNObject.class], @"Parsed model object is not an RNObject: %@", parsedObject);

            [subscriber sendNext:parsedObject];
        };

        if ([responseObject isKindOfClass:NSArray.class]) {
            for (NSDictionary *JSONDictionary in responseObject) {
                if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
                    NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"Invalid JSON array element: %@", @""), JSONDictionary];
                    [subscriber sendError:[self parsingErrorWithFailureReason:failureReason]];
                    return nil;
                }

                parseJSONDictionary(JSONDictionary);
            }

            [subscriber sendCompleted];
        }
        else if ([responseObject isKindOfClass:NSDictionary.class]) {
            parseJSONDictionary(responseObject);
            [subscriber sendCompleted];
        }
        else if (responseObject != nil) {
            NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"Response wasn't an array or dictionary (%@): %@", @""), [responseObject class], responseObject];
            [subscriber sendError:[self parsingErrorWithFailureReason:failureReason]];
        }

        return nil;
    }];
}

- (NSError *)parsingErrorWithFailureReason:(NSString *)localizedFailureReason
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not parse the service response.", @"");

    if (localizedFailureReason != nil) {
        userInfo[NSLocalizedFailureReasonErrorKey] = localizedFailureReason;
    }

    return [NSError errorWithDomain:RNBaseClientErrorDomain code:RNClientErrorJSONParsingFailed userInfo:userInfo];
}

@end
