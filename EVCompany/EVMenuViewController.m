//
//  EVMenuViewController.m
//  EVCompany
//
//  Created by Srishti on 18/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVMenuViewController.h"
#import "EVSlidingViewController.h"
#import "EVUser.h"
#import "EVLikeViewController.h"
#import <MessageUI/MessageUI.h>


@interface EVMenuViewController ()<MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *sectionItems;
@property (nonatomic, strong) NSArray *rowItems;

@end

@implementation EVMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat statusBarHeight = 20;
    
    CGRect menuFrame = screen;
    menuFrame.origin.y = statusBarHeight;
    menuFrame.size.height = screen.size.height - statusBarHeight;
    self.view.frame = menuFrame;
}

- (void)viewDidLoad
{
    NSLog(@"--------------EVMenuViewController--------------");
    [super viewDidLoad];
    [[UINavigationBar appearance] setTintColor:[UIColor clearColor]];
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    if([[EVUser currentUser]userId]){
        self.sectionItems = [NSArray arrayWithObjects:@"Actions",@"Account",@"Find Stations",@"Stay In Touch",nil];
        self.rowItems = [NSArray arrayWithObjects:@[@"Add Stations",@"Trip Planner", @"Add Charger"],@[@"Profile",@"Vehicle",@"Notification Settings ",@"Logout"],@[@"Map",@"Nearby EV Stations",@"Filters",@"Favorites"],@[@"Feedback/Report an Issue",@"Like Us on Facebook",@"Like Us on Twitter",@"Like Us on Google+"],nil];
        self.menuItems = [NSArray arrayWithObjects:@[@"addNavigation",@"tripplanNavigation", @"addCharger"],@[@"profilenavigation",@"addvehicleNavigation",@"userSettingNavigation",@"logout"],@[@"navigationController",@"stationlistNavigation",@"filterNavigationController",@"favoriteNavigation"],@[@"Feedback/Report an Issue",@"likeViewController",@"likeViewController",@"likeViewController"], nil];
    } else{
        self.sectionItems = [NSArray arrayWithObjects:@"Account",@"Find Stations",@"Stay In Touch", nil];
        self.rowItems = [NSArray arrayWithObjects:@[@"Sign Up",@"Log In",@"Trip Planner"],@[@"Map",@"Nearby EV Stations",@"Filters"],@[@"Feedback/Report an Issue",@"Like Us on Facebook",@"Like Us on Twitter",@"Like Us on Google+"], nil];
        self.menuItems = [NSArray arrayWithObjects:@[@"signupNavigation",@"loginNavigation",@"tripplanNavigation"],@[@"navigationController",@"stationlistNavigation",@"filterNavigationController"],@[@"Feedback/Report an Issue",@"likeViewController",@"likeViewController",@"likeViewController"],  nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.sectionItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *array = self.rowItems[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"CellMessege";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSArray *array = self.rowItems[indexPath.section];
    cell.textLabel.text = array[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:175.0/255.0 blue:62.0/255.0 alpha:1.0];
    return cell;
}




- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    headerView.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:175.0/255.0 blue:62.0/255.0 alpha:1.0];
    UILabel *labelTitle = [[UILabel alloc]init];
    labelTitle.frame = CGRectMake(5,20,150,30);
    labelTitle.text = self.sectionItems[section];
    labelTitle.font = [UIFont systemFontOfSize:12];
    labelTitle.textColor = [UIColor whiteColor];
    [headerView addSubview:labelTitle];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell != nil) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:0.31 green:0.73 blue:0.36 alpha:1];
        [cell setSelectedBackgroundView:bgColorView];
        
    }
    
     NSArray *array = self.menuItems[indexPath.section];
    NSString *identifier = [NSString stringWithFormat:@"%@", [array objectAtIndex:indexPath.row]];
    if([identifier isEqualToString:@"logout"]){
        identifier = @"navigationController";
        [EVUser userWithDetails:nil];
        [self loadNewTop:identifier];
    }else if([identifier isEqualToString:@"likeViewController"]){
        EVLikeViewController *evlikeViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        if([_rowItems[indexPath.section][indexPath.row] isEqualToString:@"Like Us on Facebook"])
            [evlikeViewController setUrl:@"https://www.facebook.com/revtializechargingsolutions"];
        else if ([_rowItems[indexPath.section][indexPath.row] isEqualToString:@"Like Us on Twitter"])
            [evlikeViewController setUrl:@"https://twitter.com/RevitalizeCS"];
        else
            [evlikeViewController setUrl:@"https://plus.google.com/u/0/b/115453733114778512611/115453733114778512611"];
            
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = evlikeViewController;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
        }];
    }else if([identifier isEqualToString:@"Feedback/Report an Issue"]){
        [self SendFeedBack];
        
    }else if([identifier isEqualToString:@"tripplanNavigation"] || [identifier isEqualToString:@"addCharger"]){
        if([[EVUser currentUser]userId]){
            [self loadNewTop:identifier];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please login to access Trip Plan feature." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: Nil, nil];
            
            [alert show];
        }
    }else if([identifier isEqualToString:@"stationNavigation"]){
        if([[EVUser currentUser]userId]){
            [self loadNewTop:identifier];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please login to access Trip Plan feature." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: Nil, nil];
            
            [alert show];
        }
    }else{
        [self loadNewTop:identifier];
    }
    
}
#pragma mark mailcomposer delegates

-(void)SendFeedBack
{
   // [[UINavigationBar appearance] setBarTintColor:[UIColor blueColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:42.0f/255.0f
                                                                  green:175.0f/255.0f
                                                                   blue:61.0f/255.0f
                                                                  alpha:1.0f]];
    MFMailComposeViewController *mailComposer=[[MFMailComposeViewController alloc]init];
    
    mailComposer.mailComposeDelegate=self;
    
    
    if ([MFMailComposeViewController canSendMail]) {
        
        [mailComposer setToRecipients:[NSArray arrayWithObject:@"info@revitalizechargingsolutions.com"]];
        
        [mailComposer setSubject:@"Feedback/Report an Issue"];
        NSString *messageBody = @"";
        [mailComposer setMessageBody:messageBody isHTML:NO];
        [self presentViewController:mailComposer animated:YES completion:nil];
        
    }
    
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            [[[UIAlertView alloc]initWithTitle:@"Feedback sent" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
   [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)mailComposeControllerDidCancel: (MFMailComposeViewController *)controller

{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
    
}

-(void)loadNewTop:(NSString *)identifier{
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[[UINavigationBar appearance] setTintColor:[UIColor clearColor]];
}


@end
