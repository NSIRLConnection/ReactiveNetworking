//
//  ReadmeUser.h
//  ReactiveNetworking
//
//  Created by Plunien, Johannes on 22/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "ReactiveNetworking.h"

@interface ReadmeUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *objectID;
@property (nonatomic, copy, readonly) NSString *login;
@property (nonatomic, copy, readonly) NSString *name;

@end
