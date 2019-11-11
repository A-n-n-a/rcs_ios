//
//  EVTripPlanTableViewController.m
//  EVCompany
//
//  Created by GridScape on 9/4/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVTripPlanTableViewController.h"
#import "EVSlidingViewController.h"
#import "EVAppDelegate.h"
#import "GeoCoder.h"
#import "EVUser.h"
#import "EVMapViewController.h"
#import "EVMenuViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "EVDirectionService.h"
#import "EVDirectionClient.h"
#import "EVAddVehicleViewController.h"
#import "EVTripPlanRouteViewController.h"
#import "EVTripToStationRouteViewController.h"
#import "EVModal.h"

@interface EVTripPlanTableViewController (){
    EVAppDelegate     *AppDelegate;
    
    NSString          *estimatedDistance;
    CLLocationManager *locationManager;
    CLGeocoder        *geocoder;
    CLPlacemark       *placemark;
    CLLocation        *destinationDist;
    CLLocation        *sourceDist;
    NSDictionary      *locationDict;
    NSArray           *arrRoutes;
    EVModal           *modal;
    
    double distanceInMiles;
    double BatteryDistance;
}

@property (nonatomic,strong)IBOutlet UISlider *sliderPercentage;
@property (nonatomic,strong)IBOutlet UILabel *labelPercentage;
@property (nonatomic,strong)IBOutlet UILabel *labelEstimatedDist;
@property (nonatomic,strong)IBOutlet UILabel *labelDistanceCount;
@property (nonatomic,strong)IBOutlet UILabel *textFieldMileage;
@property (nonatomic,strong)IBOutlet UITextView *textViewEndPoint;
@property (nonatomic,strong)IBOutlet UITextView *textViewStartPoint;
@property (nonatomic,strong)IBOutlet UIButton *buttonSave;

@end

@implementation EVTripPlanTableViewController

- (void)viewDidLoad {
    NSLog(@"--------------EVTripPlanTableViewController--------------");
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

    self.buttonSave.enabled = NO;
    AppDelegate = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
    AppDelegate.tripTableVC = self;
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    _labelPercentage.text =  [[NSString stringWithFormat:@"%.0f",self.sliderPercentage.value *100] stringByAppendingString:@"%"];
    _textFieldMileage.text = [EVUser currentUser].milesWhenFull;
    
    if ([_textFieldMileage.text isEqualToString:@"0"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please store vehicle details." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView setTag:3];
        [alertView show];
    }
    
    [self fetchStateName];
    [self calculateEstimatedDistance];
//    [self fetchlocationName:@"vadodara"];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    //_textFieldMileage.inputAccessoryView = numberToolbar;
    
   // [[_textViewEndPoint layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
   // [[_textViewEndPoint layer] setBorderWidth:2.3];
    [[_textViewEndPoint layer] setCornerRadius:5];
    [_textViewEndPoint setClipsToBounds: YES];
    [[_textViewStartPoint layer] setCornerRadius:5];
    [_textViewStartPoint setClipsToBounds: YES];

}

-(void)doneWithNumberPad{
    [_textFieldMileage resignFirstResponder];
}

- (IBAction)getCurrentLocation{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
 //       _longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
 //       _latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            _textViewStartPoint.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                  placemark.subThoroughfare, placemark.thoroughfare,
                                  placemark.postalCode, placemark.locality,
                                  placemark.administrativeArea,
                                  placemark.country];
            NSLog(@"Start Address = %@",  _textViewStartPoint.text);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
}

-(void)fetchStateName{
    GeoCoder *reverseGeocoder = [GeoCoder new];
    [reverseGeocoder reverseGeoCode:AppDelegate.currentLocation inBlock:^(NSDictionary *statename) {
        AppDelegate.tripStartLatitude = [NSString stringWithFormat:@"%.8f", AppDelegate.currentLocation.coordinate.latitude];
        AppDelegate.tripStartLatitude = [NSString stringWithFormat:@"%.8f", AppDelegate.currentLocation.coordinate.latitude];
        locationDict = statename;
        NSLog(@"State Name = %@",statename);
        _textViewStartPoint.text = [statename objectForKey:@"address"];
    }];
}

-(IBAction)fetchlocationName:(id)sender{
    GeoCoder *reverseGeocoder = [GeoCoder new];
    [reverseGeocoder geoCodeAddress:_textViewEndPoint.text inBlock:^(CLLocation *location) {
        AppDelegate.TripLatitude = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
        AppDelegate.TripLongitude = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
        destinationDist = location;
        if (![_textViewStartPoint.text isEqualToString:@""]) {
            [self getEstimatedDistance:self];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Starting point should not be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView setTag:5];
            [alertView show];
        }
    }];
}

-(void)fetchlocationName:(NSString *)stopLocation withCompletionBlock:(void (^)(BOOL))completionBlock{
    GeoCoder *reverseGeocoder = [GeoCoder new];
    if (![stopLocation isEqualToString:@""]) {
        [reverseGeocoder geoCodeAddress:stopLocation inBlock:^(CLLocation *location) {
            AppDelegate.TripLatitude = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
            AppDelegate.TripLongitude = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
            destinationDist = location;
        }];
    }
    completionBlock(YES);
}

-(void)fetchlatandlong:(NSString *)sourceLocation withCompletionBlock:(void (^)(BOOL))completionBlock{
    GeoCoder *reverseGeocoder = [GeoCoder new];
    if (![sourceLocation isEqualToString:@""]) {
        [reverseGeocoder geoCodeAddress:_textViewStartPoint.text inBlock:^(CLLocation *location) {
                sourceDist = location;
                completionBlock(YES);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)calculateEstimatedDistance{
    [self fetchlocationName:_textViewEndPoint.text withCompletionBlock:^(BOOL success){
        if (YES) {
            BatteryDistance = ([_labelPercentage.text doubleValue] * [_textFieldMileage.text doubleValue])/100;
            _labelDistanceCount.text = [NSString stringWithFormat:@"%0.2f",BatteryDistance];
        }
    }];
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)sliderValueChanged:(UISlider *)sender{
    _labelPercentage.text =  [[NSString stringWithFormat:@"%.0f",sender.value *100] stringByAppendingString:@"%"];
    BatteryDistance = ([_labelPercentage.text doubleValue] * [_textFieldMileage.text doubleValue])/100;
    _labelDistanceCount.text = [NSString stringWithFormat:@"%0.2f",BatteryDistance];
}

- (IBAction)getEstimatedDistance:(id)sender{
    if (![_textViewEndPoint.text isEqualToString:@""] && ![_textFieldMileage.text isEqualToString:@""]) {
        if(![_textFieldMileage.text isEqualToString:@"0"]){
            //[self calculateEstimatedDistance];
            [self calculateDistanceWithSource:_textViewStartPoint.text withDestination:_textViewEndPoint.text WithCompletionBlock:^(BOOL success, id result, NSError *error){
                if(YES){
                    AppDelegate.tripStartLocation = [locationDict objectForKey:@"address"];
                    NSArray *rowsArray = [result objectForKey:@"rows"];
                    NSArray *elementArray = [[rowsArray objectAtIndex:0] objectForKey:@"elements"];
                    NSArray *distanceArray = [[elementArray objectAtIndex:0] objectForKey:@"distance"];
                    NSString *distanceText = [distanceArray valueForKey:@"text"];
                    
                    NSRange range = [distanceText rangeOfString:@" " options:NSBackwardsSearch];
                    NSLog(@"Range.location : %lu", (unsigned long)range.location);
                    NSString *substring = [distanceText substringFromIndex:range.location+1];
                    NSLog(@"Substring Trip Plan : '%@'", substring);
                    
                    NSString * rpString;
                    //double distanceinml = 0.0;
                    
                    if([substring isEqualToString:@"km"]){
                        rpString = [distanceText stringByReplacingOccurrencesOfString:@"km" withString:@""];
                        NSString *rmcomma = [rpString stringByReplacingOccurrencesOfString:@"," withString:@""];
                        NSLog(@"distanceText = %@",rmcomma);
                        distanceInMiles = [rmcomma doubleValue]*0.621371;
                    }else if([substring isEqualToString:@"m"]){
                        rpString = [distanceText stringByReplacingOccurrencesOfString:@"m" withString:@""];
                        NSString *rmcomma = [rpString stringByReplacingOccurrencesOfString:@"," withString:@""];
                        NSLog(@"distanceText = %@",rmcomma);
                        distanceInMiles = [rmcomma doubleValue]*0.000621371;
                    }
                    
                    NSLog(@"distance in ml=%f",distanceInMiles);
                    NSLog(@"distance in ml=%d",(int)distanceInMiles );
                    _labelEstimatedDist.text = [NSString stringWithFormat:@"%.2f",distanceInMiles];
                    self.buttonSave.enabled = YES;
                    if ((float)distanceInMiles == 0.0) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please try with modifing Start point and End point." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView setTag:6];
                        [alertView show];
                        self.buttonSave.enabled = NO;
                    }
                }else if(NO) {
                    
                }
            }];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please store vehicle details." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView setTag:3];
            [alertView show];
        }
       
    }else{
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Fields should not be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView setTag:2];
        [alertView show];
    }
    
}

- (IBAction)submitButtonClicked:(id)sender{
    NSLog(@"EVTripPlanTableViewController submitButtonClicked");
    if (![_textViewEndPoint.text isEqualToString:@""] && ![_textFieldMileage.text isEqualToString:@""]) {
        if(![_textFieldMileage.text isEqualToString:@"0"]){
            if (BatteryDistance > distanceInMiles) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"There is sufficient amount amount of battery charge to reach your destination." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView setTag:0];
                [alertView show];
            }else{
                
                if([CLLocationManager locationServicesEnabled] &&
                   [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"There is insufficient amount of battery charge to reach your destination." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView setTag:0];
                    [alertView show];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"There is no location service available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView setTag:4];
                    [alertView show];
                }
            }
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please store vehicle details." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView setTag:3];
            [alertView show];
        }
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Fields should not be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView setTag:2];
        [alertView show];
    }

}

//--------------------------------------------------------------------------------------------------
// AlertView's Button Event
//--------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 0) {
        if (buttonIndex == 0) {
            [self fetchlatandlong:_textViewStartPoint.text withCompletionBlock:^(BOOL success){
                if (YES) {
                    EVTripPlanRouteViewController *evTripRoughtViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"tripGpsView"];
                    [self.navigationController pushViewController:evTripRoughtViewcontroller animated:YES];
                    evTripRoughtViewcontroller.ToLati=[NSString stringWithFormat:@"%.8f",destinationDist.coordinate.latitude] ;
                    evTripRoughtViewcontroller.ToLongi=[NSString stringWithFormat:@"%.8f",destinationDist.coordinate.longitude];
                    evTripRoughtViewcontroller.FromLati = [NSString stringWithFormat:@"%.8f",sourceDist.coordinate.latitude] ;
                    evTripRoughtViewcontroller.FromLongi = [NSString stringWithFormat:@"%.8f",sourceDist.coordinate.longitude] ;
                    evTripRoughtViewcontroller.fromCoords = sourceDist.coordinate;
                    evTripRoughtViewcontroller.toCoords = destinationDist.coordinate;
 
                }
            }];
            
        }
    }
    if ([alertView tag] == 3) {
        if (buttonIndex == 0) {
            EVAddVehicleViewController *evAddVehicleViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"addVehicleView"];
            [self.navigationController pushViewController:evAddVehicleViewcontroller animated:YES];
        }
        else if (buttonIndex == 1){
        }
    }
}

#pragma mark protocol methods.
//--------------------------------------------------------------------------------------------------
// TextField start Editing
//--------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 1){
        [_textFieldMileage becomeFirstResponder];
    }
}


#pragma mark protocol methods.
//--------------------------------------------------------------------------------------------------
// Return key Pressed
//--------------------------------------------------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1){
        [_textFieldMileage resignFirstResponder];
    }
    return TRUE;
}

- (IBAction)startTimer:(id)sender{
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void) tick:(NSTimer *) timer {}

-(void)calculateDistanceWithSource:(NSString *)source withDestination:(NSString *)destination WithCompletionBlock:(void(^)(BOOL success, id result, NSError *error))completionBlock{
    NSLog(@"EVTripPlanTableViewController calculateDistanceWithSource");
    [EVDirectionService fetchDataFromServiceWithSource:source withDestination:(NSString *)destination withCompletionBlock:^(BOOL success, id result, NSError *error){
        if(success){
            completionBlock(YES,result,error);
        }else
            completionBlock(NO,result,error);
    }];
}

- (IBAction)addReservationNotification:(id)sender {
    NSLog(@"EVTripPlanTableViewController addReservationNotification");
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:120];
    localNotification.alertBody = @"Test Notification";
    localNotification.alertAction = @"Show me the item";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        if (textView.tag == 1) {
            
        }else if(textView.tag == 2){
            if (![textView.text isEqualToString:@""]) {
                [self fetchlocationName:self];
            }
        }
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)goTripToStationRouteVC{
    EVTripToStationRouteViewController *testview = [self.storyboard instantiateViewControllerWithIdentifier:@"tripToStationView"];
    [self.navigationController pushViewController:testview animated:YES];
}

@end
