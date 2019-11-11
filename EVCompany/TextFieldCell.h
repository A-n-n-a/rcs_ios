//
//  TextFieldCell.h
//  Invite
//
//  Created by Bala on 31/03/14..
//  Copyright (c) 2014 bala. All rights reserved.
//


@interface TextFieldCell : UITableViewCell

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *labelFieldName;
@property (nonatomic,strong) UIButton *leftButton;

- (id)initWithPlaceHolder:(NSString *)title;
- (id)initWithLabel:(NSString *)title withFontSizeOfLabel:(int)fontSize;
- (id)initWithstring:(NSString *)title withFontSizeOfLabel:(int)fontSize withHeight :(CGFloat)height;
@end
