//
//  UserList.m
//  EVCompany
//
//  Created by Anna on 10/17/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVUserListViewController.h"
#import "EVViewController.h"
#import "ConstantStrings.h"
#import "EVUserCell.h"

@interface EVUserListViewController () <UITableViewDelegate, UITableViewDataSource> {
    
    __weak IBOutlet UITableView *tableView;
    __weak IBOutlet UIButton *addUserButton;
    __weak IBOutlet NSLayoutConstraint *tableViewHeight;
    
    NSMutableArray *_userList;
}
    
    
@end

@implementation EVUserListViewController
    
    
- (void)viewDidLoad{
    
    [super viewDidLoad];
    [super setNavigationBar:backArrow title:pairingTitle rightIconName:NULL selector:NULL rightButtonTitle:NULL];
    _userList = [NSMutableArray arrayWithObjects: @"User Name 01", @"User Name 02", nil];
}
    
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
    
- (IBAction)addUser:(UIButton*)sender {
    [self showCancelAlert:self message:connectUserMessage];
    
}
 
// Table view data source
    
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return _userList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        return 70; // same as button height
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EVUserCell *cell = [tableView dequeueReusableCellWithIdentifier: UserCellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = _userList[indexPath.row];
        return cell;
    }
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        //TODO: action implementation
    }
}
    
-(void)updateViewConstraints {
    [super updateViewConstraints];
    tableViewHeight.constant = _userList.count * 70; //70 - cell height
}
    
@end
