//
//  EVDetailCell.m
//  EVCompany
//
//  Created by Srishti on 19/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVDetailCell.h"

@implementation EVDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 7, 150, 30)];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:14];
        self.labelTitle.numberOfLines = 2;
        self.labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.labelDetails  = [[UILabel alloc]initWithFrame:CGRectMake(153, -10, 170, 60)];
        self.labelDetails.font = [UIFont boldSystemFontOfSize:14];
        self.labelDetails.textColor = [UIColor grayColor];
        self.labelDetails.numberOfLines = 2;
        self.labelDetails.lineBreakMode = NSLineBreakByWordWrapping;
        
        
        [self.contentView addSubview:_labelDetails];
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
