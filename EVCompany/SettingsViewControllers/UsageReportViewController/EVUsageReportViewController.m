//
//  EVUsageReportViewController.m
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVUsageReportViewController.h"
#import "EVSettingsDateTableViewCell.h"
#import "EVSettingsStandartTableViewCell.h"
#import "EVSettingWithImageTableViewCell.h"
#import "ConstantStrings.h"

@interface EVUsageReportViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *_filtersTitleList;
    NSMutableArray *_resultsTitleList;
    NSMutableArray *_filtersList;
    NSMutableArray *_resultsList;
    NSMutableArray *_headerTitleList;
    
    BOOL _isDateSectionVisible;
    CGFloat _cellHeight;
    NSInteger _index;
    NSString *_dateString;
    NSDateFormatter *_formatter;
    NSString *_startButtonTitle;
    NSString *_finishButtonTitle;
    NSInteger _currentButtonTag;
    NSDate *_currentDate;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *picker;

@end

@implementation EVUsageReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBar:backArrow title:usageReports rightIconName:NULL selector:NULL rightButtonTitle: NULL];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsDateTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsDateTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsStandartTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsStandartTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingWithImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingWithImageTableViewCell"];
    
    _filtersTitleList = [NSMutableArray arrayWithObjects: @"Ports", @"Time", nil];
    _resultsTitleList = [NSMutableArray arrayWithObjects: @"Time", @"Power", @"Cost", nil];
    _filtersList = [NSMutableArray arrayWithObjects: @"Connector 1", @"Last week", nil];
    _resultsList = [NSMutableArray arrayWithObjects: @"3:45:21", @"145 kWt/h", @"$70", nil];
    _headerTitleList = [NSMutableArray arrayWithObjects: @"Filters", @"Result", nil];
    _isDateSectionVisible = NO;
    _cellHeight = 70;
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateStyle:NSDateFormatterShortStyle];
    [_formatter setTimeStyle:NSDateFormatterNoStyle];
    _currentDate = [NSDate date];
    NSDate *tenDaysAgo = [_currentDate dateByAddingTimeInterval:-10*24*60*60];
    _finishButtonTitle = [_formatter stringFromDate:_currentDate];
    _startButtonTitle = [_formatter stringFromDate:tenDaysAgo];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)showTimePopUpMenu {
    UIAlertController *alert = [UIAlertController  alertControllerWithTitle:@"Select Time" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *allDates = [UIAlertAction  actionWithTitle: @"All Dates"
                                                        style: UIAlertActionStyleDefault
                                                      handler: ^(UIAlertAction *action) {
                                                          [_filtersList replaceObjectAtIndex:_index withObject:@"All Dates"];
//                                                          [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_index inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
                                                          _isDateSectionVisible = NO;
                                                          [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                                      }];
    UIAlertAction *yesterday = [UIAlertAction  actionWithTitle: @"Yesterday"
                                                         style: UIAlertActionStyleDefault
                                                       handler: ^(UIAlertAction *action) {
                                                           
                                                           [_filtersList replaceObjectAtIndex:_index withObject:@"Yesterday"];
                                                           _isDateSectionVisible = NO;
                                                           [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                                       }];
    UIAlertAction *thisWeek = [UIAlertAction  actionWithTitle: @"This Week"
                                                        style: UIAlertActionStyleDefault
                                                      handler: ^(UIAlertAction *action) {
                                                          [_filtersList replaceObjectAtIndex:_index withObject:@"This Week"];
                                                          _isDateSectionVisible = NO;
                                                          [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                                      }];
    UIAlertAction *currentMonth = [UIAlertAction  actionWithTitle: @"Current Month"
                                                            style: UIAlertActionStyleDefault
                                                          handler: ^(UIAlertAction *action) {
                                                              [_filtersList replaceObjectAtIndex:_index withObject:@"Current Month"];
                                                              _isDateSectionVisible = NO;
                                                              [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                                          }];
    UIAlertAction *chooseDates = [UIAlertAction  actionWithTitle: @"Choose Dates"
                                                           style: UIAlertActionStyleDefault
                                                         handler: ^(UIAlertAction *action) {
                                                             [_filtersList replaceObjectAtIndex:_index withObject:@"Choose Dates"];
                                                             _isDateSectionVisible = YES;
                                                             [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                                          
                                                         }];
    UIAlertAction* cancel = [UIAlertAction  actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action) {
                                                        //Handle cancel action
                                                    }];
    [alert addAction:allDates];
    [alert addAction:yesterday];
    [alert addAction:thisWeek];
    [alert addAction:currentMonth];
    [alert addAction:chooseDates];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPortsPopUpMenu {
    UIAlertController *alert = [UIAlertController  alertControllerWithTitle:@"Select Connector" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *connector1 = [UIAlertAction  actionWithTitle: @"Connector 1"
                                                          style: UIAlertActionStyleDefault
                                                        handler: ^(UIAlertAction *action) {
                                                            [_filtersList replaceObjectAtIndex:_index withObject:@"Connector 1"];
                                                            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_index inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
                                                        }];
    UIAlertAction *connector2 = [UIAlertAction  actionWithTitle: @"Connector 2"
                                                          style: UIAlertActionStyleDefault
                                                        handler: ^(UIAlertAction *action) {
                                                            [_filtersList replaceObjectAtIndex:_index withObject:@"Connector 2"];
                                                            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_index inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
                                                        }];
    UIAlertAction* cancel = [UIAlertAction  actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action) {
                                                        //Handle cancel action
                                                    }];
    [alert addAction:connector1];
    [alert addAction:connector2];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_headerTitleList objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    EVSettingWithImageTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingWithImageTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:_filtersTitleList[indexPath.row] info:_filtersList[indexPath.row]];
                    return cell;
                }
                case 1:
                {
                    EVSettingWithImageTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingWithImageTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:_filtersTitleList[indexPath.row] info:_filtersList[indexPath.row]];
                    return cell;
                }
                case 2:
                {
                    EVSettingsDateTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsDateTableViewCell" forIndexPath:indexPath];
                    [cell.startDateButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.startDateButton setTitle:_startButtonTitle forState:UIControlStateNormal];
                    cell.startDateButton.tag = 1;
                    [cell.finishDateButton addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.finishDateButton setTitle:_finishButtonTitle forState:UIControlStateNormal];
                    cell.finishDateButton.tag = 2;
                    return cell;
                }
                default:
                    return nil;
            }
        }
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:_resultsTitleList[indexPath.row] info:_resultsList[indexPath.row]];
                    [cell setInfoBold:YES];
                    [cell setTitleBold:YES];
                    return cell;
                }
                case 1:
                {
                    EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:_resultsTitleList[indexPath.row] info:_resultsList[indexPath.row]];
                    [cell setInfoBold:YES];
                    [cell setTitleBold:YES];
                    return cell;
                }
                case 2:
                {
                    EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                    [cell setupCell:_resultsTitleList[indexPath.row] info:_resultsList[indexPath.row]];
                    [cell setInfoBold:YES];
                    [cell setTitleBold:YES];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2 + _isDateSectionVisible;
        case 1:
            return 3;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cellHeight;
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
    if ([tableView isEqual:_tableView]) {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:    [self showPortsPopUpMenu];
                default:   [self showTimePopUpMenu];
            }
            _index = indexPath.row;
        }
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - IBA

-(void)showPickerView:(UIButton*)sender {
    _currentButtonTag = sender.tag;
    _pickerView.hidden = NO;
}
- (IBAction)cancelButtonDidTap:(id)sender {
    _pickerView.hidden = YES;
}
- (IBAction)doneButtonDidTap:(id)sender {
    
    _dateString = [_formatter stringFromDate:_picker.date];
    if (_currentButtonTag == 1) {
        _startButtonTitle = _dateString;
    } else {
        _finishButtonTitle = _dateString;
    }
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
    _pickerView.hidden = YES;
}

@end
