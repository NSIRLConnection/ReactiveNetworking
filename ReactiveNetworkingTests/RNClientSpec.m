//
//  RNClientSpec.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

SpecBegin(RNClient)

it(@"should work", ^{
    RNClient *client = [[RNClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.github.com"]];
    expect(client).to.beKindOf(RNClient.class);
});

SpecEnd