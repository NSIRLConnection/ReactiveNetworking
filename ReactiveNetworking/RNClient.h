//
//  RNClient.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

extern NSString * const RNClientErrorDomain;
extern NSInteger const RNClientErrorJSONParsingFailed;

@interface RNClient : AFHTTPClient

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass;

@end
