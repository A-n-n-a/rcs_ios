//
//  EVAddChargerViewController.m
//  EVCompany
//
//  Created by Anna on 10/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EVAddChargerViewController.h"
#import "EVViewController.h"
#import "ConstantStrings.h"



@interface EVAddChargerViewController () {
    __weak IBOutlet UIButton *wifiButton;
}


@end

@implementation EVAddChargerViewController


- (void)viewDidLoad { 
    
    [super viewDidLoad];
    [super setNavigationBar:menuIcon title:addChargerTitle rightIconName:myChargers selector:NULL rightButtonTitle:NULL];
}

@end
