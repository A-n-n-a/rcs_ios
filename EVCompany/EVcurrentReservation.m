//
//  EVcurrentReservation.m
//  EVCompany
//
//  Created by GridScape on 10/20/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVcurrentReservation.h"
#import "EVDetailCell.h"
#import "EVOCPPClientApi.h"
#import "EVAppDelegate.h"
#import "EVStations.h"
#import "EVUser.h"
#import "EVModal.h"

@interface EVcurrentReservation (){
    UILabel *labelTitle;
    UILabel *labelDetails;
    NSMutableArray *_reservation;
    EVAppDelegate *appDelegete;
    NSDateFormatter *serverFormat;
    NSDateFormatter *localFormat;
    NSArray *connectorArray;
    EVStations *currentstationonScreen;
    NSString *currentConnectorId;
    NSString *chargePointStatus;
    UIButton *stop_button;
    UIButton *start_button;
    UIButton *cancel;
    UIActivityIndicatorView *activityIndicator;
    UISegmentedControl *control;
    BOOL isALL;
    EVModal *modal;
}

@end

@implementation EVcurrentReservation

- (void)viewDidLoad {
    NSLog(@"--------------EVcurrentReservation--------------");
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
    
    isALL = NO;
    currentstationonScreen = _currentstation;
    
    serverFormat = [[NSDateFormatter alloc] init];
    [serverFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [serverFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    localFormat = [[NSDateFormatter alloc] init];
    [localFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [localFormat setTimeZone:[NSTimeZone localTimeZone]];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    _reservation = [[NSMutableArray arrayWithArray:_reservationData] mutableCopy];
    appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    NSArray *itemArray = [NSArray arrayWithObjects: @"Own", @"All", nil];
    control = [[UISegmentedControl alloc] initWithItems:itemArray];
    [control setTintColor:[UIColor colorWithRed:41.0/255.0 green:175.0/255.0 blue:62.0/255.0 alpha:1.0]];
    [control setSelectedSegmentIndex:0];
    [control setFrame:CGRectMake(10.0, 10, self.view.frame.size.width-20, 30.0)];
    [control setEnabled:YES];
    [control addTarget:self action:@selector(segmentSwitch:) forControlEvents:UIControlEventValueChanged];
    
    [self setRightBarbutton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [control setFrame:CGRectMake(10.0, 10, self.view.frame.size.width-20, 30.0)];
}

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if(selectedSegment == 0){
        isALL = NO;
        [self UserReservation];
        [self showModalWithMessage:@"Retrieving reservations..."];
    }else{
        isALL = YES;
        [self allUserReservation];
        [self showModalWithMessage:@"Retrieving reservations"];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self refreshAction];
    [self.tableView reloadData];
}

-(void)setRightBarbutton{
    UIButton *refreshBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [refreshBarButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    [refreshBarButton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithCustomView:refreshBarButton];
    
    activityIndicator = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidden = YES;
    UIBarButtonItem* spinner = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    NSArray *tempArray2= [[NSArray alloc] initWithObjects:spinner,refresh,nil];
    self.navigationItem.rightBarButtonItems=tempArray2;
}

-(void)refreshAction{
    [activityIndicator startAnimating];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setValue:_currentstation.chargerId forKey:@"ocppChargeboxIdentity"];
    [dict setValue:_currentconnectorid forKey:@"connectorId"];
    if (isALL) {
        [dict setValue:@"-" forKey:@"tagId"];
    }else{
        [dict setValue:[EVUser currentUser].tagId forKey:@"tagId"];
    }
    [dict setValue:_currentStartTime forKey:@"startDate"];
    [dict setValue:_currentEndTime forKey:@"expiryDate"];
    NSLog(@"Refresh Parameter Data = %@",dict);
    
    [[EVOCPPClientApi sharedOcppClient] getReservationListWithParameters:dict Success:^(id result) {
        NSLog(@"Refresh Responce Data = %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
            _reservation = [result[@"reservationList"] mutableCopy];
            [self.tableView reloadData];
            [activityIndicator stopAnimating];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"There are no reservations" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    } Failure:^(NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)allUserReservation{
    [activityIndicator startAnimating];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setValue:_currentstation.chargerId forKey:@"ocppChargeboxIdentity"];
    [dict setValue:_currentconnectorid forKey:@"connectorId"];
    [dict setValue:@"-" forKey:@"tagId"];
    [dict setValue:_currentStartTime forKey:@"startDate"];
    [dict setValue:_currentEndTime forKey:@"expiryDate"];
    NSLog(@"All User Reservation Parameter Data : %@",dict);
    
    [[EVOCPPClientApi sharedOcppClient] getReservationListWithParameters:dict Success:^(id result) {
        NSLog(@"All User Reservation Response Data : %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
            
            _reservation = result[@"reservationList"];
            
            [self.tableView reloadData];
            [activityIndicator stopAnimating];
            [modal hide];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"No reservations found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [modal hide];
        }
    } Failure:^(NSError *error) {
        [modal hide];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)UserReservation{
    [activityIndicator startAnimating];
    NSMutableDictionary *dict = [NSMutableDictionary new];

    [dict setValue:_currentstation.chargerId forKey:@"ocppChargeboxIdentity"];
    [dict setValue:_currentconnectorid forKey:@"connectorId"];
    [dict setValue:[EVUser currentUser].tagId forKey:@"tagId"];
    [dict setValue:_currentStartTime forKey:@"startDate"];
    [dict setValue:_currentEndTime forKey:@"expiryDate"];
    NSLog(@"Reservation List Parameter Data : %@",dict);
    
    [[EVOCPPClientApi sharedOcppClient] getReservationListWithParameters:dict Success:^(id result) {
        NSLog(@"Reservation List Response Data : %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
            
            _reservation = result[@"reservationList"];
            
            [self.tableView reloadData];
            [activityIndicator stopAnimating];
            [modal hide];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"There are no reservations" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [modal hide];
        }
        
    } Failure:^(NSError *error) {
        [modal hide];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_reservation count];
    NSLog(@"Reservation count = %lu",(unsigned long)[_reservation count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rowsnumber;
    if([[[_reservation objectAtIndex:section] objectForKey:@"tagId"] isEqualToString:[EVUser currentUser].tagId]){
        rowsnumber = 7;
    }else{
        rowsnumber = 6;
    }
    return rowsnumber;
}

-(void)fetchConnectorUsingChargerId{
    [currentstationonScreen fetchConnectorUsingChargerIdWithCompletionBlock:^(BOOL success,id result, NSError *error) {
        if(success){
            NSArray *arrayResult = result;
            if(arrayResult.count > 0){
                connectorArray = result;
            }
        }else{
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.contentView clearsContextBeforeDrawing];
    }
    
    labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 7, 150, 30)];
    labelTitle.font = [UIFont boldSystemFontOfSize:14];
    labelTitle.numberOfLines = 2;
    labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
    
    labelDetails  = [[UILabel alloc]initWithFrame:CGRectMake(153, -10, 170, 60)];
    labelDetails.font = [UIFont boldSystemFontOfSize:14];
    labelDetails.textColor = [UIColor grayColor];
    labelDetails.numberOfLines = 2;
    labelDetails.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDate *server_date;
    NSString *local_date;

    switch (indexPath.row)
    {
        case 0:
            labelTitle.text = @"Address";
            labelDetails.text = currentstationonScreen.adderssline1;
            [cell.contentView addSubview:labelTitle];
            [cell.contentView addSubview:labelDetails];
            break;
            
        case 1:
            labelTitle.text = @"Chargebox Identity";
            labelDetails.text = [[_reservation objectAtIndex:indexPath.section] objectForKey:@"ocppChargeboxIdentity"];
            [cell.contentView addSubview:labelTitle];
            [cell.contentView addSubview:labelDetails];
            break;
            
        case 2:
            labelTitle.text = @"Connector #";
            labelDetails.text = _currentconnectorid;
            [cell.contentView addSubview:labelTitle];
            [cell.contentView addSubview:labelDetails];
            break;
      
        case 3:
            labelTitle.text = @"Start Date";
            server_date = [serverFormat dateFromString:[[[_reservation objectAtIndex:indexPath.section] objectForKey:@"ocpp_Start_Date"] substringWithRange:NSMakeRange(0, 19)]];
            local_date = [localFormat stringFromDate:server_date];
            labelDetails.text = local_date;
            [cell.contentView addSubview:labelTitle];
            [cell.contentView addSubview:labelDetails];
            break;
            
            
        case 4:
            labelTitle.text = @"Expiry Date";
            server_date = [serverFormat dateFromString:[[[_reservation objectAtIndex:indexPath.section] objectForKey:@"ocpp_Expiry_Date"] substringWithRange:NSMakeRange(0, 19)]];
            local_date = [localFormat stringFromDate:server_date];
            labelDetails.text = local_date;
            [cell.contentView addSubview:labelTitle];
            [cell.contentView addSubview:labelDetails];
            break;
        
        case 5:
            labelTitle.text = @"Reservation Status";
            if([[[_reservation objectAtIndex:indexPath.section] objectForKey:@"reservation_Status"] isEqualToString:@"InProgress"]){
                labelDetails.text = @"Reserved";
            }else if([[[_reservation objectAtIndex:indexPath.section] objectForKey:@"reservation_Status"] isEqualToString:@"Waiting"]){
                labelDetails.text = @"Reserved";
            }else if([[[_reservation objectAtIndex:indexPath.section] objectForKey:@"reservation_Status"] isEqualToString:@"Completed"]){
                labelDetails.text = @"Completed";
            }else if([[[_reservation objectAtIndex:indexPath.section] objectForKey:@"reservation_Status"] isEqualToString:@"Expire"]){
                labelDetails.text = @"Expire";
            }else if([[[_reservation objectAtIndex:indexPath.section] objectForKey:@"reservation_Status"] isEqualToString:@"Rejected"]){
                labelDetails.text = @"Rejected";
            }
           
            [cell.contentView addSubview:labelTitle];
            [cell.contentView addSubview:labelDetails];
            break;
        
        case 6:
        {
            if([[[_reservation objectAtIndex:indexPath.section] objectForKey:@"reservation_Status"] isEqualToString:@"InProgress"]){
                    start_button = [[UIButton alloc] initWithFrame:CGRectMake(170, 5, 60, 30)];
                    start_button.layer.cornerRadius = 5.0;
                    start_button.tag = indexPath.section;
                    [start_button addTarget:self action:@selector(RemoteStartButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    [start_button setTitle:@"Start" forState:UIControlStateNormal];
                    [start_button setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
                    start_button.titleLabel.font = [UIFont systemFontOfSize:16];
                    [cell.contentView addSubview:start_button];
           
                cancel = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, 130, 30)];
                cancel.layer.cornerRadius = 5.0;
                cancel.tag = indexPath.section;
                [cancel addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
                [cancel setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
                cancel.titleLabel.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:cancel];
            }else if([[[_reservation objectAtIndex:indexPath.section] objectForKey:@"reservation_Status"] isEqualToString:@"Completed"]){
                if(![[[_reservation objectAtIndex:indexPath.section] objectForKey:@"transactionStatus"] isEqualToString:@"0"] ){
                    [stop_button setHidden:YES];
                }else{
                    stop_button = [[UIButton alloc] initWithFrame:CGRectMake(240, 5, 60, 30)];
                    stop_button.layer.cornerRadius = 5.0;
                    stop_button.tag = indexPath.section;
                    [stop_button addTarget:self action:@selector(RemoteStopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    [stop_button setTitle:@"Stop" forState:UIControlStateNormal];
                    [stop_button setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
                    stop_button.titleLabel.font = [UIFont systemFontOfSize:16];
                    [cell.contentView addSubview:stop_button];
                }
            }else if([[[_reservation objectAtIndex:indexPath.section] objectForKey:@"reservation_Status"] isEqualToString:@"Waiting"]){
                    cancel = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, 130, 30)];
                    cancel.layer.cornerRadius = 5.0;
                    cancel.tag = indexPath.section;
                    [cancel addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
                    [cancel setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
                    cancel.titleLabel.font = [UIFont systemFontOfSize:16];
                    [cell.contentView addSubview:cancel];
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView;
    if(section == 0){
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
        headerView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:control];
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int value = 0;
    if (section == 0){
        value = 44;
    }else{
        value = 0;
    }
    return value;
}

- (void)cancelButtonClick:(id) sender
{
    [self showModalWithMessage:@"Cancelling reservation..."];
    UIButton *senderBtn = (UIButton *)sender;
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"ocppChargeboxIdentity"] forKey:@"ocppChargeboxIdentity"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"ocppConnectorID"] forKey:@"connectorId"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"tagId"] forKey:@"idTag"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"reservationId"] forKey:@"reservationId"];
    
    NSLog(@"Cancel Service Parameter Data : %@",dict);
    
    [[EVOCPPClientApi sharedOcppClient] getCancelReservationWithParameters:dict Success:^(id result) {
        NSLog(@"Cancel Service Responce Data : %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
            [self showModalWithMessage:@"Reservation Cancelled!" forDuration:1.5];
            [_reservation removeObjectAtIndex:senderBtn.tag];
            [self fetchConnectorUsingChargerId];
            [self refreshAction];
            [self.tableView reloadData];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Cannot cancel reservation." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    } Failure:^(NSError *error) {
        [self showModalWithMessage:@"Failed" forDuration:1.5];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)RemoteStartButtonClick:(id) sender
{
    [self showModalWithMessage:@"Starting..."];
    UIButton *senderBtn = (UIButton *)sender;
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"reservationId"] forKey:@"reservationId"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"ocppChargeboxIdentity"] forKey:@"ocppChargeboxIdentity"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"ocppConnectorID"] forKey:@"connectorId"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"tagId"] forKey:@"idTag"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"sdad"] forKey:@"msg"];
    NSLog(@"Start Charging Service Parameter Data : %@",dict);
 
    [[EVOCPPClientApi sharedOcppClient] RemoteChargingStartWithParameters:dict Success:^(id result) {
        NSLog(@"Start Charging Service Responce Data : %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
            [self showModalWithMessage:@"Charging started!" forDuration:1.5];
            [self refreshAction];
            [self.tableView reloadData];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Charging Started" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [self refreshAction];
        }else
        {
            [self showModalWithMessage:@"@Failed to start charging" forDuration:1.5];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:result[@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    } Failure:^(NSError *error) {
        [self showModalWithMessage:@"Failed" forDuration:1.5];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
  
}


- (void)RemoteStopButtonClick:(id) sender
{
    [self showModalWithMessage:@"Stopping..."];
    UIButton *senderBtn = (UIButton *)sender;
    NSMutableDictionary *dict = [NSMutableDictionary new];
   
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"reservationId"] forKey:@"reservationId"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"ocppChargeboxIdentity"] forKey:@"ocppChargeboxIdentity"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"ocppConnectorID"] forKey:@"connectorId"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"tagId"] forKey:@"idTag"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"sdad"] forKey:@"msg"];
    NSLog(@"Stop Charging Service Parameter Data : %@",dict);
 
    [[EVOCPPClientApi sharedOcppClient] RemoteChargingStopWithParameters:dict Success:^(id result) {
        NSLog(@"Stop Charging Service Responce Data : %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
            [self showModalWithMessage:@"Charging stopped!" forDuration:1.5];
            [self refreshAction];
            [self.tableView reloadData];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Charging Stopped." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [self refreshAction];
            
        }else{
            [self showModalWithMessage:@"Failed" forDuration:1.5];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:result[@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    } Failure:^(NSError *error) {
        [self showModalWithMessage:@"Failed" forDuration:1.5];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
  
}

-(void)showModalWithMessage:(NSString*)message {
    [modal setMessage: message];
    [modal show];
}

-(void)showModalWithMessage:(NSString*)message forDuration:(CGFloat)duration {
    [modal setMessage: message];
    [modal showWithoutSpinner];
    
    [NSTimer scheduledTimerWithTimeInterval: duration target:modal selector:@selector(hide) userInfo:nil repeats:NO];
}

@end
