//
//  EVSettingsSwitchTableViewCell.h
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVSettingsSwitchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *cellSwitch;

- (void)setupCell:(NSString *)info;
- (void)setupCell:(NSString *)info state:(BOOL)state;
@end
