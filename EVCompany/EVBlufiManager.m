//
//  EVBlufiManager.m
//  EVCompany
//
//  Created by Anna on 11/10/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>



//    baby = [BabyBluetooth shareBabyBluetooth];
//
//    [self BleDelegate];
//
//    self.blestate=BleStateIdle;
//
//    baby.scanForPeripherals().begin().stop(SCANTIME);

//-(void)BleDelegate
//{
//    //__weak typeof(baby) weakbaby = baby;
//    __weak typeof(self) weakself =self;
//    
//    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
//        
//        if (central.state==CBCentralManagerStatePoweredOn) {
//            
//            weakself.blestate=BleStatePowerOn;
//            
//            //NSString *UUIDStr=[[NSUserDefaults standardUserDefaults] objectForKey:ConnectedDeviceKey];
//        }
//        if(central.state==CBCentralManagerStateUnsupported)
//        {
//            weakself.blestate=BleStateUnknown;
//        }
//        if (central.state==CBCentralManagerStatePoweredOff) {
//            weakself.blestate=BleStatePoweroff;
//            [weakself updateInterface];
//        }
//    }];
//    
//    //SCANNING
//    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
//        NSLog(@"Peripheral.name,AdvertisementData:%@,%@",peripheral.name,advertisementData);
//        NSString *name=[NSString stringWithFormat:@"%@",peripheral.name];
//        NSMutableArray * chList = [[NSMutableArray alloc] init];
//        [chList addObject:peripheral];
//        _list = chList;
//        [weakself updateInterface];
//    }];
//    
//    //START SCANNING
//    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI)
//     {
//         if ([peripheralName hasPrefix:filterBLEname]) {
//             return YES;
//         }
//         return NO;
//     }];
//    
//    //Detect devices with "BLUFI" prefix only
//    [baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
//        if ([peripheralName hasPrefix:filterBLEname]) {
//            weakself.blestate=BleStateConnecting;
//            return YES;
//        }
//        return NO;
//    }];
//    
//    //WHEN TAP CONNECT
//    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
//#ifdef DEBUG
//        NSLog(@"%@",peripheral.name);
//#endif
//    }];
//    
//    //Connect failed
//    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//#ifdef DEBUG
//        NSLog(@"CONNECT FAILED: %@",peripheral.name);
//#endif
//    }];
//    
//    //  SERVICES
//    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
//#ifdef DEBUG
//        for (CBService *service in peripheral.services) {
//            NSLog(@"SERVICES: %@", service);
//        }
//#endif
//    }];
//    
//    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
//#ifdef DEBUG
//        NSLog(@"RSSI: %@", RSSI);
//#endif
//    }];
//    
//    //Characteristics
//    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
//#ifdef DEBUG
//        NSLog(@"===service name:%@",service.UUID);
//        for (CBCharacteristic *characteristic in service.characteristics) {
//            NSLog(@"CHARACTERISTIC: %@", characteristic);
//        }
//#endif
//    }];
//    
//    //Characteristic value
//    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//#ifdef DEBUG
//        NSLog(@"CHARACTERISTIC VALUE:%@", characteristic.value);
//#endif
//    }];
//    
//    //Characteristics descriptors
//    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//#ifdef DEBUG
//        NSLog(@"CHARACTERISTIC DESCRIPTOR:%@", characteristic.descriptors);
//#endif
//    }];
//    
//    //Descriptor
//    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
//#ifdef DEBUG
//        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
//#endif
//    }];
//    
//    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//        if (error) {
//            NSLog(@"Error %@",error);
//        }
//    }];
//    
//    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
//#ifdef DEBUG
//        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
//#endif
//    }];
//    
//    //CANCEL SCANNING
//    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
//#ifdef DEBUG
//        NSLog(@"CANCEL SCANNING");
//#endif
//    }];
//    
//    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
//    
//    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
//                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
//                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
//    
//    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
//}

