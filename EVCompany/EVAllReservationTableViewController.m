//
//  EVAllReservationTableViewController.m
//  EVCompany
//
//  Created by GridScape on 2/26/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import "EVAllReservationTableViewController.h"
#import "EVDetailCell.h"
#import "EVOCPPClientApi.h"
#import "EVAppDelegate.h"
#import "EVStations.h"
#import "EVUser.h"
#import "EVModal.h"

@interface EVAllReservationTableViewController (){
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
    BOOL isALL;
    long startTag;
}

@end

@implementation EVAllReservationTableViewController
@synthesize currentconnectorid,reservationData,currentstation,currentconnctIndex,currentStartTime,currentEndTime, delegate;

- (void)viewDidLoad {
    NSLog(@"--------------EVAllRservationTableViewController--------------");
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 84, 0);
    isALL = NO;
    currentstationonScreen = currentstation;
    
    serverFormat = [[NSDateFormatter alloc] init];
    [serverFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [serverFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    localFormat = [[NSDateFormatter alloc] init];
    [localFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [localFormat setTimeZone:[NSTimeZone localTimeZone]];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self allUserReservation];
    [self.tableView reloadData];
    _reservation = [[NSMutableArray arrayWithArray:reservationData] mutableCopy];
    appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.isRefresh = YES;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init]; [refreshControl addTarget:self action:@selector(sortArray) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)sortArray
{
    
    [self refreshAction];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)orientationChanged:(NSNotification *)notification
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self allUserReservation];
    [self.tableView reloadData];
}

-(void)refreshAction
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:currentstation.chargerId forKey:@"ocppChargeboxIdentity"];
    [dict setValue:currentconnectorid forKey:@"connectorId"];
    [dict setValue:@"-" forKey:@"tagId"];
    [dict setValue:currentStartTime forKey:@"startDate"];
    [dict setValue:currentEndTime forKey:@"expiryDate"];
    NSLog(@"Refresh Parameter Data : %@",dict);
    
    [[EVOCPPClientApi sharedOcppClient] getReservationListWithParameters:dict Success:^(id result) {
        NSLog(@"Refresh Responce Data : %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
            _reservation = [result[@"reservationList"] mutableCopy];
            [self.tableView reloadData];
        }else
        {
            [_reservation removeAllObjects];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"No reservations found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert setTag:5];
            [alert show];
            [self.tableView reloadData];
        }
        
    } Failure:^(NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)allUserReservation{
    [self.delegate showModalWithMessage:@"Loading reservations..."];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:currentstation.chargerId forKey:@"ocppChargeboxIdentity"];
    [dict setValue:currentconnectorid forKey:@"connectorId"];
    [dict setValue:@"-" forKey:@"tagId"];
    [dict setValue:currentStartTime forKey:@"startDate"];
    [dict setValue:currentEndTime forKey:@"expiryDate"];
    NSLog(@"All User Reservation Parameter Data : %@",dict);
        
    [[EVOCPPClientApi sharedOcppClient] getReservationListWithParameters:dict Success:^(id result) {
        [self.delegate hideModal];
        NSLog(@"All User Reservation Responce Data : %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
             _reservation = [result[@"reservationList"] mutableCopy];
            [self.tableView reloadData];
        }else
        {
            [_reservation removeAllObjects];
            [self.delegate hideModal];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"No reservations found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert setTag:6];
            [alert show];
            [self.tableView reloadData];
        }
    } Failure:^(NSError *error) {
        [self.delegate hideModal];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_reservation count];
    NSLog(@"Reservation Count : %lu",(unsigned long)[_reservation count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
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
                //a     [self.tableView reloadData];
            }
            
        }else{
            //[self showAlert];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            labelDetails.text = currentconnectorid;
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
                //    if ([chargePointStatus isEqualToString:@"Available"]) {
                start_button = [[UIButton alloc] initWithFrame:CGRectMake(170, 5, 60, 30)];
                start_button.layer.cornerRadius = 5.0;
                start_button.tag = indexPath.section;
                [start_button addTarget:self action:@selector(RemoteStartStopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [start_button setTitle:@"Start" forState:UIControlStateNormal];
                //  [start_button setBackgroundColor:[UIColor colorWithRed:42.0/255.0 green:175.0/255.0 blue:61.0/255.0 alpha:1]];
                [start_button setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
                start_button.titleLabel.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:start_button];
                //     }else if([chargePointStatus isEqualToString:@"Occupied"]){
                
                //     }
                cancel = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, 130, 30)];
                cancel.layer.cornerRadius = 5.0;
                cancel.tag = indexPath.section;
                [cancel addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
                //    [cancel setBackgroundColor:[UIColor colorWithRed:42.0/255.0 green:175.0/255.0 blue:61.0/255.0 alpha:1]];
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

- (void)cancelButtonClick:(id) sender{
    [self.delegate showModalWithMessage:@"Cancelling reservation..."];
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
            [self.delegate showModalWithMessage:@"Reservation successfully cancelled!" forDuration:1.5];
            [_reservation removeObjectAtIndex:senderBtn.tag];
            [self fetchConnectorUsingChargerId];
            [self refreshAction];
            [self.tableView reloadData];
        }else{
            [self.delegate showModalWithMessage:@"Failed to cancel reservation" forDuration:1.5];
        }
    } Failure:^(NSError *error) {
        [self.delegate showModalWithMessage:@"Failed to cancel reservation" forDuration:1.5];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)RemoteStartStopButtonClick:(id) sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Is your vehicle plugged in?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alertView setTag:0];
    [alertView show];
    
    UIButton *senderBtn = (UIButton *)sender;
    startTag = senderBtn.tag;
}


- (void)RemoteStopButtonClick:(id) sender
{
    [self.delegate showModalWithMessage:@"Stopping..."];
    UIButton *senderBtn = (UIButton *)sender;
    NSMutableDictionary *dict = [NSMutableDictionary new];
    // [dict setValue:@"0" forKey:@"reservationId"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"reservationId"] forKey:@"reservationId"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"ocppChargeboxIdentity"] forKey:@"ocppChargeboxIdentity"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"ocppConnectorID"] forKey:@"connectorId"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"tagId"] forKey:@"idTag"];
    [dict setValue:[[_reservation objectAtIndex:senderBtn.tag] objectForKey:@"sdad"] forKey:@"msg"];
    NSLog(@"Stop Charging Service Parameter Data : %@",dict);
    
    [[EVOCPPClientApi sharedOcppClient] RemoteChargingStopWithParameters:dict Success:^(id result) {
        NSLog(@"Stop Charging Service Responce Data : %@",result);
        if ([result[@"status"] isEqualToString:@"true"]) {
            [self.delegate showModalWithMessage:@"Charging stopped!" forDuration:1.5];
            [self refreshAction];
            [self.tableView reloadData];
            [self refreshAction];
        }else{
            [self.delegate showModalWithMessage:@"Failed to stop charging." forDuration:1.5];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:result[@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert setTag:2];
            [alert show];
        }
    } Failure:^(NSError *error) {
        [self.delegate showModalWithMessage:@"Failed to stop charging." forDuration:1.5];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

//--------------------------------------------------------------------------------------------------
// AlertView's Button Event
//--------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 0) {
        if (buttonIndex == 0) {
            [self.delegate showModalWithMessage:@"Starting..."];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setValue:[[_reservation objectAtIndex:startTag] objectForKey:@"reservationId"] forKey:@"reservationId"];
            [dict setValue:[[_reservation objectAtIndex:startTag] objectForKey:@"ocppChargeboxIdentity"] forKey:@"ocppChargeboxIdentity"];
            [dict setValue:[[_reservation objectAtIndex:startTag] objectForKey:@"ocppConnectorID"] forKey:@"connectorId"];
            [dict setValue:[[_reservation objectAtIndex:startTag] objectForKey:@"tagId"] forKey:@"idTag"];
            [dict setValue:[[_reservation objectAtIndex:startTag] objectForKey:@"sdad"] forKey:@"msg"];
            NSLog(@"Start Charging Service Parameter Data : %@",dict);
            
            [[EVOCPPClientApi sharedOcppClient] RemoteChargingStartWithParameters:dict Success:^(id result) {
                NSLog(@"Start Charging Service Responce Data : %@",result);
                if ([result[@"status"] isEqualToString:@"true"]) {
                    [self.delegate showModalWithMessage:@"Charging Started!" forDuration:1.5];
                    [self refreshAction];
                    [self.tableView reloadData];
                    [self refreshAction];
                }else{
                    [self.delegate showModalWithMessage:@"Failed to start charging" forDuration:1.5];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:result[@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert setTag:4];
                    [alert show];
                }
            } Failure:^(NSError *error) {
                [self.delegate showModalWithMessage:@"Failed to start charging" forDuration:1.5];
                NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
            }];
        }
        else if (buttonIndex == 1){
        }
    }
}

@end
