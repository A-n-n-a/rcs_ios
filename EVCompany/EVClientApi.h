//
//  INClientApi.h
//  Inspection
//
//  Created by mac on 8/30/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
@interface EVClientApi : AFHTTPClient
+(EVClientApi *)sharedClient;

- (void)fetchStationWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
- (void)fetchNearestStationWithParameters : (NSDictionary*)parameters Success : (void(^)(id ))succes Failure : (void(^)(NSError *))failure;

@end
