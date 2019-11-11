//
//  EVSystemInformationViewController.m
//  EVCompany
//
//  Created by Anna on 12/15/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSystemInformationViewController.h"
#import "ConstantStrings.h"
#import "EVSettingsTextWithImageTableViewCell.h"

@interface EVSystemInformationViewController ()  <UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *_titlesList;
    NSArray *_actions;
    CGFloat _cellHeight;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation EVSystemInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBar:backArrow title:systemInformation rightIconName:NULL selector:NULL rightButtonTitle: NULL];
    [self.tableView registerNib:[UINib nibWithNibName:@"EVSettingsTextWithImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"EVSettingsTextWithImageTableViewCell"];
    _titlesList = [NSMutableArray arrayWithObjects: @"Charger MAC Address", @"Serial Number", @"Firmware Version", nil];
    _actions = [NSArray arrayWithObjects:  @"showMacAdress", @"showSerialNumber", @"showFirmwareVersion", nil];
    _cellHeight = 70;
    _tableView.backgroundColor = UIColor.whiteColor;
    _tableView.separatorColor = UIColor.whiteColor;
}

-(void)showAlert:(NSInteger)infoType {
    NSString *title = [[NSString alloc] init];
    title = _titlesList[infoType];
    UIAlertController * alert = [UIAlertController  alertControllerWithTitle: title
                                                                     message: @""
                                                              preferredStyle:UIAlertControllerStyleAlert];
    self.activeAlert = alert;
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   
                                               }];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}
    
-(void)showMacAdress {
    [self showAlert: mac];
}
-(void)showSerialNumber {
    [self showAlert:serial];
}
-(void)showFirmwareVersion {
    [self showAlert:firmware];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return _cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EVSettingsTextWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EVSettingsTextWithImageTableViewCell" forIndexPath:indexPath];
    [cell setupCell:_titlesList[indexPath.section]];
    SEL action = NSSelectorFromString(_actions[indexPath.section]);
//    [cell.showButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
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
        cell.layer.masksToBounds = YES;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

typedef enum {
    mac = 0,
    serial = 1,
    firmware = 2,
} Information;

@end

