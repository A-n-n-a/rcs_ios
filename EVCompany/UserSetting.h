//
//  UserSetting.h
//  EVCompany
//
//  Created by GridScape on 11/5/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UserSetting : NSManagedObject

@property (nonatomic, retain) NSString * notifyBeforeTime;
@property (nonatomic, retain) NSString * notifyBeforeDistance;
@property (nonatomic, retain) NSString * searchNearbyDistance;
@property (nonatomic, retain) NSString * notificationStr;

@end
