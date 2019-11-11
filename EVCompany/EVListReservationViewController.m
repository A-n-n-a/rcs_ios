//
//  EVListReservationViewController.m
//  EVCompany
//
//  Created by GridScape on 10/20/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVListReservationViewController.h"
#import "EVSlidingViewController.h"
#import "EVOCPPClientApi.h"
#import "EVcurrentReservation.h"
#import "config.h"
#import "EVUser.h"

@interface EVListReservationViewController (){
    NSMutableArray *reservationList;
    NSString *startDateString;
    NSString *endDateString;
}

@property (nonatomic,strong)IBOutlet UILabel *labelStartDate;
@property (nonatomic,strong)IBOutlet UILabel *labelEndDate;
@property (nonatomic,strong)IBOutlet UITextField *textFieldStartTime;
@property (nonatomic,strong)IBOutlet UITextField *textFieldEndTime;
@property (nonatomic,strong)IBOutlet UIButton *buttonShow;
@property (nonatomic,strong)IBOutlet UIButton *buttonCancel;
@property (nonatomic,retain)IBOutlet UIDatePicker *datePicker;

@end

@implementation EVListReservationViewController

- (void)viewDidLoad {
    NSLog(@"--------------EVListReservationViewController--------------");
    [super viewDidLoad];
    self.navigationItem.title = kNAV_TITLE;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    startDateString = [formatter stringFromDate:[NSDate date]];
    endDateString = [formatter stringFromDate:[NSDate date]];
    
    _textFieldStartTime.delegate = self;
    _textFieldEndTime.delegate = self;
    _buttonShow.layer.cornerRadius = 5.0;
    _buttonCancel.layer.cornerRadius = 5.0;
}

- (void)viewWillAppear:(BOOL)animated{
    _textFieldStartTime.text = @"";
    _textFieldEndTime.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)revealMenu:(id)sender{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)showButtonClicked:(id)sender{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    
    NSDate *startDate = [dateFormat dateFromString:self.textFieldStartTime.text];
    NSTimeInterval timeInMiliseconds = [startDate timeIntervalSince1970]*1000;
    double startTime = timeInMiliseconds;
    
    NSDate *endDate = [dateFormat dateFromString:self.textFieldEndTime.text];
    NSTimeInterval timeInMilliseconds2 = [endDate timeIntervalSince1970]*1000;
    double endTime = timeInMilliseconds2;
    if([_textFieldStartTime.text isEqualToString:@""] || [_textFieldEndTime.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Fields cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        
        [alert show];
    }else{
        if (([startDate compare: endDate] == NSOrderedDescending) || ([startDate compare:endDate] == NSOrderedSame)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"End Date should be greater than start Date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
            _textFieldStartTime.text = @"";
            _textFieldEndTime.text = @"";
        }else{
            NSMutableDictionary *dict = [NSMutableDictionary new];
                
            [dict setValue:_station.chargerId forKey:@"ocppChargeboxIdentity"];
            [dict setValue:_connectorId forKey:@"connectorId"];
            [dict setValue:[EVUser currentUser].tagId forKey:@"tagId"];
            [dict setValue:[NSString stringWithFormat:@"%1.0f", startTime] forKey:@"startDate"];
            [dict setValue:[NSString stringWithFormat:@"%1.0f", endTime] forKey:@"expiryDate"];
            NSLog(@"List Reservation Parameter Data = %@",dict);
            
            [[EVOCPPClientApi sharedOcppClient] getReservationListWithParameters:dict Success:^(id result) {
                NSLog(@"List Reservation Responce Data = %@",result);
                if ([result[@"status"] isEqualToString:@"true"]) {
                    
                    reservationList = result[@"reservationList"];
                    
                    EVcurrentReservation *evReserveViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"currentReservation"];
                    [evReserveViewcontroller setCurrentconnectorid:_connectorId];
                    [evReserveViewcontroller setReservationData:reservationList];
                    [evReserveViewcontroller setCurrentstation:_station];
                    [evReserveViewcontroller setCurrentconnctIndex:_connctIndex];
                    [evReserveViewcontroller setCurrentStartTime:[NSString stringWithFormat:@"%1.0f", startTime]];
                    [evReserveViewcontroller setCurrentEndTime:[NSString stringWithFormat:@"%1.0f", endTime]];
                    [self.navigationController pushViewController:evReserveViewcontroller animated:YES];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"There is no reservation." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    _textFieldStartTime.text = @"";
                    _textFieldEndTime.text = @"";
                }
            } Failure:^(NSError *error) {
                NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
            }];
        }
    }
}

- (IBAction)cancelButtonClicked:(id)sender{
    self.textFieldStartTime.text = @"";
    self.textFieldEndTime.text = @"";
}

- (void)reserveButtonPressed{
}

- (void)showDatePicker:(UITextField *)textField
{
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    textField.inputView =  _datePicker;
    UIToolbar*  pickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    pickerToolBar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolBar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked:)];
    doneBtn.tag = textField.tag;
    [barItems addObject:doneBtn];
    [pickerToolBar setItems:barItems animated:YES];
    textField.inputAccessoryView = pickerToolBar;
    [_datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    _datePicker.tag = textField.tag;
}

-(void)pickerDoneClicked: (id) sender{
    UIBarButtonItem *theTextField = (UIBarButtonItem *)sender;
    if (theTextField.tag == 1){
        _textFieldStartTime.text = [NSString stringWithFormat:@"%@",startDateString];
        [_textFieldStartTime resignFirstResponder];
    }else if (theTextField.tag == 2){
        _textFieldEndTime.text = [NSString stringWithFormat:@"%@",endDateString];
        [_textFieldEndTime resignFirstResponder];
    }
}

-(void)updateTextField:(id)sender{
    UIDatePicker *theTextField = (UIDatePicker *)sender;
    if (theTextField.tag == 1){
        UIDatePicker *picker = (UIDatePicker*)self.textFieldStartTime.inputView;
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        startDateString = [formatter stringFromDate:picker.date];
    }else if (theTextField.tag == 2){
        UIDatePicker *picker = (UIDatePicker*)self.textFieldEndTime.inputView;
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        endDateString = [formatter stringFromDate:picker.date];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 1){
        [self showDatePicker:textField];
    }else if (textField.tag == 2){
        [self showDatePicker:textField];
    }
}

@end
