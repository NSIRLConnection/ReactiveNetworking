//
//  RNBaseClient.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class RACSignal;

// The domain for all errors originating in RNBaseClient.
extern NSString * const RNBaseClientErrorDomain;

// A user info key associated with the NSURL of the request that failed.
extern NSString * const RNBaseClientErrorRequestURLKey;

// A user info key associated with an NSNumber, indicating the HTTP status code
// that was returned with the error.
extern NSString * const RNBaseClientErrorHTTPStatusCodeKey;

// There was a problem connecting to the server.
extern const NSInteger RNBaseClientErrorConnectionFailed;

// A request was made to an endpoint that requires authentication, and the user
// is not logged in.
extern const NSInteger RNBaseClientErrorAuthenticationFailed;

// The request was invalid (HTTP error 400).
extern const NSInteger RNBaseClientErrorBadRequest;

// The server is refusing to process the request because of an
// authentication-related issue (HTTP error 403).
//
// Often, this means that there have been too many failed attempts to
// authenticate. Even a successful authentication will not work while this error
// code is being returned. The only recourse is to stop trying and wait for
// a bit.
extern const NSInteger RNBaseClientErrorRequestForbidden;

// The server refused to process the request (HTTP error 422).
extern const NSInteger RNBaseClientErrorServiceRequestFailed;

@interface RNBaseClient : AFHTTPClient

// Subclasses should use this method to enqueue requests.
- (RACSignal *)enqueueRequest:(NSURLRequest *)request;

// Subclasses can override this method to customize error response parsing.
- (NSString *)errorMessageFromRequestOperation:(AFHTTPRequestOperation *)operation;
- (NSError *)errorFromRequestOperation:(AFHTTPRequestOperation *)operation;

@end
