//
//  EVSettingsStandartTableViewCell.h
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVSettingsStandartTableViewCell : UITableViewCell

- (void)setupCell:(NSString *)description info:(NSString *)info;
- (void)setTitleBold:(BOOL)value;
- (void)setInfoBold:(BOOL)value;
@end
