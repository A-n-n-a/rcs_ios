//
//  EVSettingsTextWithImageTableViewCell.m
//  EVCompany
//
//  Created by Zins on 12/18/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVSettingsTextWithImageTableViewCell.h"

@interface EVSettingsTextWithImageTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation EVSettingsTextWithImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupCell:(NSString *)info {
    self.infoLabel.text = info;
}
@end
