//
//  RNObject.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "RNObject.h"

@implementation RNObject

#pragma mark MTLModel

+ (NSUInteger)modelVersion
{
    return 1;
}

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{};
}

@end
