//
//  EVConnectBluetoothViewController.m
//  EVCompany
//
//  Created by Anna on 10/12/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVConnectBluetoothViewController.h"
#import "EVViewController.h"
#import "ConstantStrings.h"
#import "EVBluetoothManager.h"
#import "BabyBluetooth.h"
#import "EVChargerCell.h"
#import "EVCharger.h"
#import "EVMyChargersListViewController.h"
#import "EVBLEDevice.h"
@import CoreBluetooth;

#define filterBLEname   @"BLUFI"
#define ConnectedDeviceKey  @"ConnectedDevice"
#define SCANTIME        20


@interface EVConnectBluetoothViewController () <UITableViewDelegate, UITableViewDataSource, EVBluetoothManagerDelegate> {
    
    //__weak IBOutlet UITableView *tableView;
    
    __weak IBOutlet UILabel *bluetoothLabel;
    __weak IBOutlet UIButton *wifiButton;

    BabyBluetooth *baby;
    UIAlertController *_alert;
    
    NSMutableArray<EVBLEDevice *> *_devices;
    
}


@property(nonatomic,assign)BleState blestate;
@property(nonatomic,strong)NSMutableArray* list;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *charger;
@property(nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation EVConnectBluetoothViewController


- (void)viewDidLoad{

    [super viewDidLoad];
    [super setNavigationBar:backArrow title:bluetoothTitle rightIconName:NULL selector:NULL rightButtonTitle:NULL];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterface:) name:@"updateInterface" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChargers:) name:@"ChargerInfoDidUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBluetoothTurnOffAlert) name:@"showBluetoothTurnOffAlert" object:nil];
    
    [[EVBluetoothManager shared] scanBluetoothDevicesWithTimer:3];
    
//    [self showCancelAlert:self message:connectingMessage];
    self.alert = self.activeAlert;
    _devices = [NSMutableArray new];
    [self showNoDevices];

}

-(void)showNoDevices {
    bluetoothLabel.text = bluetoothFailureMessage;
    wifiButton.hidden = NO;
    _tableView.hidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[EVBluetoothManager shared] setDelegate:self];
}

#pragma mark - Notifications

- (void)updateInterface:(NSNotification *)notification {
    [self.alert dismissViewControllerAnimated:YES completion:nil];
    _devices = [notification object];
    
    
    if (_devices.count == 0) {
        bluetoothLabel.text = bluetoothFailureMessage;
        wifiButton.hidden = NO;
        _tableView.hidden = YES;
        [self.view setNeedsDisplay];
    } else {
        bluetoothLabel.text = findingChargersMessage;
        wifiButton.hidden = YES;
        _tableView.hidden = NO;
        [self.tableView reloadData];
    }
}

- (void)updateChargers:(NSNotification *)notification {
    NSArray<EVCharger *> *chargers = [notification object];
    [self.alert dismissViewControllerAnimated:YES completion:nil];
    EVMyChargersListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EVMyChargersListViewController"];
    vc.chargers = chargers;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showBluetoothTurnOffAlert {
    [super showOkAlert:self message:bluetuthTurnedOffMessage];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (IBAction)chooseCharger:(UIButton*)sender {
    CBPeripheral *peripheral = _devices[sender.tag - 1].peripheral;
//    NSLog(@"PERIPH NAME = %@", _devices[sender.tag - 1].peripheral.name);
    [[EVBluetoothManager shared] connectToPeripheral:peripheral];
    
    _alert = [UIAlertController alertControllerWithTitle:@"Connecting to Charger" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:_alert animated:YES completion:nil];
//    [self showAlertWithTextField:self whithCompletionHandler:^(BOOL match) {
//        if (match) {
//
//            //[self connect:peripheral];
//        }
//    }];
}

- (IBAction)connectViaWifi:(id)sender {
    [super goTo:wifiVC];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _devices.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EVChargerCell *cell = [tableView dequeueReusableCellWithIdentifier: ChargerCellIdentifier forIndexPath:indexPath];
    [cell.chargerButton setTitle:_devices[indexPath.row].name forState:UIControlStateNormal];
    [cell.chargerButton addTarget:self action:@selector(chooseCharger:) forControlEvents:UIControlEventTouchUpInside];
    cell.chargerButton.tag = indexPath.row + 1;
    return cell;
}

#pragma mark - UITableViewDelegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row == 0){
//        //TODO: action implementation
//    }
//}

#pragma mark - EVBluetoothManagerDelegate

- (void)connectingToCharger {
    
}

- (void)startSetupCharger {
    [_alert setTitle:@"Configuring device"];
}

- (void)finishSetupCharger {
    [_alert setTitle:@"Device Configured"];
}

- (void)startChargerInfoLoading {
    [_alert setTitle:@"Loading Info"];
}

- (void)chargerInfoLoaded {
    [_alert setMessage:@"Info Loaded"];
}


@end


