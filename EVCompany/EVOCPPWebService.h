//
//  EVOCPPWebService.h
//  EVCompany
//
//  Created by GridScape on 10/5/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVOCPPWebService : NSObject
+(void)fetchDataFromService:(NSString *)serviceName withParameters:(id)parameters withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion;
//+(void)handleError:(NSError*)error;

@end