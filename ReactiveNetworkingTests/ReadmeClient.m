//
//  ReadmeClient.m
//  ReactiveNetworking
//
//  Created by Plunien, Johannes on 22/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "ReadmeClient.h"
#import "ReadmeUser.h"

@implementation ReadmeClient

- (instancetype)initWithBaseURL:(NSURL *)url
{
    if (url == nil) url = [NSURL URLWithString:@"https://api.example.com"];
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:AFJSONRequestOperation.class];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    return self;
}

- (RACSignal *)fetchUser:(NSString *)username
{
    NSString *path = [NSString stringWithFormat:@"/users/%@", username];
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
	return [self enqueueRequest:request
                    resultClass:ReadmeUser.class
                       keyPaths:@[@"user"]];
}

@end
