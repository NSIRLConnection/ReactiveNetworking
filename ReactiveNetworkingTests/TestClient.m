//
//  TestClient.m
//  ReactiveNetworking
//
//  Created by Plunien, Johannes on 22/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "TestClient.h"

@implementation TestClient

+ (NSString *)errorMessageFromRequestOperation:(AFHTTPRequestOperation *)operation resultClass:(Class)resultClass
{
    NSParameterAssert(operation != nil);
    NSDictionary *responseDictionary = nil;
    if ([operation isKindOfClass:AFJSONRequestOperation.class]) {
        id JSON = [(AFJSONRequestOperation *)operation responseJSON];
        if ([JSON isKindOfClass:NSDictionary.class]) {
            responseDictionary = JSON;
        }
    }
    return [responseDictionary valueForKey:@"message"];
}

@end
