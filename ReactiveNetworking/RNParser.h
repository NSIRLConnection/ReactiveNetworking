//
//  RNParser.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 23/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <Foundation/Foundation.h>

// The domain for all errors originating in RNParser.
extern NSString * const RNParserErrorDomain;

// JSON parsing failed, or a model object could not be created from the parsed JSON.
extern NSInteger const RNParserErrorJSONParsingFailed;

@class RACSignal;

@interface RNParser : NSObject

+ (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseObject;

@end
