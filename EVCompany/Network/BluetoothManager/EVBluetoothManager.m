//
//  EVBluetoothManager.m
//  EVCompany
//
//  Created by Anna on 10/13/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVBluetoothManager.h"
#import "ConstantStrings.h"
#import "EVBLEConstants.h"
#import "EVChargersManager.h"
#import "EVCharger.h"
#import "EVBLEDataReader.h"

#import "BabyBluetooth.h"
#import "PacketCommand.h"
#import "RSAObject.h"
#import "DH_AES.h"
#import "EVBLEDevice.h"
#import "NSData+AES128Encryption.h"


#define AutoConnect  0

@interface EVBluetoothManager () {
    
    BOOL isConnectionSuccess;
    NSTimer *_scanTimer;
    NSMutableArray<EVCharger *> *_chargers;
    CBPeripheral *_connectedPeripheral;
    BOOL _isDataSent;
    BOOL _needToUpdateData;
    
    //temp
    BabyBluetooth *_baby;
    RSAObject *_rsaobject;
    NSData *_senddata;
    CBCharacteristic *_writeCharacteristic;
    NSData *_securtkey;
    uint8_t _sequence;
    NSData *key;
    NSData *iv;
}

@property(nonatomic,strong) NSTimer *configureTimer;
@property(nonatomic,assign) BleState blestate;
@property(nonatomic,assign) ChargerState chagerState;
@property(nonatomic,strong) NSMutableArray *bLEDeviceArray;
@property(nonatomic,strong) EVBLEDevice *currentDevice;
@property(nonatomic,strong) NSTimer *_connectTimeoutTimer;
@property(nonatomic,assign) BOOL aPPCancelConnect;
@property(nonatomic,strong) NSMutableArray<EVBLEDevice *> *devices;

@end

@implementation EVBluetoothManager

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
        _rsaobject = [DH_AES DHGenerateKey];
        _blestate = BleStateIdle;
        _baby = [BabyBluetooth shareBabyBluetooth];
        [self cancelAllConnection];
        _currentDevice = [EVBLEDevice new];
        _bLEDeviceArray = [NSMutableArray new];
        _devices = [NSMutableArray new];
        _needToUpdateData = YES;
        [self BleDelegate];
        key = [[EVChargersManager shared] dataFromHexString:@"01BF7389965AD232832EC95F9B68CFAE"];
        Byte ivBytes[] = {0x55, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
        iv = [NSData dataWithBytes:ivBytes length:16];
    }
    return self;
}

-(void)BleDelegate
{
    __weak typeof(_baby) weakbaby = _baby;
    __weak typeof(self) weakself = self;

    [_baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state==CBCentralManagerStatePoweredOn) {
            weakself.blestate=BleStatePowerOn;
            weakbaby.scanForPeripherals().begin().stop(20);
        }
        if(central.state==CBCentralManagerStateUnsupported) {
            weakself.blestate=BleStateUnknown;
        }
        if (central.state==CBCentralManagerStatePoweredOff) {
            weakself.blestate=BleStatePoweroff;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showBluetoothTurnOffAlert" object:nil];
        }
    }];
    
    [_baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {

        NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
        if ([weakself addPeripheralToArray:peripheral]) {
#ifdef DEBUG
            NSLog(@"Found charger: %@, Charger UUID: %@", localName, peripheral.identifier);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateInterface" object: weakself.devices];
        }
        
        NSString *name=[NSString stringWithFormat:@"%@",peripheral.name];
        if (![EVBluetoothManager isAleadyExist:name BLEDeviceArray:weakself.bLEDeviceArray])
        {
            EVBLEDevice *device=[[EVBLEDevice alloc] init];
            device.name=name;
            device.peripheral=peripheral;
            [weakself.bLEDeviceArray addObject: device];
        }
    }];
    
    [_baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        if ([peripheralName hasPrefix:NOT_CONFIGURED_DEVICE_PREFIX] || [peripheralName hasPrefix:CONFIGURED_DEVICE_PREFIX]) {
            weakself.blestate=BleStateConnecting;
            return YES;
        }
        return NO;
    }];
    
    [_baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI)
     {
         if ([peripheralName hasPrefix:NOT_CONFIGURED_DEVICE_PREFIX] || [peripheralName hasPrefix:CONFIGURED_DEVICE_PREFIX]) {
             return YES;
         }
         return NO;
     }];
    
    
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [weakself autoReconnectCancel:weakself.currentDevice.peripheral];
        weakself.currentDevice.peripheral = peripheral;
        weakself.currentDevice.name = peripheral.name;
    }];
    
    [_baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
       
//        weakself.APPCancelConnect=NO;
    }];
    
    [_baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        weakself.blestate=BleStateConnected;
        
        BOOL isDeviceConfiguredInternal = NO;
        BOOL isDeviceCharger = NO;
        if ([weakself.currentDevice.peripheral.identifier isEqual:peripheral.identifier]) {
            for (CBService *service in peripheral.services) {
                if ([service.UUID.UUIDString isEqualToString:NON_CONFIGURED_SERVICE_UUID]) {
                    isDeviceCharger = YES;
                }
                if ([service.UUID.UUIDString isEqualToString:PORT1_SERVICE_UUID] || [service.UUID.UUIDString isEqualToString:PORT2_SERVICE_UUID]) {
                    isDeviceConfiguredInternal = YES;
                }
            }
            
            if (isDeviceCharger) {
                if ([weakself.delegate respondsToSelector:@selector(connectingToCharger)]) {
                    [weakself.delegate connectingToCharger];
                }
            }
            
            if (isDeviceConfiguredInternal) {
                [weakself changeChargerState:ChargerConfigured];
            } else {
                [weakself changeChargerState:ChargerNotConfigured];
            }
        } else {
            NSLog(@"Not charger device");
        }
    }];
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {

        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([service.UUID.UUIDString isEqualToString:NON_CONFIGURED_SERVICE_UUID]) {
                if ([characteristic.UUID.UUIDString isEqualToString:NOTIFY_FFFF_CHARACTERISTIC_UUID]) {
                    [weakbaby notify:peripheral characteristic:characteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error){
                        NSLog(@"%@", characteristic.UUID.UUIDString);
                        NSData *data=characteristic.value;
                        if (data.length<3) {
                            return ;
                        }
                        
                        NSMutableData *Mutabledata=[NSMutableData dataWithData:data];
                        [weakself analyseData:Mutabledata];
                        
                        if(weakself._connectTimeoutTimer) {
                            [weakself._connectTimeoutTimer invalidate];
                        }
                    }];
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:WRITE_FFFF_CHARACTERISTIC_UUID]) {
                    _writeCharacteristic = characteristic;
                } else {
                }
            } else if ([service.UUID.UUIDString isEqualToString:PORT1_SERVICE_UUID] || [service.UUID.UUIDString isEqualToString:PORT2_SERVICE_UUID]) {
                [[EVChargersManager shared] addChargerWithPeripheral:peripheral andPort:service];
            }
        }
    }];
    
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        [[EVChargersManager shared] updateChargerValue:peripheral andCharacteristic:characteristic];
    }];
    
    [_baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        if (error) {
            
        }
        if (weakself.aPPCancelConnect) {
            weakself.aPPCancelConnect = NO;
            weakself.blestate=BleStateDisconnect;
        }
        else {
            weakself.blestate=BleStateReConnect;
            [weakself autoReconnect:weakself.currentDevice.peripheral];
        }
    }];
    
    [_baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [_baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        weakself.blestate=BleStateWaitToConnect;
        NSInteger count=weakself.bLEDeviceArray.count;

        if (count <= 0) {
            weakself.blestate=BleStateNoDevice;
        }
    }];

    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};

    [_baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    [_baby setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if (error) {

        }
    }];

    [weakbaby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error)
     {
         if (error) {
             NSLog(@"Error on write value on characteristic = %@",error);
             return ;
         }
     }];
}


- (void)scanBluetoothDevicesWithTimer:(int)time {
//    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//    _scanTimer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(stopScan) userInfo:nil repeats:NO];
}

- (void)connectToPeripheral:(CBPeripheral*)peripheral {
    NSLog(@"%@", peripheral.name);
    _baby.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().begin();
}



#pragma mark - INITIAL SETUP SECTION

- (void)setupDevice {
    if (_chagerState == ChargerConfiguring || _chagerState == ChargerConfigured) {
        return;
    }
    _chagerState = ChargerConfiguring;
    if (!_rsaobject) {
        _rsaobject=[DH_AES DHGenerateKey];
    }
    NSInteger datacount=80;

    uint16_t length=_rsaobject.P.length+_rsaobject.g.length+_rsaobject.PublickKey.length+6;
    [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:[PacketCommand SetNegotiatelength:length Sequence:_sequence]];
    
    _senddata=[PacketCommand GenerateNegotiateData:_rsaobject];
    NSInteger number=_senddata.length/datacount;
    if (number>0) {
        for(NSInteger i=0;i<number+1;i++)
        {
            if (i==number) {
                [NSThread sleepForTimeInterval:0.1f];
                NSData *data=[PacketCommand SendNegotiateData:_senddata Sequence:_sequence Frag:NO TotalLength:_senddata.length];
                [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:data];
                
            }
            else
            {
                [NSThread sleepForTimeInterval:0.1f];
                NSData *data=[PacketCommand SendNegotiateData:[_senddata subdataWithRange:NSMakeRange(0, datacount)] Sequence:_sequence Frag:YES TotalLength:_senddata.length];
                [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:data];
                _senddata=[_senddata subdataWithRange:NSMakeRange(datacount, _senddata.length-datacount)];
            }
        }
        
    } else {
        NSData *data=[PacketCommand SendNegotiateData:_senddata Sequence:_sequence Frag:NO TotalLength:_senddata.length];
        [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:data];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self setupWifiConnection];
        
    });
    
    
    
}

- (void)setupWifiConnection {
    if (!_isDataSent) {
        [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:[PacketCommand SetOpmode:STAOpmode Sequence:_sequence]];
        [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:[PacketCommand SetStationSsid:@"Zins-WiFi" Sequence:_sequence Encrypt:YES WithKeyData:_securtkey]];
        [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:[PacketCommand SetStationPassword:@"Z2236863" Sequence:_sequence Encrypt:YES WithKeyData:_securtkey]];
        [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:[PacketCommand ConnectToAPWithSequence:_sequence]];
        _isDataSent = YES;
    }
}

- (void)writeStructDataWithCharacteristic:(CBCharacteristic *)characteristic WithData:(NSData *)data {
    if ([_baby findConnectedPeripherals].firstObject && characteristic) {
        [[_baby findConnectedPeripherals].firstObject writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        _sequence=_sequence+1;
        NSLog(@"writing char");
    }
}

- (void)writeStuctDataWithCharacteristicWithoutResponce:(CBCharacteristic *)characteristic withData:(NSData *)data {
    if ([_baby findConnectedPeripherals].firstObject && characteristic) {
        [[_baby findConnectedPeripherals].firstObject writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        _sequence=_sequence+1;
        NSLog(@"writing char without response");
    }
}

-(void)analyseData:(NSMutableData *)data
{
    Byte *dataByte = (Byte *)[data bytes];
    
    Byte Type=dataByte[0] & 0x03;
    Byte sequence=dataByte[2];
    Byte frameControl=dataByte[1];
    Byte length=dataByte[3];
    
    BOOL hash=frameControl & Packet_Hash_FrameCtrlType;
    BOOL checksum=frameControl & Data_End_Checksum_FrameCtrlType;
    BOOL ack=frameControl & ACK_FrameCtrlType;
    BOOL appendPacket=frameControl & Append_Data_FrameCtrlType;
    
    if (hash) {
#ifdef DEBUG
        NSLog(@"HASH IS OK");
#endif
        NSRange range=NSMakeRange(4, length);
        NSData *Decryptdata=[data subdataWithRange:range];
        Byte *byte=(Byte *)[Decryptdata bytes];
        Decryptdata=[DH_AES blufi_aes_DecryptWithSequence:sequence data:byte len:length KeyData:_securtkey];
        [data replaceBytesInRange:range withBytes:[Decryptdata bytes]];
    }else{
#ifdef DEBUG
        NSLog(@"HASH NOT OK");
#endif
    }
    if (checksum) {
#ifdef DEBUG
        NSLog(@"Incoming Packet CHECKSUM is OK");
#endif
        if ([PacketCommand VerifyCRCWithData:data]) {
#ifdef DEBUG
            NSLog(@"Incoming Packet CRC is OK");
#endif
        } else {
#ifdef DEBUG
            NSLog(@"Incoming Packet CRC is FAIL");
#endif
            return;
        }
    }
    else {
#ifdef DEBUG
        NSLog(@"Incoming Packet CHECKSUM is FAIL");
#endif
    }
    if(ack) {
        [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:[PacketCommand ReturnAckWithSequence:_sequence BackSequence:sequence]];
    } else {
    }
    if (appendPacket) {
    } else {

    }
    
    if (Type==ContolType) {
//        [self GetControlPacketWithData:data];
    }
    else if (Type==DataType) {
        [self GetDataPackectWithData:data];
    }
    else {
    }
}

-(void)GetDataPackectWithData:(NSData *)data
{
    
    Byte *dataByte = (Byte *)[data bytes];
    Byte SubType=dataByte[0]>>2;
    Byte length=dataByte[3];
    
    switch (SubType) {
        case Negotiate_Data_DataSubType:
        {
            if (data.length<length+4) {
                return;
            }
            NSData *NegotiateData=[data subdataWithRange:NSMakeRange(4, length)];
            _securtkey=[DH_AES GetSecurtKey:NegotiateData RsaObject:_rsaobject];

            NSData *SetSecuritydata=[PacketCommand SetESP32ToPhoneSecurityWithSecurity:YES CheckSum:YES Sequence:_sequence];
            [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:SetSecuritydata];
            [self writeStructDataWithCharacteristic:_writeCharacteristic WithData:[PacketCommand GetDeviceInforWithSequence:_sequence]];
        }
            break;
            
        case Wifi_Connection_state_Report_DataSubType:
        {
            if (length<3) {
                return;
            }
            switch (dataByte[4])
            {
                case NullOpmode:
                    break;
                case STAOpmode:
                    break;
                case SoftAPOpmode:
                    break;
                case SoftAP_STAOpmode:
                    break;
                default:
                    break;
            }

            //STA STATUS
            if (dataByte[5]==0x0) {
                NSLog(@"STA = YES");
                [self changeChargerState:ChargerConfiguredAndScan];
               
               
            } else {
                NSLog(@"STA = NO");
            }
            if(length==0x13) {
            }
        }
            break;
        case Version_DataSubType:
            break;
            
        default:
            break;
    }
}

- (void)autoReconnectCancel:(CBPeripheral *)peripheral {
    [_baby AutoReconnectCancel:peripheral];
}

- (void)autoReconnect:(CBPeripheral *)peripheral {
    [_baby AutoReconnect:peripheral];
}


+ (BOOL)isAleadyExist:(NSString*)str BLEDeviceArray:(NSMutableArray *)array {
    NSInteger count=array.count;
    if (count==0) {
        return NO;
    }
    for (NSInteger i=0; i<count; i++) {
        EVBLEDevice *device=array[i];
        if ([str isEqualToString:device.name]) {
            return YES;
        }
    }
    return NO;
}

- (void)connect:(CBPeripheral *)peripheral {
//    _baby.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().discoverCharacteristics().begin();
}

- (BOOL)addPeripheralToArray:(CBPeripheral *)peripheral {
    for (EVBLEDevice *device in _devices) {
        if ([device.peripheral.identifier isEqual:peripheral.identifier]) {
            return NO;
        }
    }
    EVBLEDevice *bleDev = [EVBLEDevice new];
    bleDev.name = peripheral.name;
    bleDev.peripheral = peripheral;
    [_devices addObject:bleDev];
    return YES;
}

- (void)changeChargerState:(ChargerState)state {
    _chagerState = state;
    
    if (_chagerState == ChargerConfigured) {
        if (_needToUpdateData) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                _baby.having(_currentDevice.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
            });
        }
        if ([self.delegate respondsToSelector:@selector(startChargerInfoLoading)]) {
            [self.delegate startChargerInfoLoading];
        }
    }
    if (_chagerState == ChargerConfiguredAndScan) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            _baby.having(_currentDevice.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
        });
        
        if ([self.delegate respondsToSelector:@selector(startChargerInfoLoading)]) {
            [self.delegate startChargerInfoLoading];
        }
    }
    if (_chagerState == ChargerConfiguring) {
        if ([self.delegate respondsToSelector:@selector(startChargerInfoLoading)]) {
            [self.delegate startChargerInfoLoading];
        }
    }
    if (_chagerState == ChargerNotConfigured) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self setupDevice];
        });
        if ([self.delegate respondsToSelector:@selector(startSetupCharger)]) {
            [self.delegate startSetupCharger];
        }
    }
}

- (void)startAutomaticReadCharacteristics {
     _configureTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(readCharacteristics) userInfo:nil repeats:YES];
}

- (void)readCharacteristics {
    _baby.having(_currentDevice.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
}

- (void)cancelAllConnection {
    if([_baby findConnectedPeripherals].count>0)
    {
        [_baby cancelAllPeripheralsConnection];
    }
}

- (void)rebootDevice:(EVCharger *)charger {
    const char myByteArray[] = {255};
    NSData * data = [NSData dataWithBytes:myByteArray length:1];
    NSData * encryptedData = [data AES128EncryptedDataWithKey:key iv:iv];
    [self writeStructDataWithCharacteristic:charger.rebootCharacteristic WithData:encryptedData];
}

- (void)startCharging:(EVCharger *)charger withStartTime:(int)startTime {
//     [self writeStructDataWithCharacteristic:charger.rebootCharacteristic WithData:[NSMutableData]];
}

- (void)stopCharging:(EVCharger *)charger withStopTime:(int)stopTime {
    
}

@end


