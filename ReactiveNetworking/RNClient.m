//
//  RNClient.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 23/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RNClient.h"
#import "RNParser.h"
#import "RNResponse.h"

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
                 return [[RNParser
                          parsedResponseOfClass:resultClass fromJSON:wantedObject]
                         map:^(id parsedResult) {
                             RNResponse *parsedResponse = [[self.responseClass alloc] initWithHTTPURLResponse:response parsedResult:parsedResult];
                             NSAssert(parsedResponse != nil, @"Could not create RNResponse with response %@ and parsedResult %@", response, parsedResult);

                             return parsedResponse;
                         }];
             }]
            concat];
}

@end
