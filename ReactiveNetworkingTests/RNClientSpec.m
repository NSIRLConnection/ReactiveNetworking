//
//  RNClientSpec.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "TestClient.h"
#import "TestResponse.h"

SpecBegin(RNClient)

void (^stubResponseWithHeaders)(NSString *, NSString *, NSDictionary *) = ^(NSString *path, NSString *responseFilename, NSDictionary *headers) {
    headers = [headers mtl_dictionaryByAddingEntriesFromDictionary:@{@"Content-Type": @"application/json"}];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqual:path];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:responseFilename.stringByDeletingPathExtension withExtension:responseFilename.pathExtension];
        return [OHHTTPStubsResponse responseWithFileAtPath:fileURL.path statusCode:200 headers:headers];
    }];
};

__block TestClient *client;

beforeEach(^{
    [OHHTTPStubs removeAllStubs];
    client = [[TestClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.github.com"]
                                   responseClass:TestResponse.class];
    [client registerHTTPOperationClass:AFJSONRequestOperation.class];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    expect(client).notTo.beNil();
});

describe(@"initializer", ^{
    it(@"should throw an exception", ^{
        __block RNClient *customClient;
        expect(^{
            customClient = [[RNClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.github.com"]
                                               responseClass:nil];
        }).to.raise(NSInternalInconsistencyException);

        expect(^{
            customClient = [[RNClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.github.com"]
                                               responseClass:NSObject.class];
        }).to.raise(NSInternalInconsistencyException);

        expect(^{
            customClient = [[RNClient alloc] initWithBaseURL:nil
                                               responseClass:RNResponse.class];
        }).to.raise(NSInternalInconsistencyException);

        expect(customClient).to.beNil();
    });
});

describe(@"enqueueRequest", ^{
    __block BOOL success;
    __block NSError *error;

    beforeEach(^{
        success = NO;
        error = nil;
    });

    it(@"should return the object", ^{
        stubResponseWithHeaders(@"/object", @"object.json", @{});

        NSURLRequest *request = [client requestWithMethod:@"GET" path:@"object" parameters:nil];
        RACSignal *result = [client enqueueRequest:request resultClass:RNObject.class keyPaths:nil];
        TestResponse *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];
        RNObject *object = response.parsedResult;

        expect(response).to.beKindOf(TestResponse.class);
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(object).to.beKindOf(RNObject.class);
    });

    it(@"should traverse the keypaths", ^{
        stubResponseWithHeaders(@"/keypaths", @"keypaths.json", @{});
        NSURLRequest *request = [client requestWithMethod:@"GET" path:@"keypaths" parameters:nil];
        RACSignal *result = [client enqueueRequest:request resultClass:RNObject.class keyPaths:@[@"{http://www.example.com/schema/thing/v1}things", @"value.thing"]];
        TestResponse *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];
        RNObject *object = response.parsedResult;

        expect(response).to.beKindOf(TestResponse.class);
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(object).to.beKindOf(RNObject.class);
    });
});

describe(@"errorMessageFromRequestOperation", ^{
    __block BOOL success;
    __block NSError *error;

    beforeEach(^{
        success = NO;
        error = nil;
    });

    it(@"should parse the error message", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"error" withExtension:@"json"];
            return [OHHTTPStubsResponse responseWithFileAtPath:fileURL.path statusCode:401 headers:nil];
        }];

        NSURLRequest *request = [client requestWithMethod:@"GET" path:@"whatever" parameters:nil];
        RACSignal *result = [client enqueueRequest:request resultClass:RNObject.class keyPaths:nil];
        TestResponse *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];

        expect(response).to.beNil();
        expect(success).to.beFalsy();
        expect(error).notTo.beNil();

        expect(error.domain).to.equal(RNBaseClientErrorDomain);
        expect(error.code).to.equal(RNBaseClientErrorAuthenticationFailed);
        expect(error.localizedDescription).to.equal(@"The world is down.");
        expect(error.userInfo[RNBaseClientErrorHTTPStatusCodeKey]).to.equal(401);
        expect(error.userInfo[RNBaseClientErrorRequestURLKey]).to.equal([NSURL URLWithString:@"https://api.github.com/whatever"]);
        expect(error.userInfo[NSUnderlyingErrorKey]).notTo.beNil();
    });
});

SpecEnd
