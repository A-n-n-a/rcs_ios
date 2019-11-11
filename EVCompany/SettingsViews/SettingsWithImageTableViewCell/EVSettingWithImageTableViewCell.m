//
//  EVSettingWithImageTableViewCell.m
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVSettingWithImageTableViewCell.h"

@interface EVSettingWithImageTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation EVSettingWithImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupCell:(NSString *)description info:(NSString *)info {
    self.descriptionLabel.text = description;
    self.infoLabel.text = info;
}

@end
