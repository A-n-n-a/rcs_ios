//
//  EVSettingsChecboxTableViewCell.h
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVSettingsChecboxTableViewCell : UITableViewCell

- (void)setupCell:(NSString *)info checked:(BOOL)checked;
- (void)setChecked:(BOOL)value;

@end
