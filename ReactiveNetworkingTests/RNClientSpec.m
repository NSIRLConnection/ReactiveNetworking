//
//  RNClientSpec.m
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveNetworking/ReactiveNetworking.h>

@interface Response : RNResponse
@end
@implementation Response;
@end

@interface RNClient (Tests)

- (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseObject;
- (NSError *)parsingErrorWithFailureReason:(NSString *)localizedFailureReason;

@end

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

__block RNClient *client;

beforeEach(^{
    client = [[RNClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.github.com"]
                                 responseClass:Response.class];
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
    __block BOOL success;
    __block NSError *error;

    beforeEach(^{
        success = NO;
        error = nil;
    });

    it(@"should parse NSArray", ^{
        NSArray *array = [[NSArray alloc] init];
        [[client parsedResponseOfClass:nil fromJSON:array] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
    });

    it(@"should parse NSDictionary", ^{
        NSDictionary *dictionary = [[NSDictionary alloc] init];
        [[client parsedResponseOfClass:nil fromJSON:dictionary] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
    });

    it(@"should not parse NSObject", ^{
        NSObject *object = [[NSObject alloc] init];
        [[client parsedResponseOfClass:nil fromJSON:object] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beFalsy();
        expect(error).notTo.beNil();
    });

    it(@"should pass NSDictionary through", ^{
        NSDictionary *dictionary = @{@"foo": @"bar"};
        NSDictionary *result = [[client parsedResponseOfClass:nil fromJSON:dictionary] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(result).to.equal(dictionary);
    });

    it(@"should pass NSArray through", ^{
        NSMutableArray *result = [NSMutableArray array];
        NSArray *array = @[@{@"one": @"one"}, @{@"two": @"two"}];
        [[client parsedResponseOfClass:nil fromJSON:array] subscribeNext:^(id d) {
            [result addObject:d];
        }];
        expect(result).to.equal(array);
    });

    it(@"should require result class be a subclass of MTLModel", ^{
        expect(^{ [client parsedResponseOfClass:NSObject.class fromJSON:nil]; }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should return the parsed object", ^{
        NSDictionary *dictionary = @{@"id": @(42)};
        RNObject *result = [[client parsedResponseOfClass:RNObject.class fromJSON:dictionary] asynchronousFirstOrDefault:nil success:&success error:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(result.objectID).to.equal(@"42");
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
        Response *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];
        RNObject *object = response.parsedResult;

        expect(response).to.beKindOf(Response.class);
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(object.objectID).to.equal(@"1234");
    });

    it(@"should traverse the keypaths", ^{
        stubResponseWithHeaders(@"/keypaths", @"keypaths.json", @{});
        NSURLRequest *request = [client requestWithMethod:@"GET" path:@"keypaths" parameters:nil];
        RACSignal *result = [client enqueueRequest:request resultClass:RNObject.class keyPaths:@[@"{http://www.example.com/schema/thing/v1}things", @"value.thing"]];
        Response *response = [result asynchronousFirstOrDefault:nil success:&success error:&error];
        RNObject *object = response.parsedResult;

        expect(response).to.beKindOf(Response.class);
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(object.objectID).to.equal(@"5678");
    });
});

SpecEnd
