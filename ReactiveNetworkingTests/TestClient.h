//
//  TestClient.h
//  ReactiveNetworking
//
//  Created by Plunien, Johannes on 22/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <ReactiveNetworking/ReactiveNetworking.h>

@interface RNClient (Tests)

- (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseObject;
- (NSError *)parsingErrorWithFailureReason:(NSString *)localizedFailureReason;

@end

@interface TestClient : RNClient

@end
