//
//  EVSettingsStandartTableViewCell.m
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVSettingsStandartTableViewCell.h"

@interface EVSettingsStandartTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation EVSettingsStandartTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupCell:(NSString *)description info:(NSString *)info {
    self.descriptionLabel.text = description;
    self.infoLabel.text = info;
}

- (void)setTitleBold:(BOOL)value {
    if (value) {
        self.descriptionLabel.font = [UIFont boldSystemFontOfSize:17.f];
    } else {
        self.descriptionLabel.font = [UIFont systemFontOfSize:17.f];
    }
}

- (void)setInfoBold:(BOOL)value {
    if (value) {
        self.infoLabel.font = [UIFont boldSystemFontOfSize:17.f];
    } else {
        self.infoLabel.font = [UIFont systemFontOfSize:17.f];
    }
}


@end
