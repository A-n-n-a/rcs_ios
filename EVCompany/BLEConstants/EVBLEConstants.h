//
//  EVBLEConstants.h
//  EVCompany
//
//  Created by Zins on 11/10/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Service UUIDs
static NSString *const NON_CONFIGURED_SERVICE_UUID     = @"FFFF";

static NSString *const PORT1_SERVICE_UUID              = @"00003EBB-0000-1000-8000-00805F9B34FB";
static NSString *const PORT2_SERVICE_UUID              = @"00003ECC-0000-1000-8000-00805F9B34FB";

static NSString *const PORT1_NAME                      = @"RCS_CHARGER PORT_A";
static NSString *const PORT2_NAME                      = @"RCS_CHARGER PORT_B";

#pragma mark - Characteristics UUIDs
static NSString *const ISCHARGING_CHARACTERISTIC_UUID  = @"3E01";
static NSString *const KWH_CHARACTERISTIC_UUID         = @"3E02";
static NSString *const AMPERAGE_CHARACTERISTIC_UUID    = @"3E03";
static NSString *const DURATION_CHARACTERISTIC_UUID    = @"3E04";
static NSString *const COST_CHARACTERISTIC_UUID        = @"3E05";
static NSString *const STARTDATE_CHARACTERISTIC_UUID   = @"3E06";
static NSString *const SCHEDULE_CHARACTERISTIC_UUID    = @"3E07";
static NSString *const STATUS_CHARACTERISTIC_UUID      = @"3E08";
static NSString *const NAME_CHARACTERISTIC_UUID        = @"3E09";
static NSString *const STARTSTOP_CHARACTERISTIC_UUID   = @"3E0A";
static NSString *const REBOOT_CHARACTERISTIC_UUID      = @"3E0B";

static NSString *const WRITE_FFFF_CHARACTERISTIC_UUID  = @"FF01";
static NSString *const NOTIFY_FFFF_CHARACTERISTIC_UUID = @"FF02";

#pragma mark - Charger Name Prefix

static NSString *const CONFIGURED_DEVICE_PREFIX        = @"ESP";
static NSString *const NOT_CONFIGURED_DEVICE_PREFIX    = @"BLUFI";

@interface EVBLEConstants : NSObject

@end
