//
//  ButtonCell.m
//  TutorialApp
//
//  Created by Bala on 31/03/14..
//  Copyright (c) 2014 bala. All rights reserved.
//

#import "ButtonCell.h"

@implementation ButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        

    }
    return self;
}
- (id)initWithTitles:(NSArray*)titles{
    self = [super init];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
                NSArray *buttons = @[@"leftButton",@"rightButton"];
        for (int i = 0; i < titles.count; i++) {
            UIButton *button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [button setFrame:CGRectMake(10+(i*160), 3, 135, 38)];
             button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [self.contentView addSubview:button];
            [self setValue:button forKey:buttons[i]];

        }
        self.leftButton.frame = titles.count == 1?CGRectMake(10, 3, 300, 38):self.leftButton.frame;
    }
    return self;
}

- (id)initWithsubmitButton:(NSString*)title {
    self = [super init];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
        UIButton *button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:title forState:UIControlStateNormal];
        [button setFrame:CGRectMake(80, 3, 135, 38)];
        button.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:button];
        [self setValue:button forKey:@"leftButton"];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
