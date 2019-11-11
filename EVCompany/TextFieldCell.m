//
//  TextFieldCell.m
//  Invite
//
//  Created by Bala on 31/03/14..
//  Copyright (c) 2014 bala. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell

@synthesize textField;

- (id)initWithPlaceHolder:(NSString *)title
{
    self = [super init];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.contentView.bounds.size.width - 20, self.contentView.bounds.size.height)];
        [textField setTag:2];
        [textField setPlaceholder:title];
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
        [self.contentView addSubview:textField];
    }
    return self;
}


- (id)initWithLabel:(NSString *)title withFontSizeOfLabel:(int)fontSize
{
    self = [super init];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, 300, 38)];
        [textField setTag:2];
        [textField setFont:[UIFont systemFontOfSize:15]];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textField setPlaceholder:title];
        [textField setTextAlignment:NSTextAlignmentLeft];
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.contentView addSubview:textField];
    }
    return self;
}
- (id)initWithstring:(NSString *)title withFontSizeOfLabel:(int)fontSize withHeight :(CGFloat)height
{
    self = [super init];
    if (self)
    {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
                _labelFieldName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, height)];
                [_labelFieldName setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin)];
                [_labelFieldName setFont:[UIFont systemFontOfSize:fontSize]];
                [_labelFieldName setNumberOfLines:3];
                [_labelFieldName setBackgroundColor:[UIColor clearColor]];
                [_labelFieldName setHighlightedTextColor:[UIColor whiteColor]];
                [_labelFieldName setText:title];
                [self.contentView addSubview:_labelFieldName];
        
              UIButton *button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
              [button setTitle:@"" forState:UIControlStateNormal];
              [button setFrame:CGRectMake(0, 0, 320, height)];
              button.titleLabel.textAlignment = NSTextAlignmentLeft;
              [self.contentView addSubview:button];
              [self setValue:button forKey:@"leftButton"];
           }
    return self;
}

@end
