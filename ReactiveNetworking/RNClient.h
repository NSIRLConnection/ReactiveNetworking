//
//  RNClient.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class RACSignal;

// The domain for all errors originating in RNClient.
extern NSString * const RNClientErrorDomain;

// A user info key associated with the NSURL of the request that failed.
extern NSString * const RNClientErrorRequestURLKey;

// A user info key associated with an NSNumber, indicating the HTTP status code
// that was returned with the error.
extern NSString * const RNClientErrorHTTPStatusCodeKey;

// JSON parsing failed, or a model object could not be created from the parsed JSON.
extern NSInteger const RNClientErrorJSONParsingFailed;

// There was a problem connecting to the server.
extern const NSInteger RNClientErrorConnectionFailed;

// A request was made to an endpoint that requires authentication, and the user
// is not logged in.
extern const NSInteger RNClientErrorAuthenticationFailed;

// The request was invalid (HTTP error 400).
extern const NSInteger RNClientErrorBadRequest;

// The server is refusing to process the request because of an
// authentication-related issue (HTTP error 403).
//
// Often, this means that there have been too many failed attempts to
// authenticate. Even a successful authentication will not work while this error
// code is being returned. The only recourse is to stop trying and wait for
// a bit.
extern const NSInteger RNClientErrorRequestForbidden;

// The server refused to process the request (HTTP error 422).
extern const NSInteger RNClientErrorServiceRequestFailed;

// The server scheme is unsupported.
extern const NSInteger RNClientErrorUnsupportedServerScheme;

@interface RNClient : AFHTTPClient

- (instancetype)initWithBaseURL:(NSURL *)url responseClass:(Class)responseClass;
- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass keyPaths:(NSArray *)keyPaths;

@end
