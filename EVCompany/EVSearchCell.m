//
//  EVSearchCell.m
//  EVCompany
//
//  Created by Srishti on 21/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVSearchCell.h"

@implementation EVSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 250, 30)];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:14];
        self.labelTitle.numberOfLines = 2;
        self.labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.labelAddress  = [[UILabel alloc]initWithFrame:CGRectMake(40, 28, 250, 30)];
        self.labelAddress.font = [UIFont boldSystemFontOfSize:12];
        self.labelAddress.textColor = [UIColor grayColor];
        self.labelAddress.numberOfLines = 3;
        self.labelAddress.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.pinView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 24, 37)];
        self.pinView.image = [UIImage imageNamed:@"map_pin.png"];
        
        [self.contentView addSubview:_labelAddress];
        [self.contentView addSubview:_labelTitle];
        [self.contentView addSubview:_pinView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
