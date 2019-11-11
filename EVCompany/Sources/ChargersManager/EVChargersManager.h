//
//  EVChargersManager.h
//  EVCompany
//
//  Created by Zins on 11/14/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "EVCharger.h"
#include <CoreBluetooth/CoreBluetooth.h>

@interface EVChargersManager : NSObject

+ (id)shared;

- (void)addChargerWithPeripheral:(CBPeripheral *)peripheral andPort:(CBService *)port;
- (void)updateChargerValue:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic;
- (NSData *) dataFromHexString:(NSString*)hexString;


@end
