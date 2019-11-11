//
//  EVBluetoothManager.h
//  EVCompany
//
//  Created by Anna on 10/13/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVCharger.h"

@import CoreBluetooth;

@protocol EVBluetoothManagerDelegate <NSObject>
@optional
- (void)connectingToCharger;
- (void)startSetupCharger;
- (void)finishSetupCharger;
- (void)startChargerInfoLoading;
- (void)chargerInfoLoaded;

@end

@interface EVBluetoothManager: NSObject  <CBCentralManagerDelegate, CBPeripheralDelegate>

typedef enum {
    ChargerConnected,
    ChargerNotConfigured,
    ChargerConfiguring,
    ChargerConfigured,
    ChargerConfiguredAndScan,
    
}ChargerState;

typedef enum {
    BleStateUnknown=0,
    BleStatePowerOn,
    BleStatePoweroff,
    BleStateIdle,
    BleStateScan,
    BleStateCancelConnect,
    BleStateNoDevice,
    BleStateWaitToConnect,
    BleStateConnecting,
    BleStateConnected,
    BleStateDisconnect,
    BleStateReConnect,
    BleStateConnecttimeout,
    BleStateReconnecttimeout,
    //BleStateShutdown,
}BleState;

@property (nonatomic, weak) id<EVBluetoothManagerDelegate> delegate;

@property (nonatomic, strong) CBCentralManager* centralManager;
@property (nonatomic, strong) CBPeripheral*     charger;
@property (nonatomic, strong) NSMutableArray*   chargersList;
@property (nonatomic, strong) NSMutableArray*   localNames;
@property(strong,nonatomic)void(^callBack)();

+ (id)shared;
- (void)scanBluetoothDevicesWithTimer:(int)time;
- (void)connectToPeripheral:(CBPeripheral*)peripheral;
- (void)cancelAllConnection;
- (void)rebootDevice:(EVCharger *)charger;
- (void)startCharging:(EVCharger *)charger withStartTime:(int)startTime;
- (void)stopCharging:(EVCharger *)charger withStopTime:(int)stopTime;;
- (void)writeStructDataWithCharacteristic:(CBCharacteristic *)characteristic WithData:(NSData *)data;

@end
