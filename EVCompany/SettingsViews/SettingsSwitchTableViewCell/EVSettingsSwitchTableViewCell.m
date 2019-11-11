//
//  EVSettingsSwitchTableViewCell.m
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVSettingsSwitchTableViewCell.h"

@interface EVSettingsSwitchTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation EVSettingsSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupCell:(NSString *)info {
    self.titleLabel.text = info;
}

- (void)setupCell:(NSString *)info state:(BOOL)state {
    self.titleLabel.text = info;
    [self.cellSwitch setOn:state];
}

@end
