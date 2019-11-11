//
//  EVMyChargersListViewController.h
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVViewController.h"
#import "EVCharger.h"

@interface EVMyChargersListViewController : EVViewController

@property(nonatomic, strong) NSArray<EVCharger *> *chargers;

@end
