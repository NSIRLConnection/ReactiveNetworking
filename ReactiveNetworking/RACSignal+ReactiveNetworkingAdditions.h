//
//  RACSignal+ReactiveNetworkingAdditions.h
//  ReactiveNetworking
//
//  Created by Plunien, Johannes on 29/06/14.
//  Copyright (c) 2014 Johannes Plunien. All rights reserved.
//

#import "RACSignal.h"

@interface RACSignal (ReactiveNetworkingAdditions)

- (RACSignal *)rn_parsedResults;

@end
