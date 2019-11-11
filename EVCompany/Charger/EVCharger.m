//
//  EVCharger.m
//  EVCompany
//
//  Created by Zins on 11/13/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVCharger.h"

@implementation EVCharger

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithDeviceId:(NSString *)deviceId andPortId:(NSString *)portId {
    if (self = [self init]) {
        _periferalId = deviceId;
        _portId = portId;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    EVCharger *charger = [[[self class] allocWithZone:zone] init];
    charger->_periferalId = [self.periferalId copyWithZone:zone];
    charger->_portId = [self.portId copyWithZone:zone];
    charger.startStopCharacteristic = self.startStopCharacteristic;
    charger.rebootCharacteristic = self.rebootCharacteristic;
    charger.isUpdated = self.isUpdated;
    charger.isCharging = self.isCharging;
    charger.kWH = self.kWH;
    charger.amperage = self.amperage;
    charger.duration = self.duration;
    charger.cost = self.cost;
    charger->_startDate = [self.startDate copyWithZone:zone];
    charger->_schedule = [self.schedule copyWithZone:zone];
    charger.status = self.status;
    charger->_name = [self.name copyWithZone:zone];
    
    return charger;
}

@end
