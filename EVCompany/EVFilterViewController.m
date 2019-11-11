//
//  EVFilterViewController.m
//  EVCompany
//
//  Created by Srishti on 25/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVFilterViewController.h"
#import "ECSlidingViewController.h"
#import "EVAppDelegate.h"
#import "Filter.h"
#import "EVModal.h"

@interface EVFilterViewController (){
    NSManagedObjectContext *managedObjectContext;
    EVModal *modal;
}
@property(nonatomic,strong)IBOutlet UISwitch *switchChargingLevel1;
@property(nonatomic,strong)IBOutlet UISwitch *switchChargingLevel2;
@property(nonatomic,strong)IBOutlet UISwitch *switchChargingLevel3;

@property(nonatomic,strong)IBOutlet UISwitch *switchUsagePublic;
@property(nonatomic,strong)IBOutlet UISwitch *switchUsageUnknown;
@property(nonatomic,strong)IBOutlet UISwitch *switchUsagePrivateForStaffandVisitors;
@property(nonatomic,strong)IBOutlet UISwitch *switchUsagePrivateRestrictedAccess;
@property(nonatomic,strong)IBOutlet UISwitch *switchUsagePrivatelyOwnedNoticeRequired;
@property(nonatomic,strong)IBOutlet UISwitch *switchUsagePublicMembershipRequired;
@property(nonatomic,strong)IBOutlet UISwitch *switchUsagePublicNoticRequired;
@property(nonatomic,strong)IBOutlet UISwitch *switchUsagePublicPayAtLocation;





@end

@implementation EVFilterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"--------------EVFilterViewController--------------");
    [super viewDidLoad];
    [self fetchDataFromCoreData];
    self.navigationItem.title = kNAV_TITLE;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fetchDataFromCoreData{
    [modal show:@"Loading..."];
    
    Filter *filter;
    managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Filter" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        filter=results[0];
    }
    NSArray *arrayLevel = [filter.chargingLevel componentsSeparatedByString:@","];
    NSArray *arrayUsage = [filter.usageType componentsSeparatedByString:@","];
    if(arrayLevel.count>0){
        [arrayLevel containsObject:@"1"]?[_switchChargingLevel1 setOn:YES]:[_switchChargingLevel1 setOn:NO];
        [arrayLevel containsObject:@"2"]?[_switchChargingLevel2 setOn:YES]:[_switchChargingLevel2 setOn:NO];
        [arrayLevel containsObject:@"3"]?[_switchChargingLevel3 setOn:YES]:[_switchChargingLevel3 setOn:NO];
        }
    if(arrayUsage.count > 0){
        
        [arrayUsage containsObject:@"0"]?[_switchUsageUnknown setOn:YES]:[_switchUsageUnknown setOn:NO];
        [arrayUsage containsObject:@"1"]?[_switchUsagePublic setOn:YES]:[_switchUsagePublic setOn:NO];
        [arrayUsage containsObject:@"2"]?[_switchUsagePrivateRestrictedAccess setOn:YES]:[_switchUsagePrivateRestrictedAccess setOn:NO];
        [arrayUsage containsObject:@"3"]?[_switchUsagePrivatelyOwnedNoticeRequired setOn:YES]:[_switchUsagePrivatelyOwnedNoticeRequired setOn:NO];
        [arrayUsage containsObject:@"4"]?[_switchUsagePublicMembershipRequired setOn:YES]:[_switchUsagePublicMembershipRequired setOn:NO];
        [arrayUsage containsObject:@"5"]?[_switchUsagePublicPayAtLocation setOn:YES]:[_switchUsagePublicPayAtLocation setOn:NO];
        [arrayUsage containsObject:@"6"]?[_switchUsagePrivateForStaffandVisitors setOn:YES]:[_switchUsagePrivateForStaffandVisitors setOn:NO];
        [arrayUsage containsObject:@"7"]?[_switchUsagePublicNoticRequired setOn:YES]:[_switchUsagePublicNoticRequired setOn:NO];
        
    }
    [modal hide];
}
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}
-(IBAction)saveFilterSettings:(id)sender{
    [modal show:@"Saving..."];
    Filter *filter;
    managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Filter" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        filter=results[0];
    }
    else
    {
        filter = [NSEntityDescription insertNewObjectForEntityForName:@"Filter"
                                                  inManagedObjectContext:managedObjectContext];
    }
    NSMutableArray *arrayLevel=[[NSMutableArray alloc]init];
    _switchChargingLevel1.on?[arrayLevel addObject:@"1"]:nil;
    _switchChargingLevel2.on?[arrayLevel addObject:@"2"]:nil;
    _switchChargingLevel3.on?[arrayLevel addObject:@"3"]:nil;
    filter.chargingLevel = [arrayLevel componentsJoinedByString:@","];
    NSMutableArray *arrayUsage=[[NSMutableArray alloc]init];
    _switchUsageUnknown.on?[arrayUsage addObject:@"0"]:nil;
    _switchUsagePublic.on?[arrayUsage addObject:@"1"]:nil;
    _switchUsagePrivateRestrictedAccess.on?[arrayUsage addObject:@"2"]:nil;
    _switchUsagePrivatelyOwnedNoticeRequired.on?[arrayUsage addObject:@"3"]:nil;
    _switchUsagePublicMembershipRequired.on?[arrayUsage addObject:@"4"]:nil;
    _switchUsagePublicPayAtLocation.on?[arrayUsage addObject:@"5"]:nil;
    _switchUsagePrivateForStaffandVisitors.on?[arrayUsage addObject:@"6"]:nil;
    _switchUsagePublicNoticRequired.on?[arrayUsage addObject:@"7"]:nil;
    
    filter.usageType = [arrayUsage componentsJoinedByString:@","];
    
    
    if (![managedObjectContext save:&error]) {
    }
    [modal hide];
}
@end
