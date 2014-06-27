//
//  ReadmeUser.m
//  ReactiveNetworking
//
//  Created by Plunien, Johannes on 22/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "ReadmeUser.h"

@implementation ReadmeUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"objectID": @"id",
             @"login": @"login_name",
             @"name": @"display_name"};
}

@end
