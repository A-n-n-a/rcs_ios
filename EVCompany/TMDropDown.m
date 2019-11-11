//
//  TMDropDown.m
//
//  Created by Thahir on 17/01/13.
//  Copyright (c) 2013 SICS. All rights reserved.
//

#import "TMDropDown.h"
#import "QuartzCore/QuartzCore.h"

@implementation TMDropDown
@synthesize btnTitleDelegate;
- (id)initWithDropDownForButton:(UIButton *)button withHeight:(CGFloat *)height withArray:(NSArray *)array {
    self.buttonSender = button;
    self = [super init];
    if (self) {
        // Initialization code
        CGRect buttonFrame = button.frame;
        
        self.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y+buttonFrame.size.height, buttonFrame.size.width, 0);
        self.arrayList = [NSArray arrayWithArray:array];
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowOffset = CGSizeMake(-5, 5);
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, buttonFrame.size.width, 0)];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.layer.cornerRadius = 5;
        //self.tableView.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.separatorColor = [UIColor grayColor];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y+buttonFrame.size.height, buttonFrame.size.width, *height);
        self.tableView.frame = CGRectMake(0, 0, buttonFrame.size.width, *height);
        [UIView commitAnimations];
        button.backgroundColor =[UIColor clearColor];
        [button.superview.superview addSubview:self];
        [self addSubview:self.tableView];
    }
    return self;
}
- (void)hideDropDownForButton:(UIButton *)button {
    [button setSelected:NO];
    CGRect buttonFrame = button.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y+buttonFrame.size.height, buttonFrame.size.width, 0);
    self.tableView.frame = CGRectMake(0, 0, buttonFrame.size.width, 0);
    [UIView commitAnimations];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    NSArray *arraydata;
     arraydata = [self.arrayList[0] isKindOfClass:[NSString class]]? self.arrayList: self.arrayList[indexPath.row];
    cell.textLabel.text =[self.arrayList objectAtIndex:indexPath.row];
    UIView * selectionView = [[UIView alloc] init];
    selectionView.backgroundColor = [UIColor grayColor];
    cell.selectedBackgroundView = selectionView;
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDownForButton:self.buttonSender];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
   // [self.buttonSender setTitle:cell.textLabel.text forState:UIControlStateNormal];
    [self.btnTitleDelegate sendTitle:cell.textLabel.text withIndex:indexPath.row];
}

@end
