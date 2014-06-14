//
//  RNResponse.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "RNResponse.h"
#import "EXTKeyPathCoding.h"

@interface RNResponse ()

@property (nonatomic, copy, readonly) NSHTTPURLResponse *HTTPURLResponse;

@end

@implementation RNResponse

- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult
{
	return [super initWithDictionary:@{
        @keypath(self.parsedResult): parsedResult ?: NSNull.null,
        @keypath(self.HTTPURLResponse): [response copy] ?: NSNull.null,
    } error:NULL];
}

@end
