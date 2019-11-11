//
//  EVMyChargersListViewController.m
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVMyChargersListViewController.h"
#import "EVMyChargerHeaderView.h"
#import "EVMyChargerFooterView.h"
#import "EVMyChargerStatusTableViewCell.h"
#import "EVMyChargerDelayTableViewCell.h"
#import "EVMyChargerScheduleTableViewCell.h"
#import "EVMyChargerProgressView.h"
#import "EVBluetoothManager.h"
#import "ConstantStrings.h"

@interface EVMyChargersListViewController () <UITableViewDataSource, UITableViewDelegate, ChargerStartStopButtonDelegate> {
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EVMyChargersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBar:menuIcon title:myCharger rightIconName:NULL selector:NULL rightButtonTitle: settings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargersUpdated:) name:@"ChargersDidUpdated" object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EVMyChargerHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"EVMyChargerHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVMyChargerFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"EVMyChargerFooterView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVMyChargerStatusTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVMyChargerStatusTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVMyChargerDelayTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVMyChargerDelayTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVMyChargerScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVMyChargerScheduleTableViewCell"];
    
    [self.tableView setEstimatedRowHeight:100.f];
//    [self.tableView setEstimatedSectionHeaderHeight:150.f];
    [self.tableView setEstimatedSectionFooterHeight:105.f];
    
    [self.tableView setBackgroundColor: [UIColor whiteColor]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _chargers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    EVMyChargerHeaderView *header = (EVMyChargerHeaderView *)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"EVMyChargerHeaderView"];
    EVCharger *charger = [_chargers objectAtIndex:section];
    header.currentCharger = charger;
    [header setupHeaderView:charger.name progress:charger.status/100.f];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    EVMyChargerFooterView *footer = (EVMyChargerFooterView *)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"EVMyChargerFooterView"];
    footer.identifier = section;
    [footer setDelegate:self];
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 95.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EVCharger *charger = [_chargers objectAtIndex:indexPath.section];
    switch (indexPath.row) {
        case 0:
        {
            EVMyChargerStatusTableViewCell *cell = (EVMyChargerStatusTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"EVMyChargerStatusTableViewCell"];
            cell.currentCharger = charger;
            if (!charger.isCharging) {
                NSLog(@"NOT READY");
                [cell setupCell:@"Charging" kWh:[NSString stringWithFormat:@"%2.2f", charger.kWH]
                       amperage:[NSString stringWithFormat:@"%2.2fA", charger.amperage]
                       duration:[self fromIntToTimeStr:charger.duration]
                           cost:[NSString stringWithFormat:@"$ %2.2f", charger.cost]];
            } else {
                NSLog(@"READY");
               [cell setupCell:@"Ready"];
            }


            return cell;
        }

        case 1:
        {
            EVMyChargerScheduleTableViewCell *cell = (EVMyChargerScheduleTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"EVMyChargerScheduleTableViewCell"];
            NSString *daysOfWeek = [charger.schedule getWeekDaysString];
            NSString *startStopTime = [charger.schedule scheduleTimeString];
            NSString *kWtHForDay = [NSString stringWithFormat:@"%ld kWt/h for week", charger.schedule.kWHLimitPerWeek];
            NSString *result;
            if (charger.schedule.kWHLimitPerWeek != 0) {
                result = [NSString stringWithFormat:@"%@", kWtHForDay];
            } else if (daysOfWeek != nil && startStopTime != nil){
                result = [NSString stringWithFormat:@"%@\n%@", daysOfWeek, startStopTime];
            } else {
                result = @"";
            }
            [cell setupCell:result];
            
            return cell;
        }

        case 2:
        {
            EVMyChargerDelayTableViewCell *cell = (EVMyChargerDelayTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"EVMyChargerDelayTableViewCell"];
            [cell setupCell];

            return cell;
        }

        default:
            return nil;
    }
}

- (void)chargersUpdated:(NSNotification *)notif {
    self.chargers = [notif object];
    }
//
//            [CATransaction begin];
//
//             [self.tableView beginUpdates];
//    
//             
//             [self.tableView endUpdates];
//             [CATransaction commit];


#pragma mark - ChargerStartStopButtonDelegate

- (void)startButtonClicked:(id)sender {
    EVMyChargerFooterView *footer = sender;
    [[EVBluetoothManager shared] startCharging:[_chargers objectAtIndex:(int)footer.identifier] withStartTime:0];
}

- (void)stopButtonClicked:(id)sender {
    EVMyChargerFooterView *footer = sender;
    [[EVBluetoothManager shared] stopCharging:[_chargers objectAtIndex:(int)footer.identifier] withStopTime:0];
}

- (NSString *)fromIntToTimeStr:(uint32_t)elapsedSeconds {
    NSUInteger h = elapsedSeconds / 3600;
    NSUInteger m = (elapsedSeconds / 60) % 60;
    NSUInteger s = elapsedSeconds % 60;
    
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu", h, m, s];
}

@end
