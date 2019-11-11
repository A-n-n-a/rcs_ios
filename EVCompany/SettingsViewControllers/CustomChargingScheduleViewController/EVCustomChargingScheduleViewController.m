//
//  EVCustomChargingScheduleViewController.m
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVCustomChargingScheduleViewController.h"
#import "EVSettingsSwitchTableViewCell.h"
#import "EVSettingsStandartTableViewCell.h"
#import "EVSettingsTextWithImageTableViewCell.h"
#import "EVScheduleEditorViewController.h"
#import "ConstantStrings.h"
#import "EVSchedule.h"

@interface EVCustomChargingScheduleViewController () <UITableViewDelegate, UITableViewDataSource> {
    EVSchedule *_schedule;
    BOOL _isPower;
    BOOL _isSchedule;
    BOOL _isHours;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation EVCustomChargingScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBar:backArrow title:customChargingSchedule rightIconName:NULL selector:NULL rightButtonTitle: NULL];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsStandartTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsStandartTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsSwitchTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsSwitchTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsTextWithImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsTextWithImageTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _schedule = [EVSchedule new];
    _isPower = YES;
    _isSchedule = YES;
    _isHours = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return 1 + _isPower;
        case 2: return 1 + _isSchedule;
        case 3: return 1 + _isHours;
        default: return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
            [cell setupCell:@"Charger ID" info:@"213123sdsd23112"];
            [cell setTitleBold:YES];
            [cell setInfoBold:NO];
            return cell;
        }
        case 1:
        {
            if (indexPath.row == 0) {
                EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
                [cell setupCell:@"Power" state:_isPower];
                [cell.cellSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
                [cell.cellSwitch setTag:powerSwitch];
                return cell;
            } else {
                EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                [cell setupCell:@"145kwh / week" info:@""];
                [cell setTitleBold:NO];
                return cell;
            }
        }
        case 2: {
            if (indexPath.row == 0) {
                EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
                [cell setupCell:@"Schedule" state:_isSchedule];
                [cell.cellSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
                [cell.cellSwitch setTag:scheduleSwitch];
                return cell;
            } else {
                EVSettingsTextWithImageTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsTextWithImageTableViewCell" forIndexPath:indexPath];
                [cell setupCell:[NSString stringWithFormat:@"%@\n%@", [_schedule getWeekDaysString], [_schedule scheduleTimeString]]];
                return cell;
            }
        }
        case 3: {
            if (indexPath.row == 0) {
                EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
                [cell setupCell:@"Hours" state:_isHours];
                [cell.cellSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
                [cell.cellSwitch setTag:hoursSwitch];
                return cell;
        } else {
                EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                [cell setupCell:@"4 Hours" info:@""];
                [cell setTitleBold:NO];
                return cell;
            }
        }
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 10.f;
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 0, 0);
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        } else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        layer.fillColor = [UIColor colorWithRed:245/255 green:245/255 blue:245/255 alpha:0.05f].CGColor;
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = 1.f;
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, 1.f);
            lineLayer.backgroundColor = [UIColor colorWithRed:217.f/255.f green:217.f/255.f blue:217.f/255.f alpha:1.f].CGColor;
            [layer addSublayer:lineLayer];
        }
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.whiteColor;
        cell.backgroundView = testView;
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    if ([tableView numberOfRowsInSection:indexPath.section] == 1) {
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: cell.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii: (CGSize){10.f, 10.f}].CGPath;
        cell.layer.mask = maskLayer;
    } else {
        if (indexPath.row == 0) {
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: cell.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.f, 10.f}].CGPath;
            cell.layer.mask = maskLayer;
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: cell.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.f, 10.f}].CGPath;
            cell.layer.mask = maskLayer;
        }
    }
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier: @"EVPowerSettingsViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 2 && indexPath.row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        EVScheduleEditorViewController *vc = [storyboard instantiateViewControllerWithIdentifier: @"EVScheduleEditorViewController"];
        vc.schedule = _schedule;
        [self.navigationController pushViewController:vc animated:YES];
    }
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)changeSwitch:(UISwitch *)sender {
    
    
    switch (sender.tag) {
        case powerSwitch:
            _isPower = [sender isOn];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case scheduleSwitch:
            _isSchedule = [sender isOn];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case hoursSwitch:
            _isHours = [sender isOn];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
        default:
            break;
    }
}

typedef enum {
    powerSwitch = 0,
    scheduleSwitch = 1,
    hoursSwitch = 2,
} Informations;

@end
