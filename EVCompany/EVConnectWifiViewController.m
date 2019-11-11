//
//  EVConnectWifiViewController.m
//  EVCompany
//
//  Created by Anna on 10/12/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVConnectWifiViewController.h"
#import "EVViewController.h"
#import "ConstantStrings.h"
#import "EVBluetoothManager.h"
@import CoreBluetooth;

@interface EVConnectWifiViewController () {
    
    __weak IBOutlet UILabel *wifiLabel;
    __weak IBOutlet UIButton *chargerButton;
    __weak IBOutlet UIButton *bluetoothButton;

    BOOL isConnectionSuccess;
}

@end

@implementation EVConnectWifiViewController


- (void)viewDidLoad{
    NSLog(@"--------------EVConnectWifiViewController--------------");
    [super viewDidLoad];
    [super setNavigationBar:backArrow title:wifiTitle rightIconName:NULL selector:NULL rightButtonTitle:NULL];

    [[EVBluetoothManager shared] scanBluetoothDevicesWithTimer:3];

    // just for build purpose
    [self createButton:self.view y:105 buttonNumber:1 selector:@selector(selectCharger:)];
    [self showCancelAlert:self message:connectingMessage];
//    if (isConnectionSuccess) {
//        wifiLabel.text = wifiFailureMessage;
//        chargerButton.hidden = YES;
//        bluetoothButton.hidden = NO;
//    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
- (IBAction)selectCharger:(id)sender {
}
- (IBAction)connectViaBluetooth:(id)sender {
    [super goTo:bluetoothVC];
}


@end
