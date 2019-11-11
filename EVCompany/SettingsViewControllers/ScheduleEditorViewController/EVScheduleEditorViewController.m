//
//  EVScheduleEditorViewController.m
//  EVCompany
//
//  Created by Zins on 12/19/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVScheduleEditorViewController.h"
#import "EVSettingsChecboxTableViewCell.h"
#import "EVSettingsStandartTableViewCell.h"
#import "ConstantStrings.h"

@interface EVScheduleEditorViewController()<UITableViewDelegate, UITableViewDataSource> {
    NSArray *_valuesArray;
    int _currentTimePicker;
    NSDateFormatter *_formatter;
}
@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation EVScheduleEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar:backArrow title:schedule rightIconName:NULL selector:NULL rightButtonTitle: @"Done"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsStandartTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsStandartTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsChecboxTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsChecboxTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _formatter = [NSDateFormatter new];
    
    _valuesArray = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2;
        case 1: return 7;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            EVSettingsStandartTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
            [cell setTitleBold:YES];
            [cell setInfoBold:NO];
            if (indexPath.row == 0) {
                NSLog(@"%i",_schedule.timeStart);
                [cell setupCell:@"Time Start" info:[_schedule getTimeStart]];
            } else {
                [cell setupCell:@"Time End" info:[_schedule getTimeEnd]];
            }
            return cell;
        }
        case 1:
        {
            EVSettingsChecboxTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsChecboxTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0:
                    [cell setupCell:[_valuesArray objectAtIndex:indexPath.row] checked:_schedule.monday];
                    break;
                case 1:
                    [cell setupCell:[_valuesArray objectAtIndex:indexPath.row] checked:_schedule.tuestay];
                    break;
                case 2:
                    [cell setupCell:[_valuesArray objectAtIndex:indexPath.row] checked:_schedule.wednesday];
                    break;
                case 3:
                    [cell setupCell:[_valuesArray objectAtIndex:indexPath.row] checked:_schedule.thursday];
                    break;
                case 4:
                    [cell setupCell:[_valuesArray objectAtIndex:indexPath.row] checked:_schedule.friday];
                    break;
                case 5:
                    [cell setupCell:[_valuesArray objectAtIndex:indexPath.row] checked:_schedule.saturday];
                    break;
                case 6:
                    [cell setupCell:[_valuesArray objectAtIndex:indexPath.row] checked:_schedule.sunday];
                    break;
                    
                default:
                    break;
            }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self showPickerView:(int)indexPath.row];
    }
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                _schedule.monday = !_schedule.monday;
            }
                break;
            case 1:
            {
                _schedule.tuestay = !_schedule.tuestay;
            }
                break;
            case 2:
            {
                _schedule.wednesday = !_schedule.wednesday;
            }
                break;
            case 3:
            {
                _schedule.thursday = !_schedule.thursday;
            }
                break;
            case 4:
            {
                _schedule.friday = !_schedule.friday;
            }
                break;
            case 5:
            {
                _schedule.saturday = !_schedule.saturday;
            }
                break;
            case 6:
            {
                _schedule.sunday = !_schedule.sunday;
            }
                break;
                
            default:
                break;
        }
        [self.tableView reloadData];
    }
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)doneButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)showPickerView:(int)currentPicker {
    _currentTimePicker = currentPicker;
    [self.tableView setUserInteractionEnabled:NO];
    _pickerView.hidden = NO;
}
- (IBAction)cancelButtonDidTap:(id)sender {
    [self.tableView setUserInteractionEnabled:YES];
    _pickerView.hidden = YES;
}
- (IBAction)doneButtonDidTap:(id)sender {
    _formatter.dateFormat = @"HH";
    int hours = [[_formatter stringFromDate:_picker.date] intValue];
    _formatter.dateFormat = @"mm";
    int minutes = [[_formatter stringFromDate:_picker.date] intValue];
    
    int timeInSeconds = hours * 3600 + minutes * 60;
    if (_currentTimePicker == 0) {
        _schedule.timeStart = timeInSeconds;
    } else {
        _schedule.timeEnd = timeInSeconds;
    }
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView setUserInteractionEnabled:YES];
    _pickerView.hidden = YES;
}

@end
