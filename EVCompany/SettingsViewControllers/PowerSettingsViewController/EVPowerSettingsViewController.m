//
//  EVPowerSettingsViewController.m
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVPowerSettingsViewController.h"
#import "EVSettingsChecboxTableViewCell.h"
#import "EVSettingsStandartTableViewCell.h"
#import "ConstantStrings.h"

@interface EVPowerSettingsViewController () <UITableViewDataSource, UITableViewDelegate> {
    int _selectedIndex;
    NSArray *_valuesArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation EVPowerSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar:backArrow title:power rightIconName:NULL selector:NULL rightButtonTitle: @"Done"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsStandartTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsStandartTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsChecboxTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsChecboxTableViewCell"];
    _selectedIndex = -1;
    _valuesArray = @[@"Day",@"Week",@"Month"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setNavigationBar:(NSString*)leftIconName title:(NSString*)title rightIconName:(NSString*)rightIconName selector:(SEL*)selector rightButtonTitle:(NSString*)rightButtonTitle {
    [super setNavigationBar:leftIconName title:title rightIconName:rightIconName selector:selector rightButtonTitle:rightButtonTitle];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style: UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked)];
    [self.navigationItem setRightBarButtonItem: rightButton];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return 3;
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setupCell:@"Power (kWh)" info:@"75"];
            return cell;
        }
        case 1:
        {
            EVSettingsChecboxTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsChecboxTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setupCell:[_valuesArray objectAtIndex:indexPath.row] checked:_selectedIndex == indexPath.row ? YES : NO];
            return cell;
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
        if (indexPath.section == 1) {
            if (indexPath.row == _selectedIndex) {
                _selectedIndex = -1;
            } else {
                _selectedIndex = (int)indexPath.row;
            }
        }
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
}

- (void)doneButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}




@end
