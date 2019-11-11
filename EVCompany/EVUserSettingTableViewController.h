//
//  EVUserSettingTableViewController.h
//  EVCompany
//
//  Created by GridScape on 9/7/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVUserSettingTableViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate>

- (IBAction)changeSwitch:(id)sender;
- (IBAction)logPressed:(id)sender;

@property (nonatomic,strong) IBOutlet UIButton *logbtn;

@end
