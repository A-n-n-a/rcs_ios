//
//  EVBLEDevice.h
//  EVCompany
//
//  Created by Zins on 11/21/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface EVBLEDevice : NSObject

@property(nonatomic,copy) NSString *name;
@property(nonatomic,strong) CBPeripheral *peripheral;

@end
