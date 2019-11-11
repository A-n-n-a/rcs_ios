//
//  EVChargersManager.m
//  EVCompany
//
//  Created by Zins on 11/14/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVChargersManager.h"
#import "EVCharger.h"
#import "EVBLEConstants.h"
#import "EVBLEDataReader.h"
#import "NSData+AES128Encryption.h"
#import <CommonCrypto/CommonCryptor.h>
#import "EVBluetoothManager.h"

@implementation EVChargersManager {
    NSMutableArray<EVCharger *> *_chargers;
    BOOL tempIsFirstUpdate;
    NSData *key;
    NSData *iv;
    int c1;
    int c2;
    EVCharger *_charger1Copy;
    EVCharger *_charger2Copy;
}


+ (instancetype)shared
{
    static id shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        _chargers = [NSMutableArray<EVCharger *> new];
        tempIsFirstUpdate = YES;
        key = [self dataFromHexString:@"01BF7389965AD232832EC95F9B68CFAE"];
        Byte ivBytes[] = {0x55, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
        iv = [NSData dataWithBytes:ivBytes length:16];
        _charger1Copy = [[EVCharger alloc] init];
        _charger2Copy = [[EVCharger alloc] init];
        _charger1Copy.name = PORT1_NAME;
        _charger2Copy.name = PORT2_NAME;
    }
    return self;
}

- (void)addChargerWithPeripheral:(CBPeripheral *)peripheral andPort:(CBService *)port {
    NSString *peripheralId = [NSString stringWithFormat:@"%@",peripheral.identifier];
    NSString *portId = port.UUID.UUIDString;
    
    if (![self isChargerExistWith:peripheralId and:portId]) {
        [_chargers addObject:[[EVCharger alloc] initWithDeviceId:peripheralId andPortId:portId]];
    } else {
        
    }
}

- (void)updateChargerValue:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic {
    c1+=1;
    NSString *chargerId = [NSString stringWithFormat:@"%@", peripheral.identifier];
    NSString *portId = characteristic.service.UUID.UUIDString;
    NSString *characteristicId = characteristic.UUID.UUIDString;
    
    EVCharger *charger = [self getChargerWith:chargerId and:portId];
    
    EVCharger *chargerCopy = [[EVCharger alloc] init];
    chargerCopy = [charger.name hasPrefix: PORT1_NAME] ? _charger1Copy : _charger2Copy;

    if (charger != nil && characteristic.value != nil && ([characteristic.service.UUID.UUIDString isEqualToString:PORT1_SERVICE_UUID] ||
                                                          [characteristic.service.UUID.UUIDString isEqualToString:PORT2_SERVICE_UUID])) {
        
//        NSLog(@"%@, %@", characteristicId, characteristic.value);
        NSData *decryptedData = [characteristic.value AES128DecryptedDataWithKey:key iv:iv];
        if (characteristic.value == nil) {
            return;
        }
        
        if ([characteristicId isEqualToString:ISCHARGING_CHARACTERISTIC_UUID]) {
            charger.isCharging = [EVBLEDataReader readIsCharging:decryptedData];
        }
        else if ([characteristicId isEqualToString:KWH_CHARACTERISTIC_UUID]) {
            charger.kWH = [EVBLEDataReader readKWH:decryptedData];
        }
        else if ([characteristicId isEqualToString:AMPERAGE_CHARACTERISTIC_UUID]) {
            charger.amperage = [EVBLEDataReader readAmperage:decryptedData];
        }
        else if ([characteristicId isEqualToString:DURATION_CHARACTERISTIC_UUID]) {
            charger.duration = [EVBLEDataReader readDuration:decryptedData];
        }
        else if ([characteristicId isEqualToString:COST_CHARACTERISTIC_UUID]) {
            charger.cost = [EVBLEDataReader readCost:decryptedData];
            if (!tempIsFirstUpdate && charger.cost != chargerCopy.cost) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChargerStatusDidUpdated" object: charger];
            }
            chargerCopy.cost = charger.cost;
        }
        else if ([characteristicId isEqualToString:STARTDATE_CHARACTERISTIC_UUID]) {
            charger.startDate = [EVBLEDataReader readStartDate:decryptedData];
        }
        else if ([characteristicId isEqualToString:SCHEDULE_CHARACTERISTIC_UUID]) {
            NSLog(@"%@",  decryptedData);
            charger.schedule = [EVBLEDataReader readSchedule:decryptedData];
            if (!tempIsFirstUpdate && (charger.schedule.monday != chargerCopy.schedule.monday || charger.schedule.tuestay != chargerCopy.schedule.tuestay || charger.schedule.wednesday != chargerCopy.schedule.wednesday || charger.schedule.thursday != chargerCopy.schedule.thursday || charger.schedule.friday != chargerCopy.schedule.friday || charger.schedule.saturday != chargerCopy.schedule.saturday || charger.schedule.sunday != chargerCopy.schedule.sunday || charger.schedule.timeStart != chargerCopy.schedule.timeStart || charger.schedule.timeEnd != chargerCopy.schedule.timeEnd || charger.schedule.kWHLimitPerWeek != chargerCopy.schedule.kWHLimitPerWeek)) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChargerScheduleDidUpdated" object: charger];
            }
            chargerCopy.schedule = charger.schedule;
        }
        else if ([characteristicId isEqualToString:STATUS_CHARACTERISTIC_UUID]) {
            charger.status = [EVBLEDataReader readStatus:decryptedData];
            if (!tempIsFirstUpdate && charger.status != chargerCopy.status) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChargerProgressDidUpdated" object: charger];
            }
            chargerCopy.status = charger.status;
        }
        else if ([characteristicId isEqualToString:NAME_CHARACTERISTIC_UUID]) {
            NSLog(@"Read 9 char");
            charger.name = [EVBLEDataReader readName:decryptedData];
            charger.isUpdated = YES;
            if ([EVChargersManager isChargersUpdated:_chargers]) {
                if (tempIsFirstUpdate) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChargerInfoDidUpdated" object: [[NSArray alloc] initWithArray:_chargers copyItems:YES]];
                    tempIsFirstUpdate = NO;
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChargerNameDidUpdated" object: charger];

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChargersDidUpdated" object: [[NSArray alloc] initWithArray:_chargers copyItems:YES]];
                }
            }
        } else if ([characteristicId isEqualToString:STARTSTOP_CHARACTERISTIC_UUID]) {
            charger.startStopCharacteristic = characteristic;
        } else if ([characteristicId isEqualToString:REBOOT_CHARACTERISTIC_UUID]) {
            charger.rebootCharacteristic = characteristic;
            //TODO: write data after reboot only
            NSData *decryptedRebootData = [charger.rebootCharacteristic.value AES128DecryptedDataWithKey:key iv:iv];
            [[EVBluetoothManager shared] writeStructDataWithCharacteristic:charger.rebootCharacteristic WithData:decryptedRebootData];
            
            chargerCopy.rebootCharacteristic = charger.rebootCharacteristic;
        }
        else {
            NSLog(@"Error, characteristic id = %@, was not identified, skipping", characteristicId);
        }
        
    } else {
        NSLog(@"Error, no charger with id = %@, and port = %@ found!",chargerId, portId);
    }
}


- (BOOL)isChargerExistWith:(NSString *)chargerId and:(NSString *)portId {
    for (EVCharger *charger in _chargers) {
        if ([charger.periferalId isEqualToString:chargerId] && [charger.portId isEqualToString:portId]) {
            return YES;
        }
    }
    return NO;
}

- (EVCharger *)getChargerWith:(NSString *)chargerId and:(NSString *)portId {
    for (EVCharger *charger in _chargers) {
        if ([charger.periferalId isEqualToString:chargerId] && [charger.portId isEqualToString:portId]) {
            return charger;
        }
    }
    return nil;
}


+ (BOOL)isChargersUpdated:(NSArray<EVCharger *> *)chargers {
    for (EVCharger *charger in chargers) {
        if (!charger.isUpdated) {
            return NO;
        }
    }
    return YES;
}

- (NSData *) dataFromHexString:(NSString*)hexString {
    NSString * cleanString = hexString;
    if (cleanString == nil) {
        return nil;
    }
    
    NSMutableData *result = [[NSMutableData alloc] init];
    
    int i = 0;
    for (i = 0; i+2 <= cleanString.length; i+=2) {
        NSRange range = NSMakeRange(i, 2);
        NSString* hexStr = [cleanString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        unsigned char uc = (unsigned char) intValue;
        [result appendBytes:&uc length:1];
    }
    NSData * data = [NSData dataWithData:result];
    return data;
}

//- (BOOL)isChargerInfoChaged:(EVCharger *)charger {
//    EVCharger *oldCharger = []
//    if (char.isCharging != oldChager.isCharging || newCharger.kWH != oldChager.kWH ||
//        newCharger.amperage != oldChager.amperage || newCharger.duration != oldChager.duration ||
//        newCharger.cost != oldChager.cost) {
//        return YES;
//    }
//    return NO;
//}


@end
