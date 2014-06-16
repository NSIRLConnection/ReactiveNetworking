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

+ (NSDictionary *)dictionaryValueFromArchivedExternalRepresentation:(NSDictionary *)externalRepresentation
                                                            version:(NSUInteger)fromVersion
{
    id objectID = externalRepresentation[@"id"];
    if (objectID == nil) return nil;

    return @{ @"objectID": objectID };
}

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"objectID": @"id"};
}

+ (NSValueTransformer *)objectIDJSONTransformer
{
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(NSNumber *num) {
                return num.stringValue;
            } reverseBlock:^ id (NSString *str) {
                if (str == nil) return nil;
                return [NSDecimalNumber decimalNumberWithString:str];
            }];
}

#pragma mark - Properties

- (BOOL)validateObjectID:(id *)objectID error:(NSError **)error
{
    if ([*objectID isKindOfClass:NSString.class]) {
        return YES;
    } else if ([*objectID isKindOfClass:NSNumber.class]) {
        *objectID = [*objectID stringValue];
        return YES;
    }

    return *objectID == nil;
}

@end
