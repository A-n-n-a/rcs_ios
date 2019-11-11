//
//  EVCharger.h
//  EVCompany
//
//  Created by Zins on 11/13/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "EVSchedule.h"

@interface EVCharger : NSObject <NSCopying>

@property (nonatomic, strong) NSString *periferalId;
@property (nonatomic, strong) NSString *portId;
@property (nonatomic, assign) BOOL isUpdated;
@property (nonatomic, strong) CBCharacteristic *startStopCharacteristic;
@property (nonatomic, strong) CBCharacteristic *rebootCharacteristic;

@property (nonatomic, assign) BOOL isCharging;
@property (nonatomic, assign) float kWH;
@property (nonatomic, assign) float amperage;
@property (nonatomic, assign) uint32_t duration;
@property (nonatomic, assign) float cost;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) EVSchedule *schedule;
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSString *name;

- (instancetype)initWithDeviceId:(NSString *)deviceId andPortId:(NSString *)portId;

@end
