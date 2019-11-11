//
//  EVDirectionClient.h
//  EVCompany
//
//  Created by GridScape on 12/3/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface EVDirectionClient : AFHTTPClient
+(EVDirectionClient *)sharedClient;

-(void)fetchDataFromServiceWithSource:(NSString *)source withDestination:(NSString *)destination Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
@end
