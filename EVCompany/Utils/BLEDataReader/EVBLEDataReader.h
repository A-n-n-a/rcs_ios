//
//  EVBLEDataReader.h
//  EVCompany
//
//  Created by Zins on 11/10/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "EVSchedule.h"

@interface EVBLEDataReader : NSObject

+ (BOOL)readIsCharging:(NSData *)data;
+ (float)readKWH:(NSData *)data;
+ (float)readAmperage:(NSData *)data;
+ (uint32_t)readDuration:(NSData *)data;
+ (float)readCost:(NSData *)data;
+ (NSDate *)readStartDate:(NSData *)data;
+ (int)readStatus:(NSData *)data;
+ (EVSchedule *)readSchedule:(NSData *)data;
+ (NSString *)readName:(NSData *)data;
+ (BOOL)readStartStop:(NSData *)data;

@end
