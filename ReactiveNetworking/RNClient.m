//
//  RNClient.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RNClient.h"
#import "RNObject.h"
#import "RNResponse.h"

NSString * const RNClientErrorDomain = @"RNClientErrorDomain";
NSString * const RNClientErrorRequestStateRedirected = @"RNClientErrorRequestStateRedirected";
NSString * const RNClientErrorRequestURLKey = @"RNClientErrorRequestURLKey";
NSString * const RNClientErrorHTTPStatusCodeKey = @"RNClientErrorHTTPStatusCodeKey";

NSInteger const RNClientNotModifiedStatusCode = 304;

NSInteger const RNClientErrorJSONParsingFailed = 1000;
NSInteger const RNClientErrorConnectionFailed = 1001;
NSInteger const RNClientErrorAuthenticationFailed = 1002;
NSInteger const RNClientErrorBadRequest = 1003;
NSInteger const RNClientErrorRequestForbidden = 1004;
NSInteger const RNClientErrorServiceRequestFailed = 1005;
NSInteger const RNClientErrorUnsupportedServerScheme = 1006;

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
    NSURLRequest *originalRequest = [request copy];
    RACSignal *signal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (operation.response.statusCode == RNClientNotModifiedStatusCode) {
                // No change in the data.
                [subscriber sendCompleted];
                return;
            }

            [[RACSignal
               return:RACTuplePack(operation.response, responseObject)]
             subscribe:subscriber];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:[self.class errorFromRequestOperation:operation resultClass:(Class)resultClass]];
        }];

        operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        operation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        [self enqueueHTTPRequestOperation:operation];

        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];

    return [[[[signal replayLazily] setNameWithFormat:@"-enqueueRequest: %@", request]
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

    return [NSError errorWithDomain:RNClientErrorDomain code:RNClientErrorJSONParsingFailed userInfo:userInfo];
}

#pragma mark - Error handling

+ (NSString *)errorMessageFromRequestOperation:(AFHTTPRequestOperation *)operation resultClass:(Class)resultClass
{
    NSParameterAssert(operation != nil);
    return operation.error.localizedDescription;
}

+ (NSError *)errorFromRequestOperation:(AFHTTPRequestOperation *)operation resultClass:(Class)resultClass
{
    NSParameterAssert(operation != nil);

    NSInteger HTTPCode = operation.response.statusCode;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSInteger errorCode = RNClientErrorConnectionFailed;

    userInfo[NSLocalizedDescriptionKey] = [self errorMessageFromRequestOperation:operation resultClass:(Class)resultClass];

    switch (HTTPCode) {
        case 401:
            errorCode = RNClientErrorAuthenticationFailed;
            break;

        case 400:
            errorCode = RNClientErrorBadRequest;
            break;

        case 403:
            errorCode = RNClientErrorRequestForbidden;
            break;

        case 422:
            errorCode = RNClientErrorServiceRequestFailed;
            break;
    }

    if (operation.userInfo[RNClientErrorRequestStateRedirected] != nil) {
        errorCode = RNClientErrorUnsupportedServerScheme;
    }

    userInfo[RNClientErrorHTTPStatusCodeKey] = @(HTTPCode);
    if (operation.request.URL != nil) userInfo[RNClientErrorRequestURLKey] = operation.request.URL;
    if (operation.error != nil) userInfo[NSUnderlyingErrorKey] = operation.error;

    return [NSError errorWithDomain:RNClientErrorDomain code:errorCode userInfo:userInfo];
}

@end
