//
//  EVMapTableViewCell.m
//  EVCompany
//
//  Created by Srishti on 12/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVMapTableViewCell.h"

@implementation EVMapTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 250, 30)];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:14];
        self.labelTitle.numberOfLines = 2;
        self.labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.labelAddress  = [[UILabel alloc]initWithFrame:CGRectMake(20, 48, 250, 30)];
        self.labelAddress.font = [UIFont boldSystemFontOfSize:12];
        self.labelAddress.textColor = [UIColor grayColor];
        self.labelAddress.numberOfLines = 3;
        self.labelAddress.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.labelDistance  = [[UILabel alloc]initWithFrame:CGRectMake(200, 0, 150, 30)];
        self.labelDistance.font = [UIFont systemFontOfSize:15];
        self.labelDistance.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_labelAddress];
        [self.contentView addSubview:_labelDistance];
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
