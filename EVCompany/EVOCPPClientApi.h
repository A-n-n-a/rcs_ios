//
//  EVOCPPClientApi.h
//  EVCompany
//
//  Created by GridScape on 10/2/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "AFHTTPClient.h"

@interface EVOCPPClientApi : AFHTTPClient
+(EVOCPPClientApi *)sharedOcppClient;

- (void)addUserToOcppServerWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
- (void)getChargerDetailsWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
- (void)getConnectorWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
- (void)getReservationWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
- (void)getReservationListWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
- (void)getCancelReservationWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
- (void)RemoteChargingStartWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;
- (void)RemoteChargingStopWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure;


@end
