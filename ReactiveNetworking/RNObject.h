//
//  RNObject.h
//  ReactiveNetworking
//
//  Created by Johannes Plunien on 14/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RNObject : MTLModel <MTLJSONSerializing>

// The unique ID for this object. This is only guaranteed to be unique among
// objects of the same type, from the same server.
//
// By default, the JSON representation for this property assumes a numeric
// representation (which is the case for most API objects). Subclasses may
// override the `+objectIDJSONTransformer` method to change this behavior.
@property (nonatomic, copy, readonly) NSString *objectID;

@end
