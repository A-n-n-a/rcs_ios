//
//  TMDropDown.h
//
//  Created by Thahir on 17/01/13.
//  Copyright (c) 2013 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sendBtnTitleDelegate <NSObject>

-(void)sendTitle:(NSString *)stringButtonTitle withIndex :(NSUInteger)index;

@end
@interface TMDropDown : UIView <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *buttonSender;
@property(nonatomic, retain) NSArray *arrayList;
@property (nonatomic, retain) id <sendBtnTitleDelegate> btnTitleDelegate;
- (id)initWithDropDownForButton:(UIButton *)button withHeight:(CGFloat *)height withArray:(NSArray *)array;
- (void)hideDropDownForButton:(UIButton *)button;

@end
