//
//  RNClient.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RNClient.h"
#import "RNObject.h"
#import "RNResponse.h"

NSString * const RNClientErrorDomain = @"RNClientErrorDomain";
NSInteger const RNClientErrorJSONParsingFailed = 1000;

@implementation RNClient

#pragma mark - Parsing

- (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseObject
{
	NSParameterAssert(resultClass == nil || [resultClass isSubclassOfClass:MTLModel.class]);

	return [RACSignal createSignal:^ id (id<RACSubscriber> subscriber) {
		void (^parseJSONDictionary)(NSDictionary *) = ^(NSDictionary *JSONDictionary) {
			if (resultClass == nil) {
				[subscriber sendNext:JSONDictionary];
				return;
			}

			NSError *error = nil;
			RNObject *parsedObject = [MTLJSONAdapter modelOfClass:resultClass fromJSONDictionary:JSONDictionary error:&error];
			if (parsedObject == nil) {
				// Don't treat "no class found" errors as real parsing failures.
				// In theory, this makes parsing code forward-compatible with
				// API additions.
				if (![error.domain isEqual:MTLJSONAdapterErrorDomain] || error.code != MTLJSONAdapterErrorNoClassFound) {
					[subscriber sendError:error];
				}

				return;
			}

			NSAssert([parsedObject isKindOfClass:RNObject.class], @"Parsed model object is not an RNObject: %@", parsedObject);

			[subscriber sendNext:parsedObject];
		};

		if ([responseObject isKindOfClass:NSArray.class]) {
			for (NSDictionary *JSONDictionary in responseObject) {
				if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
					NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"Invalid JSON array element: %@", @""), JSONDictionary];
					[subscriber sendError:[self parsingErrorWithFailureReason:failureReason]];
					return nil;
				}

				parseJSONDictionary(JSONDictionary);
			}

			[subscriber sendCompleted];
		}
        else if ([responseObject isKindOfClass:NSDictionary.class]) {
			parseJSONDictionary(responseObject);
			[subscriber sendCompleted];
		}
        else if (responseObject != nil) {
			NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"Response wasn't an array or dictionary (%@): %@", @""), [responseObject class], responseObject];
			[subscriber sendError:[self parsingErrorWithFailureReason:failureReason]];
		}

		return nil;
	}];
}

- (NSError *)parsingErrorWithFailureReason:(NSString *)localizedFailureReason
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not parse the service response.", @"");

	if (localizedFailureReason != nil) {
		userInfo[NSLocalizedFailureReasonErrorKey] = localizedFailureReason;
	}

	return [NSError errorWithDomain:RNClientErrorDomain code:RNClientErrorJSONParsingFailed userInfo:userInfo];
}

@end
