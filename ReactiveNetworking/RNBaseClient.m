//
//  RNBaseClient.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveNetworking/RNBaseClient.h>

NSString * const RNBaseClientErrorDomain = @"RNClientErrorDomain";
NSString * const RNBaseClientErrorRequestURLKey = @"RNClientErrorRequestURLKey";
NSString * const RNBaseClientErrorHTTPStatusCodeKey = @"RNClientErrorHTTPStatusCodeKey";

NSInteger const RNBaseClientNotModifiedStatusCode = 304;

NSInteger const RNBaseClientErrorConnectionFailed = 1001;
NSInteger const RNBaseClientErrorAuthenticationFailed = 1002;
NSInteger const RNBaseClientErrorBadRequest = 1003;
NSInteger const RNBaseClientErrorRequestForbidden = 1004;
NSInteger const RNBaseClientErrorServiceRequestFailed = 1005;

@implementation RNBaseClient

- (RACSignal *)enqueueRequest:(NSURLRequest *)request
{
    NSURLRequest *originalRequest = [request copy];
    RACSignal *signal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (operation.response.statusCode == RNBaseClientNotModifiedStatusCode) {
                // No change in the data.
                [subscriber sendCompleted];
                return;
            }

            [[RACSignal
               return:RACTuplePack(operation.response, responseObject)]
             subscribe:subscriber];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:[self.class errorFromRequestOperation:operation]];
        }];

        operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        operation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        [self enqueueHTTPRequestOperation:operation];

        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];

    return [[signal
             replayLazily]
            setNameWithFormat:@"-enqueueRequest: %@", request];
}

#pragma mark - Error handling

+ (NSString *)errorMessageFromRequestOperation:(AFHTTPRequestOperation *)operation
{
    NSParameterAssert(operation != nil);
    return operation.error.localizedDescription;
}

+ (NSError *)errorFromRequestOperation:(AFHTTPRequestOperation *)operation
{
    NSParameterAssert(operation != nil);

    NSInteger HTTPCode = operation.response.statusCode;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSInteger errorCode = RNBaseClientErrorConnectionFailed;

    userInfo[NSLocalizedDescriptionKey] = [self errorMessageFromRequestOperation:operation];

    switch (HTTPCode) {
        case 401:
            errorCode = RNBaseClientErrorAuthenticationFailed;
            break;

        case 400:
            errorCode = RNBaseClientErrorBadRequest;
            break;

        case 403:
            errorCode = RNBaseClientErrorRequestForbidden;
            break;

        case 422:
            errorCode = RNBaseClientErrorServiceRequestFailed;
            break;
    }

    userInfo[RNBaseClientErrorHTTPStatusCodeKey] = @(HTTPCode);
    if (operation.request.URL != nil) userInfo[RNBaseClientErrorRequestURLKey] = operation.request.URL;
    if (operation.error != nil) userInfo[NSUnderlyingErrorKey] = operation.error;

    return [NSError errorWithDomain:RNBaseClientErrorDomain code:errorCode userInfo:userInfo];
}

@end
