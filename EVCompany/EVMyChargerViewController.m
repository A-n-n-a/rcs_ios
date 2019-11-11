//
//  EVMyChargerViewController.m
//  EVCompany
//
//  Created by Anna on 10/11/17.
//  Copyright © 2017 Srishti. All rights reserved.
//


#import "EVMyChargerViewController.h"
#import "EVViewController.h"
#import "ConstantStrings.h"

@interface EVMyChargerViewController () {

}


@end

@implementation EVMyChargerViewController


- (void)viewDidLoad{
    NSLog(@"--------------EVMyChargerViewController--------------");
    [super viewDidLoad];
    [super setNavigationBar:backArrow title:bluetoothTitle rightIconName:NULL selector:NULL rightButtonTitle:NULL];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}



-(IBAction)connectBluetooth:(id)sender{
    [super goTo:bluetoothVC];

}

-(IBAction)connectWifi:(id)sender{
    [super goTo:wifiVC];

}

@end


