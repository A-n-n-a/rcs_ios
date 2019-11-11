//
//  EVEnergyProviderSetupViewController.m
//  EVCompany
//
//  Created by Zins on 12/19/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVEnergyProviderSetupViewController.h"
#import "EVSettingsSwitchTableViewCell.h"
#import "EVSettingsStandartTableViewCell.h"
#import "ConstantStrings.h"

@interface EVEnergyProviderSetupViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EVEnergyProviderSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setNavigationBar:backArrow title:energyProviderSetUp rightIconName:NULL selector:NULL rightButtonTitle: nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsStandartTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsStandartTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsSwitchTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsSwitchTableViewCell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2;
        case 1: return 4;
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
            
            if (indexPath.row == 0) {
                EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
                [cell setupCell:@"Standart cost"];
                return cell;
            }
            EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
            [cell setupCell:@"Price per kWH" info:@"$0.75"];
            [cell setTitleBold:YES];
            [cell setInfoBold:NO];
            return cell;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:@"Off Peak Cost"];
                    return cell;
                }
                case 1:
                {
                    EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:@"Time Start" info:@"3:00 am"];
                    [cell setTitleBold:YES];
                    [cell setInfoBold:NO];
                    return cell;
                }
                case 2:
                {
                    EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:@"Time End" info:@"7:00 am"];
                    [cell setTitleBold:YES];
                    [cell setInfoBold:NO];
                    return cell;
                }
                case 3:
                {
                    EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:@"Price" info:@"$0.50"];
                    [cell setTitleBold:YES];
                    [cell setInfoBold:NO];
                    return cell;
                }
                    
                default:
                    return nil;
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
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
