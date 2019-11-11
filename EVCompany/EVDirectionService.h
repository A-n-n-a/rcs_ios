//
//  EVDirectionService.h
//  EVCompany
//
//  Created by GridScape on 12/3/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVDirectionService : NSObject
+(void)fetchDataFromServiceWithSource:(NSString *)source withDestination:(NSString *)destination withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion;
//+(void)fetchDataFromService:(NSString *)service withParameters:(id)parameters withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion;
@end
