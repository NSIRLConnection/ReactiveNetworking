//
//  RNClient.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 23/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveNetworking/RNBaseClient.h>

@interface RNClient : RNBaseClient

// Inject a custom subclass of RNResponse as responseClass.
- (instancetype)initWithBaseURL:(NSURL *)url responseClass:(Class)responseClass;

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass keyPaths:(NSArray *)keyPaths;

@end
