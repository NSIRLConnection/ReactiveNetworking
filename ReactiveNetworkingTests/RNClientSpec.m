//
//  RNClientSpec.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

@interface RNClient (Tests)

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

SpecEnd