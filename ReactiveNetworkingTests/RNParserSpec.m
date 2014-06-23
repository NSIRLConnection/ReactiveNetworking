//
//  RNParserSpec.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 23/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveNetworking/ReactiveNetworking.h>
#import <ReactiveNetworking/RNParser.h>

SpecBegin(RNParser)

describe(@"parsedResponseOfClass", ^{
    __block BOOL success;
    __block NSError *error;

    beforeEach(^{
        success = NO;
        error = nil;
    });

    it(@"should parse NSArray", ^{
        NSArray *array = [[NSArray alloc] init];
        [[RNParser parsedResponseOfClass:nil fromJSON:array] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
    });

    it(@"should parse NSDictionary", ^{
        NSDictionary *dictionary = [[NSDictionary alloc] init];
        [[RNParser parsedResponseOfClass:nil fromJSON:dictionary] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
    });

    it(@"should not parse NSObject", ^{
        NSObject *object = [[NSObject alloc] init];
        [[RNParser parsedResponseOfClass:nil fromJSON:object] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beFalsy();
        expect(error).notTo.beNil();
        expect(error.domain).to.equal(RNParserErrorDomain);
        expect(error.code).to.equal(RNParserErrorJSONParsingFailed);
        expect(error.userInfo[NSLocalizedDescriptionKey]).notTo.beNil();
    });

    it(@"should pass NSDictionary through", ^{
        NSDictionary *dictionary = @{@"foo": @"bar"};
        NSDictionary *result = [[RNParser parsedResponseOfClass:nil fromJSON:dictionary] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(result).to.equal(dictionary);
    });

    it(@"should pass NSArray through", ^{
        NSMutableArray *result = [NSMutableArray array];
        NSArray *array = @[@{@"one": @"one"}, @{@"two": @"two"}];
        [[RNParser parsedResponseOfClass:nil fromJSON:array] subscribeNext:^(id d) {
            [result addObject:d];
        }];
        expect(result).to.equal(array);
    });

    it(@"should require result class be a subclass of MTLModel", ^{
        expect(^{ [RNParser parsedResponseOfClass:NSObject.class fromJSON:nil]; }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should return the parsed object", ^{
        NSDictionary *dictionary = @{@"id": @(42)};
        RNObject *result = [[RNParser parsedResponseOfClass:RNObject.class fromJSON:dictionary] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(result.objectID).to.equal(@"42");
    });
});

SpecEnd