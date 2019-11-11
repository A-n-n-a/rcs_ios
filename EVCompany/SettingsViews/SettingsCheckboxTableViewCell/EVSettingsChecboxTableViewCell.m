//
//  EVSettingsChecboxTableViewCell.m
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVSettingsChecboxTableViewCell.h"

@interface EVSettingsChecboxTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation EVSettingsChecboxTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupCell:(NSString *)info checked:(BOOL)checked {
    self.titleLabel.text = info;
    [self setChecked:checked];
}

- (void)setChecked:(BOOL)value {
    [self.checkBoxImageView setHidden:!value];
}


@end
