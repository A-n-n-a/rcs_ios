//
//  EVNotificationsViewController.m
//  EVCompany
//
//  Created by Zins on 12/19/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVNotificationsViewController.h"
#import "EVSettingsSwitchTableViewCell.h"
#import "EVSettingsStandartTableViewCell.h"
#import "EVSettingsButtonTableViewCell.h"
#import "ConstantStrings.h"

@interface EVNotificationsViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSArray *_notificationsTitles;
    NSArray *_sectionNames;
    NSMutableArray *_emailsList;
    NSMutableArray *_phoneNumbersList;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EVNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar:backArrow title:notifications rightIconName:NULL selector:NULL rightButtonTitle: nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsSwitchTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsSwitchTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsStandartTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsStandartTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsButtonTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsButtonTableViewCell"];
    _notificationsTitles = @[@"Charging Start", @"Charging Stop", @"Faults"];
    _sectionNames = @[@"TYPE OF NOTIFICATIONS", @"SEND BY"];
    _emailsList = [NSMutableArray arrayWithObjects: @"example@gmail.com", nil];
    _phoneNumbersList = [NSMutableArray arrayWithObjects: @"+1 888-123-4567", @"+1 888-123-4567", nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 3;
        case 1: return 1;
        case 2: return 2 + _emailsList.count;
        case 3: return 2 + _phoneNumbersList.count;
        default: return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return [_sectionNames objectAtIndex:section];
        case 1: return [_sectionNames objectAtIndex:section];
        default: return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return 20;
        case 1: return 20;
        default: return 10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
            [cell setupCell:[_notificationsTitles objectAtIndex:indexPath.row]];
            return cell;
        }
        case 1:
        {
            EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
            [cell setupCell:@"Push"];
            return cell;
        }
        case 2:
        {
            if (indexPath.row == 0) {
                EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
                [cell setupCell:@"By Email"];
                return cell;
                
            } else if (indexPath.row == _emailsList.count + 1) {
                EVSettingsButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"EVSettingsButtonTableViewCell" forIndexPath:indexPath];
                [cell.addButton setTitle:@"Add new Email" forState:UIControlStateNormal];
                [cell.addButton addTarget:self action:@selector(addEmail) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            } else {
                EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                [cell setupCell:_emailsList[indexPath.row-1] info:@""];
                [cell setTitleBold:NO];
                return cell;
            }
        }
        case 3:
        {
            if (indexPath.row == 0) {
                EVSettingsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsSwitchTableViewCell" forIndexPath:indexPath];
                [cell setupCell:@"By SMS"];
                return cell;
            }  else if (indexPath.row == _phoneNumbersList.count + 1) {
                EVSettingsButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"EVSettingsButtonTableViewCell" forIndexPath:indexPath];
                [cell.addButton setTitle:@"Add new Phone Number" forState:UIControlStateNormal];
                [cell.addButton addTarget:self action:@selector(addPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            } else {
                EVSettingsStandartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EVSettingsStandartTableViewCell" forIndexPath:indexPath];
                [cell setupCell:_phoneNumbersList[indexPath.row-1] info:@""];
                [cell setTitleBold:NO];
                return cell;
            }
        }
        default: return nil;
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

- (void)addContact:(NSInteger)contactType {
    NSString *title = contactType == 2 ? @"Enter email adress" : @"Enter phone number";
    NSMutableArray *array = contactType == 2 ? _emailsList : _phoneNumbersList;
    UIAlertController * alert = [UIAlertController  alertControllerWithTitle: title
                                                                     message: @""
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    UIAlertAction* save = [UIAlertAction      actionWithTitle:@"Save"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          NSArray * textfields = alert.textFields;
                                                          UITextField * textfield = textfields[0];
                                                          if (![textfield.text  isEqual: @""]) {
                                                              [array addObject:textfield.text];
//                                                              [_tableView reloadSections:[NSIndexSet indexSetWithIndex:contactType] withRowAnimation:UITableViewRowAnimationNone];
                                                              [self.tableView reloadData];
                                                          }
                                                      }];
    UIAlertAction* cancel = [UIAlertAction  actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action) {
                                                    }];
    [alert addAction:save];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)addEmail {
    [self addContact:email];
}
-(void)addPhoneNumber {
    [self addContact:phone];
}

typedef enum {
    email = 2,
    phone = 3,
} Contacts;

@end
