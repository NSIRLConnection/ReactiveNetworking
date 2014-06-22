//
//  ReadmeClient.h
//  ReactiveNetworking
//
//  Created by Plunien, Johannes on 22/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveNetworking/ReactiveNetworking.h>

@interface ReadmeClient : RNClient

- (RACSignal *)fetchUser:(NSString *)username;

@end
