//
//  EVWebService.h
//  EVCompany
//
//  Created by Srishti on 11/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVWebService : NSObject
+(void)fetchDataFromService:(NSString *)serviceName withParameters:(id)parameters withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion;
//+(void)handleError:(NSError*)error;

@end
