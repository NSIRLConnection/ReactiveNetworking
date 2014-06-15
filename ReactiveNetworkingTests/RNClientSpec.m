//
//  RNClientSpec.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveNetworking/RNObject.h>

@interface RNClient (Tests)

- (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseObject;
- (NSError *)parsingErrorWithFailureReason:(NSString *)localizedFailureReason;

@end

SpecBegin(RNClient)

__block RNClient *client;

beforeEach(^{
    client = [[RNClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.github.com"]];
    expect(client).notTo.beNil();
});

describe(@"parsingErrorWithFailureReason", ^{
    it(@"should return an error object", ^{
        NSError *error = [client parsingErrorWithFailureReason:@"World down."];
        expect(error).notTo.beNil();
        expect(error.domain).to.equal(RNClientErrorDomain);
        expect(error.code).to.equal(RNClientErrorJSONParsingFailed);
        expect(error.userInfo[NSLocalizedDescriptionKey]).notTo.beNil();
        expect(error.userInfo[NSLocalizedFailureReasonErrorKey]).to.equal(@"World down.");
    });
});

describe(@"parsedResponseOfClass", ^{
    it(@"should only parse NSArray and NSDictionary", ^{
        __block NSError *objectError;
        NSObject *object = [[NSObject alloc] init];
        [[client parsedResponseOfClass:nil fromJSON:object] subscribeError:^(NSError *e) { objectError = e; }];
        expect(objectError).willNot.beNil();

        __block NSError *dictionaryError;
        NSDictionary *dictionary = [[NSDictionary alloc] init];
        [[client parsedResponseOfClass:nil fromJSON:dictionary] subscribeError:^(NSError *e) { dictionaryError = e; }];
        expect(dictionaryError).will.beNil();

        __block NSError *arrayError;
        NSArray *array = [[NSArray alloc] init];
        [[client parsedResponseOfClass:nil fromJSON:array] subscribeError:^(NSError *e) { arrayError = e; }];
        expect(arrayError).will.beNil();
    });

    it(@"should let NSDictionary just fall through without a result class", ^{
        __block id result;
        NSDictionary *dictionary = @{@"foo": @"bar"};
        [[client parsedResponseOfClass:nil fromJSON:dictionary] subscribeNext:^(id d) {
            result = d;
        }];
        expect(result).will.beKindOf(NSDictionary.class);
        expect(result).will.equal(dictionary);
    });

    it(@"should let NSArray just fall through without a result class", ^{
        NSMutableArray *result = [NSMutableArray array];
        NSArray *array = @[@{@"one": @"one"}, @{@"two": @"two"}];
        [[client parsedResponseOfClass:nil fromJSON:array] subscribeNext:^(id d) {
            [result addObject:d];
        }];
        expect(result).will.equal(array);
    });

    it(@"should require result class be a subclass of MTLModel", ^{
        expect(^{ [client parsedResponseOfClass:NSObject.class fromJSON:nil]; }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should return the parsed object", ^{
        __block id result;
        NSDictionary *dictionary = @{@"id": @(42)};
        [[client parsedResponseOfClass:RNObject.class fromJSON:dictionary] subscribeNext:^(id d) {
            result = d;
        }];
        RNObject *model = (RNObject *)result;
        expect(result).will.beKindOf(RNObject.class);
        expect(model.objectID).will.equal(@"42");
    });
});

SpecEnd