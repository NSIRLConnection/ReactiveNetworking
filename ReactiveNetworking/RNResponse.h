//
//  RNResponse.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RNResponse : MTLModel

// The parsed MTLModel object corresponding to the API response.
@property (nonatomic, strong, readonly) id parsedResult;

// Initializes the receiver with the headers from the given response, and the
// given parsed model object(s).
- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult;

@end
