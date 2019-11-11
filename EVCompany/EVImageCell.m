//
//  EVImageCell.m
//  EVCompany
//
//  Created by Srishti on 05/04/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVImageCell.h"

@implementation EVImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        // Initialization code
        self.labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 7, 150, 30)];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:14];
        self.addedImage = [[UIImageView alloc]initWithFrame:CGRectMake(280, 5, 30, 30)];
        [self.contentView addSubview:self.addedImage];
        [self.contentView addSubview:_labelTitle];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
