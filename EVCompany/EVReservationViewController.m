//
//  EVReservationViewController.m
//  EVCompany
//
//  Created by GridScape on 9/23/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVReservationViewController.h"
#import "EVOCPPClientApi.h"
#import "EVStations.h"
#import "config.h"
#import "EVUser.h"
#import "EVAppDelegate.h"
#import "UserSetting.h"
#import "EVModal.h"

@interface EVReservationViewController (){
    EVAppDelegate *appDelegate;
    UIPickerView  *intervalPicker;
    UIToolbar     *mypickerToolbar;
    NSDate        *notificationDate;
    NSInteger     intervalIndex;
    NSString      *dateString;
    NSArray       *arrayInterval;
    NSManagedObjectContext *managedObjectContext;
    UserSetting *userSetting;
    EVModal       *modal;
}

@property (nonatomic,strong)IBOutlet UILabel *labelDesc;
@property (nonatomic,strong)IBOutlet UILabel *labelStatus;
@property (nonatomic,strong)IBOutlet UILabel *labelSiteName;
@property (nonatomic,strong)IBOutlet UILabel *labelConnectorNo;
@property (nonatomic,strong)IBOutlet UITextField *textFieldStartTime;
@property (nonatomic,strong)IBOutlet UITextField *textFieldInterval;
@property (nonatomic,strong)IBOutlet UIButton *buttonReserve;
@property (nonatomic,retain)IBOutlet UIDatePicker *datePicker;

@end

@implementation EVReservationViewController
@synthesize datePicker,labelSiteName,labelDesc,labelStatus,labelConnectorNo;

- (void)viewDidLoad {
    NSLog(@"--------------EVReservationViewController--------------");
    [super viewDidLoad];
    self.navigationItem.title = kNAV_TITLE;
    [self fetchDataFromCoreData];
    intervalIndex = 0;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateString = [formatter stringFromDate:[NSDate date]];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

    appDelegate = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSLog(@"Device Token : %@",appDelegate.device_token);
    
    labelSiteName.text = _station.title;
    labelDesc.text = _station.chargerId;
    labelStatus.text = _connectorStatus;
    labelConnectorNo.text = self.connectorId;
    [self initializeUI];
    
    arrayInterval = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
    
    intervalPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 43, 320, 480)];
    intervalPicker.delegate = self;
    intervalPicker.dataSource = self;
    [intervalPicker selectRow:0 inComponent:0 animated:YES];
    [intervalPicker  setShowsSelectionIndicator:YES];
    _textFieldInterval.inputView =  intervalPicker  ;
    
    // Create done button in UIPickerView
    mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    mypickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [mypickerToolbar sizeToFit];
    
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(intervalPickerDoneClicked)];
    [barItems addObject:doneBtn];
    
    [mypickerToolbar setItems:barItems animated:YES];
    _textFieldInterval.inputAccessoryView = mypickerToolbar;
}

-(void)fetchDataFromCoreData{
    managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserSetting" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        userSetting=results[0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)intervalPickerDoneClicked{
    _textFieldInterval.text = [NSString stringWithFormat:@"%@ hours",[arrayInterval objectAtIndex:intervalIndex]];
    [_textFieldInterval resignFirstResponder];
}

- (void)initializeUI
{
    _buttonReserve.layer.cornerRadius = 5.0;
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    _textFieldStartTime.inputView =  datePicker;
    UIToolbar*  pickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    pickerToolBar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolBar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    [barItems addObject:doneBtn];
    [pickerToolBar setItems:barItems animated:YES];
    _textFieldStartTime.inputAccessoryView = pickerToolBar;
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
}

-(void)pickerDoneClicked{
    self.textFieldStartTime.text = [NSString stringWithFormat:@"%@",dateString];
    [_textFieldStartTime resignFirstResponder];
}

-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.textFieldStartTime.inputView;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateString = [formatter stringFromDate:picker.date];
    
}

- (IBAction)callReservationService:(id)sender {
    if ([_textFieldStartTime.text isEqualToString:@""] || [_textFieldInterval.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please enter all fields" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }else if([_connectorStatus isEqualToString:@"Occupied"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Charger is currently occupied. Please try to reserve when it is available." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        _textFieldStartTime.text = @"";
        _textFieldInterval.text = @"";
    }else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *currentDate = [NSDate date];
        
        NSDate *startDate = [dateFormat dateFromString:self.textFieldStartTime.text];
        notificationDate = startDate;
        NSTimeInterval timeInMiliseconds = [startDate timeIntervalSince1970]*1000;
        double startTime = timeInMiliseconds;
        NSString *rpString = [_textFieldInterval.text stringByReplacingOccurrencesOfString:@"hours" withString:@""];
        int interval = (int)[rpString integerValue];
        NSTimeInterval secondsInHours2 = interval * 60 * 60;
        
        NSDate *endDate = [startDate dateByAddingTimeInterval:secondsInHours2];
        NSTimeInterval timeInMilliseconds2 = [endDate timeIntervalSince1970]*1000;
        double endTime = timeInMilliseconds2;
        if([startDate compare:currentDate] == NSOrderedAscending){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Start time cannot be less than current time." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [alert show];
            _textFieldStartTime.text = @"";
            _textFieldInterval.text = @"";
        }else{
            if (([startDate compare: endDate] == NSOrderedDescending) || ([startDate compare:endDate] == NSOrderedSame)) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"End Date should be greater than start Date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                
                [alert show];
                _textFieldStartTime.text = @"";
                _textFieldInterval.text = @"";
            }else{
                [modal show:@"Reserving..."];
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setValue:_station.chargerId forKey:@"ocppChargeboxIdentity"];
                [dict setValue:self.connectorId forKey:@"connectorId"];
                [dict setValue:[EVUser currentUser].tagId forKey:@"tagId"];
                [dict setValue:[NSString stringWithFormat:@"%1.0f", startTime] forKey:@"startDate"];
                [dict setValue:[NSString stringWithFormat:@"%1.0f", endTime] forKey:@"expiryDate"];
                [dict setValue:@"iphone" forKey:@"deviceFlag"];
                if (appDelegate.device_token == nil) {
                    [dict setValue:@"" forKey:@"deviceToken"];
                }else{
                    [dict setValue:appDelegate.device_token forKey:@"deviceToken"];
                }
                if (userSetting.notifyBeforeTime == nil) {
                    [dict setValue:@"5" forKey:@"notificationMinute"];
                }
                else{
                    [dict setValue:userSetting.notifyBeforeTime forKey:@"notificationMinute"];
                }
                NSLog(@"Reservation Service Parameter Data : %@",dict);
                
                [[EVOCPPClientApi sharedOcppClient] getReservationWithParameters:dict Success:^(id result) {
                    NSLog(@"Reservation Service Responce Data : %@",result);
                    [modal hide];
                    if ([result[@"status"] isEqualToString:@"true"]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Charger reserved!" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        [alert addAction:okAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }else{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:result[@"error"] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                        [alert addAction:okAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                } Failure:^(NSError *error) {
                    [modal show:@"Failed" for:1.5];
                    NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
                }];
            }
        }
    }
}

- (IBAction)addReservationNotification{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *StrBeforeTime;
    if (userSetting.notifyBeforeTime == nil) {
        StrBeforeTime = @"5";
    }else{
        StrBeforeTime = userSetting.notifyBeforeTime;
    }
    int interval = (int)[StrBeforeTime integerValue];
    NSDate *notificationfinaldate = [notificationDate dateByAddingTimeInterval:-(interval*60)];
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = notificationfinaldate;
    localNotification.alertBody = @"Reservation Notification";
    localNotification.alertAction = @"Show station details.";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrayInterval count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [arrayInterval objectAtIndex:row];
}


- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    intervalIndex = row;
}

@end
