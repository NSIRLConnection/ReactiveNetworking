//
//  RACSignal+ReactiveNetworkingAdditions.m
//  ReactiveNetworking
//
//  Created by Plunien, Johannes on 29/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "RACSignal+ReactiveNetworkingAdditions.h"
#import "RNResponse.h"

@implementation RACSignal (ReactiveNetworkingAdditions)

- (RACSignal *)rn_parsedResults
{
	return [self map:^(RNResponse *response) {
#if !NS_BLOCK_ASSERTIONS
        NSAssert([response isKindOfClass:RNResponse.class], @"Expected %@ to be an RNResponse.", response);
#endif
		return response.parsedResult;
	}];
}

@end
