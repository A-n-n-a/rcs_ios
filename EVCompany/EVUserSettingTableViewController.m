//
//  EVUserSettingTableViewController.m
//  EVCompany
//
//  Created by GridScape on 9/7/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVUserSettingTableViewController.h"
#import "EVSlidingViewController.h"
#import "EVUser.h"
#import "UserSetting.h"
#import "EVAppDelegate.h"
#import "EVLogViewController.h"
#import "EVTripToStationRouteViewController.h"
#import "EVModal.h"

@interface EVUserSettingTableViewController (){
    EVAppDelegate *deleg;
    NSManagedObjectContext *managedObjectContext;
    EVModal *modal;
    
    UIPickerView *Picker ;
    UIPickerView *pickerView;
    UIToolbar *mypickerToolbar;
    
    NSArray *TimeArray;
    NSArray *BeforeMilesArray;
    NSArray *NearbyMilesArray;
    
    NSString *currentTF;
    NSString *notifyTimeStr;
    NSString *notifyDistStr;
    NSString *nearByDistStr;
    NSString *notificatinStr;
    
    NSInteger intervalIndex;
}

@property (nonatomic,strong)IBOutlet UIButton *buttonSave;
@property (nonatomic,strong)IBOutlet UIButton *buttonCancel;
@property (nonatomic,strong)IBOutlet UITextField *notificationTime;
@property (nonatomic,strong)IBOutlet UITextField *notificationDistance;
@property (nonatomic,strong)IBOutlet UITextField *nearByDistance;
@property (nonatomic,strong)IBOutlet UISwitch *notificationSwitch;

@end

@implementation EVUserSettingTableViewController
@synthesize notificationSwitch;
@synthesize notificationTime,notificationDistance,nearByDistance;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"--------------EVUserSettingTableViewController--------------");
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

    self.navigationItem.title = kNAV_TITLE;
    intervalIndex = 0;
    [self fetchDataFromCoreData];
    deleg = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
    [self initializeUI];
    notificationTime.delegate = self;
    notificationDistance.delegate = self;
    nearByDistance.delegate = self;
    currentTF = [[NSString alloc] init];
}

- (void)initializeUI
{
    _buttonSave.layer.cornerRadius = 5.0;
    _buttonCancel.layer.cornerRadius = 5.0;
}

-(void)setPickerViewByTextField:(UITextField *)textField
{
    pickerView = [[UIPickerView alloc] init];
    [pickerView setDataSource: self];
    [pickerView setDelegate: self];
    [pickerView setFrame: CGRectZero];
    pickerView.showsSelectionIndicator = YES;
    [pickerView selectRow:0 inComponent:0 animated:YES];
    
    textField.inputView = pickerView;
  
    if (textField.tag == 1) {
        TimeArray = [NSArray arrayWithObjects:@"5",@"10",@"15",@"20",@"25",@"30", nil];
    }else if(textField.tag == 2){
        TimeArray = [NSArray arrayWithObjects:@"5",@"10",@"15",@"20",@"25",@"30", nil];
    }else if(textField.tag == 3){
        TimeArray = [NSArray arrayWithObjects:@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100", nil];
    }
    [pickerView reloadAllComponents];
    
    // add a toolbar with Cancel & Done button
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    [toolBar sizeToFit];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    
    textField.inputAccessoryView = toolBar;
}

-(void)fetchDataFromCoreData{
    [modal show:@"Loading..."];
    UserSetting *userSetting;
    managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserSetting" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        userSetting=results[0];
    }
    
    notifyTimeStr = userSetting.notifyBeforeTime;
    notifyDistStr = userSetting.notifyBeforeDistance;
    nearByDistStr = userSetting.searchNearbyDistance;
    notificatinStr = userSetting.notificationStr;

    if(notifyTimeStr.length>0){
        notificationTime.text = notifyTimeStr;
    }else{
        notificationTime.text = @"5";
    }
    if(notifyDistStr.length>0){
        notificationDistance.text = notifyDistStr;
    }else{
        notificationDistance.text = @"5";
    }
    
    if(nearByDistStr.length>0){
        nearByDistance.text = nearByDistStr;
    }else{
        nearByDistance.text = @"10";
    }
    
    if([notificatinStr isEqualToString:@"OFF"]){
        [notificationSwitch setOn:NO];
        deleg.OnOffFlag =@"OFF";
    }else{
        [notificationSwitch setOn:YES];
        deleg.OnOffFlag =@"ON";
    }
    
    [modal hide];
}

-(IBAction)saveButtonClick:(id)sender{
    [modal show:@"Saving..."];
    UserSetting *userSetting;
    managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserSetting" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        userSetting=results[0];
    }
    else
    {
        userSetting = [NSEntityDescription insertNewObjectForEntityForName:@"UserSetting"
                                               inManagedObjectContext:managedObjectContext];
    }
    
    userSetting.notifyBeforeDistance = [notificationDistance.text isEqualToString:@""]?@"5":notificationDistance.text ;
    userSetting.notifyBeforeTime = [notificationTime.text isEqualToString:@""]?@"5":notificationTime.text ;
    userSetting.searchNearbyDistance = [nearByDistance.text isEqualToString:@""]?@"10":nearByDistance.text ;
    if([notificatinStr isEqualToString:@"OFF"]){
        userSetting.notificationStr = @"OFF";
    }else{
        userSetting.notificationStr = @"ON";
    }
    
    if (![managedObjectContext save:&error]) {
    }
    [modal hide];
    deleg.delegNotifyDistStr = notificationDistance.text;
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 1)
    {
        currentTF=@"notificationTime";
        [self setPickerViewByTextField:textField];
    }
    else if (textField.tag == 2)
    {
        currentTF=@"notificationDistance";
        [self setPickerViewByTextField:textField];
    }
    else if (textField.tag == 3)
    {
        currentTF=@"nearByDistance";
        [self setPickerViewByTextField:textField];
    }
}

- (IBAction)someButtonTouched:(UIButton *)sender
{
    [self.notificationTime becomeFirstResponder];
}

- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    if ([currentTF isEqualToString:@"notificationTime"]){
        [self.notificationTime resignFirstResponder];
    }else if ([currentTF isEqualToString:@"notificationDistance"]){
        [self.notificationDistance resignFirstResponder];
    }else if ([currentTF isEqualToString:@"nearByDistance"]){
        [self.nearByDistance resignFirstResponder];
    }
}

- (void)doneTouched:(UIBarButtonItem *)sender{
    // hide the picker view
    if ([currentTF isEqualToString:@"notificationTime"]){
        notificationTime.text= [TimeArray objectAtIndex:intervalIndex];
        [self.notificationTime resignFirstResponder];
    }else if ([currentTF isEqualToString:@"notificationDistance"]){
        notificationDistance.text= [TimeArray objectAtIndex:intervalIndex];
        [self.notificationDistance resignFirstResponder];
    }else if ([currentTF isEqualToString:@"nearByDistance"]){
        nearByDistance.text= [TimeArray objectAtIndex:intervalIndex];
        [self.nearByDistance resignFirstResponder];
    }
    
    [Picker selectRow:0 inComponent:0 animated:YES];
    intervalIndex=0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [TimeArray count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *item = [TimeArray objectAtIndex:row];
    return item;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    intervalIndex = row;
 /*   if ([currentTF isEqualToString:@"notificationTime"]){
        notificationTime.text= [TimeArray objectAtIndex:row];
    }else if ([currentTF isEqualToString:@"notificationDistance"]){
        notificationDistance.text= [TimeArray objectAtIndex:row];
    }else if ([currentTF isEqualToString:@"nearByDistance"]){
        nearByDistance.text= [TimeArray objectAtIndex:row];
    } */
}


- (IBAction)changeSwitch:(id)sender{
    if([sender isOn]){
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
        notificatinStr = @"ON";
        deleg.OnOffFlag = @"ON";
    } else{
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        notificatinStr = @"OFF";
        deleg.OnOffFlag = @"OFF";
    }
}

/*for sending nslog to file*/
- (IBAction)logPressed:(id)sender{
    EVLogViewController *evTripRoughtViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"logView"];
    [self.navigationController pushViewController:evTripRoughtViewcontroller animated:YES];
}
/*for sending nslog to file*/

- (IBAction)TestClicked:(id)sender{
     EVTripToStationRouteViewController *testview = [self.storyboard instantiateViewControllerWithIdentifier:@"tripToStationView"];
    [self.navigationController pushViewController:testview animated:YES];
}

@end
