//
//  ButtonCell.h
//  TutorialApp
//
//  Created by Bala on 31/03/14..
//  Copyright (c) 2014 bala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonCell : UITableViewCell
@property (nonatomic,strong) UIButton *leftButton;
@property (nonatomic,strong) UIButton *rightButton;
- (id)initWithTitles:(NSArray*)titles;
- (id)initWithsubmitButton:(NSString*)title ;
@end
