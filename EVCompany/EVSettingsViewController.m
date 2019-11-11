//
//  EVSettingsViewController.m
//  EVCompany
//
//  Created by Anna on 12/12/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSettingsViewController.h"
#import "ConstantStrings.h"
#import "EVBluetoothManager.h"
#import "EVMyChargersListViewController.h"

@interface EVSettingsViewController () {
    BOOL isPowerOn;
}
@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UIView *adminView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UILabel *powerLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerClickLabel;

@end

@implementation EVSettingsViewController

NSArray<EVCharger *> *_chargers;

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBar:backArrow title:settings rightIconName:NULL selector:NULL rightButtonTitle: NULL];
    isPowerOn = YES;
    _chargers = [NSArray<EVCharger *> new];
}

- (IBAction)segmentedControllerDidTap:(UISegmentedControl *)sender {
    _adminView.hidden = sender.selectedSegmentIndex == 0;
    _generalView.hidden = sender.selectedSegmentIndex == 1;
}
- (IBAction)energyUsageButtonDidTap:(id)sender {
//    [super goToStoryboard:usageReportsIdentifier];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier: @"EVUsageReportViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)customChargingScheduleButtonDidTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"EVCustomChargingScheduleViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)energyProviderSetUpButtonDidTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"EVEnergyProviderSetupViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)notificationsButtonDidTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"EVNotificationsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)powerButtonDidTap:(id)sender {
    isPowerOn = !isPowerOn;
    _powerLabel.text = isPowerOn ? powerOn : powerOff;
    _powerClickLabel.text = isPowerOn ? clickForOff : clickForOn;
}
- (IBAction)pairingButtonDidTap:(id)sender {
    [self goTo: userListViewController];
}
- (IBAction)rebootButtonDidTap:(id)sender {
    EVMyChargersListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EVMyChargersListViewController"];
    _chargers = vc.chargers;
    //TODO: choose charger  depending on chosen segmented controller
    [[EVBluetoothManager shared] rebootDevice:_chargers[0]];

}
- (IBAction)systemInformation:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"EVSystemInformationViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end

