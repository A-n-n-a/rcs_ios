//
//  EVOCPPDetailsViewControllerTableViewController.m
//  EVCompany
//
//  Created by GridScape on 11/27/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVOCPPDetailsViewController.h"
#import "EVDetailCell.h"
#import "EVRouteViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import "GeoCoder.h"
#import "EVStations.h"
#import "EVUser.h"
#import "EVImageCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "KGModal.h"
#import "EVMapDetailsRouteViewController.h"
#import "EVAppDelegate.h"
#import "Filter.h"
#import "EVReservationViewController.h"
#import "EVListReservationViewController.h"
#import "EVOCPPClientApi.h"
#import "EVcurrentReservation.h"
#import "EVReservationListViewController.h"
#import "EVModal.h"

@interface EVOCPPDetailsViewController ()
{
    NSArray *arrayDetails;
    //NSArray *connectorArray;
    NSMutableArray *connectorArray;
    
    UIButton *reserveListButton;
    UIButton *reserveButton;
    
    NSURL *url;
    NSUInteger index;
    NSManagedObjectContext *managedObjectContext;
    NSInteger connectorIndex;
    NSString *connectorDesc;
    NSString *connectorId;
    NSString *connectorStatus;
    NSString *usage_type;
    UILabel *labelTitle;
    UILabel *labelAddress;
    NSMutableArray *reservationList;
    EVModal *modal;
}
@end

@implementation EVOCPPDetailsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"--------------EVOCPPDetailsViewController--------------");
    [super viewDidLoad];
    if ([_station.usageType isEqualToString:@"true"]) {
        usage_type = @"Public";
    }else if([_station.usageType isEqualToString:@"false"]){
        usage_type = @"Private";
    }
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
    
    connectorId = @"";
    connectorDesc = @"";
    //[self fetchConnectorUsingChargerId];
    
    UIBarButtonItem *buttonShare = [[UIBarButtonItem alloc]initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction:)];
    UIBarButtonItem *buttonRoute = [[UIBarButtonItem alloc]initWithTitle:@"Route" style:UIBarButtonItemStylePlain target:self action:@selector(route:)];
    
    UIButton *sliderBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [sliderBarButton addTarget:self action:@selector(favoriteAction) forControlEvents:UIControlEventTouchUpInside];
    [sliderBarButton setBackgroundImage:[UIImage imageNamed:@"whiteStar.png"] forState:UIControlStateNormal];
    UIBarButtonItem *favourite = [[UIBarButtonItem alloc] initWithCustomView:sliderBarButton];
    
    UIButton *directionBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    [directionBarButton addTarget:self action:@selector(findLocationFor) forControlEvents:UIControlEventTouchUpInside];
    [directionBarButton setBackgroundImage:[UIImage imageNamed:@"carImage"] forState:UIControlStateNormal];
    UIBarButtonItem *direction = [[UIBarButtonItem alloc] initWithCustomView:directionBarButton];
    
    
    NSArray *barButtonArray;
    if([[EVUser currentUser]userId])
        barButtonArray= [[NSArray alloc] initWithObjects:favourite,buttonShare,direction,buttonRoute,nil];
    else
        barButtonArray= [[NSArray alloc] initWithObjects:buttonShare,direction,nil];
    self.navigationItem.rightBarButtonItems=barButtonArray;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    //my test change for back button[self setBackBarButton];
}

-(void)setBackBarButton{
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(BackButtonClick)];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
}

- (IBAction)BackButtonClick{
    NSLog(@"back click");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)orientationChanged:(NSNotification *)notification{
    NSString *addressString = _station.imageName.length > 0?[NSString stringWithFormat:@"%@",_station.adderssline1]: [NSString stringWithFormat:@"%@,%@,%@,%@",_station.adderssline1,_station.town,_station.stateOrProvince,_station.postCode];
    labelTitle.frame = CGRectMake(0, 5, self.view.frame.size.width, [self getHeightForString:_station.title  forFont:[labelTitle font] forConstraintSize:CGSizeMake(320, 999)].height);
    labelAddress.frame = CGRectMake(0, labelTitle.frame.size.height, self.view.frame.size.width, [self getHeightForString:addressString  forFont:[labelAddress font] forConstraintSize:CGSizeMake(320, 999)].height+5);
    
    reserveListButton.frame = CGRectMake((self.view.frame.size.width/2)+10,5,(self.view.frame.size.width/2)-20,30);
    reserveButton.frame = CGRectMake(10,5,(self.view.frame.size.width/2)-20,30);
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    connectorId = @"";
    connectorDesc = @"";
    [self fetchConnectorUsingChargerId];
    [self.tableView reloadData];
}

-(void)shareAction:(id)sender{
    NSString *addressString = [NSString stringWithFormat:@"%@,%@,%@",_station.adderssline1,_station.town,_station.stateOrProvince];
    NSString *shareString = [NSString stringWithFormat:@"Electric Car (EV) Charging Station - EVCompany. Electric Car (EV) Charging Station at - Address:%@",addressString ];
    //    NSURL *shareUrl = [NSURL URLWithString:@"https://itunes.apple.com/us/app/jade-app/id775544891?ls=1&mt=8"];
    NSArray *activityItems = [NSArray arrayWithObjects:shareString, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

-(void)route:(id)sender{
    EVMapDetailsRouteViewController *mapDetailRouteViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"gpsView"];
    mapDetailRouteViewController.ToLati=_station.latitude ;
    mapDetailRouteViewController.ToLongi=_station.longitude;
    [self.navigationController pushViewController:mapDetailRouteViewController animated:YES];
}

-(void)favoriteAction{
    EVStations *stations = _station;
    if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ] isKindOfClass:[EVImageCell class]]){
        EVImageCell *cell = (EVImageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        stations.image = cell.addedImage.image;
    }
    stations.userId = [[EVUser currentUser] userId];
    [stations makeFavouritewithCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(!success){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Already marked as favorite" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
 
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.contentView clearsContextBeforeDrawing];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
 
    reserveButton = [[UIButton alloc] init];
    reserveButton.frame = CGRectMake(10,5,(self.view.frame.size.width/2)-20,30);
    reserveButton.layer.cornerRadius = 5.0;
    [reserveButton addTarget:self action:@selector(reserveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [reserveButton setTitle:@"Reserve" forState:UIControlStateNormal];
    [reserveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [reserveButton setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
 
    reserveListButton = [[UIButton alloc]init];
    reserveListButton.frame = CGRectMake((self.view.frame.size.width/2)+10,5,(self.view.frame.size.width/2)-20,30);//CGRectMake(170,5,140,30);
    reserveListButton.layer.cornerRadius = 5.0;
    [reserveListButton addTarget:self action:@selector(showReservationList) forControlEvents:UIControlEventTouchUpInside];
    [reserveListButton setTitle:@"Reservation List" forState:UIControlStateNormal];
    [reserveListButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [reserveListButton setTitleColor:[UIColor
                                      colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
    
    UILabel *mainLabel, *secondLabel;
     
     mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 7, 150, 30)];
     mainLabel.font = [UIFont boldSystemFontOfSize:14];
     mainLabel.numberOfLines = 2;
     mainLabel.lineBreakMode = NSLineBreakByWordWrapping;
     mainLabel.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
     if (indexPath.row != 10) {
         [cell.contentView addSubview:mainLabel];
     }
     
     secondLabel  = [[UILabel alloc]initWithFrame:CGRectMake(153, -10, 170, 60)];
     secondLabel.font = [UIFont boldSystemFontOfSize:14];
     secondLabel.textColor = [UIColor grayColor];
     secondLabel.numberOfLines = 2;
     secondLabel.lineBreakMode = NSLineBreakByWordWrapping;
     secondLabel.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
     if (indexPath.row != 10) {
         [cell.contentView addSubview:secondLabel];
     }
 
    if (indexPath.row == 9) {
         if([[EVUser currentUser]userId]){
             [cell addSubview:reserveListButton];
             [cell addSubview:reserveButton];
         }
    }else if (indexPath.row == 0) {
        mainLabel.text = @"Distance";
        float distace = [self calculateDistance:_station.latitude :_station.longitude];
        secondLabel.text = [NSString stringWithFormat:@"%.2f Mi",distace];
    }else if (indexPath.row == 1) {
        mainLabel.text = @"Status";
        secondLabel.text = [[connectorArray objectAtIndex:connectorIndex] objectForKey:@"chargePointStatus"];//_station.status;
    }else if (indexPath.row == 2) {
        mainLabel.text = @"Usage Type";
        secondLabel.text =usage_type;
    }else if (indexPath.row == 3) {
        mainLabel.text = @"Charging Level";
        if (_station.powerLevel == nil || _station.powerLevel == (id)[NSNull null]) {
            secondLabel.text = @"";
        }
        //secondLabel.text = [self findChargingLevel:_station.powerLevel];
    }else if (indexPath.row == 4) {
        mainLabel.text = @"Access Information";
        if(![_station.descriptions isKindOfClass:[NSNull class]]){
            secondLabel.text = @"";//_station.descriptions;
        }
    }else if (indexPath.row == 5) {
        mainLabel.text = @"Connector Types";
        secondLabel.text = connectorDesc;//[[connectorArray objectAtIndex:connectorIndex] objectForKey:@"connectorDesc"];[_station.statusTimestamp substringWithRange:NSMakeRange(0, 19)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row == 6) {
        mainLabel.text = @"Connector #";
        secondLabel.text = [[connectorArray objectAtIndex:connectorIndex] objectForKey:@"ocppConnectorId"];;
    }else if (indexPath.row == 7) {
        mainLabel.text = @"Operator";
        secondLabel.text = _station.operatorInfo;
    }else if (indexPath.row == 8) {
        mainLabel.text = @"Contact Telephone";
        secondLabel.text = _station.contactTelephone1;
    }else if (indexPath.row == 9) {
        mainLabel.text = @"";
        secondLabel.text = @"";
    }
    return cell;
}
 
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleStr = [NSString stringWithFormat:@"%@(%@)",_station.title,_station.chargerId];
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    labelTitle = [[UILabel alloc]init];
    labelTitle.numberOfLines = 2;
    labelTitle.text = titleStr;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
    labelTitle.font = [UIFont systemFontOfSize:14];
    labelTitle.frame = CGRectMake(0, 5, self.view.frame.size.width, [self getHeightForString:titleStr  forFont:[labelTitle font] forConstraintSize:CGSizeMake(320, 999)].height);
    
    NSString *addressString = _station.imageName.length > 0?[NSString stringWithFormat:@"%@",_station.adderssline1]: [NSString stringWithFormat:@"%@,%@,%@,%@",_station.adderssline1,_station.town,_station.stateOrProvince,_station.postCode];
    labelAddress = [[UILabel alloc]init];
    labelAddress.text = _station.adderssline1;
    labelAddress.numberOfLines = 2;
    labelAddress.textColor = [UIColor grayColor];
    labelAddress.textAlignment = NSTextAlignmentCenter;
    labelAddress.lineBreakMode = NSLineBreakByWordWrapping;
    labelAddress.font = [UIFont systemFontOfSize:14];
    labelAddress.frame = CGRectMake(0, labelTitle.frame.size.height, self.view.frame.size.width, [self getHeightForString:addressString  forFont:[labelAddress font] forConstraintSize:CGSizeMake(320, 999)].height+5);
    
    [headerView addSubview:labelTitle];
    [headerView addSubview:labelAddress];
    headerView.frame = CGRectMake(0,0, 320, labelTitle.frame.size.height + labelAddress.frame.size.height+40);
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_station.imageName.length > 0 && indexPath.row == 0)
        return 40.0;
    else {
        NSString *displayContent=@"";
        if(indexPath.row == 1+index){
            if(![_station.ocppChargePointStatus isKindOfClass:[NSNull class]]){//a (![_station.status isKindOfClass:[NSNull class]]){
                //a  displayContent = _station.status;
                displayContent = _station.ocppChargePointStatus;
            }
        }
        else if(indexPath.row == 2+index)
            displayContent =  [self findChargingUsageTypes:_station.usageType];
        else if (indexPath.row == 3+index){
            displayContent = [self findChargingLevel:_station.powerLevel];
        }
        else if(indexPath.row == 4+index){
            if(![_station.descrp isKindOfClass:[NSNull class]]){
                displayContent = _station.descrp;
            }
        }else if(indexPath.row == 5+index){
            if(![_station.contactTelephone1 isKindOfClass:[NSNull class]]){
                displayContent = _station.contactTelephone1;
            }
        }
        
        return (MAX([self getHeightForString:displayContent forFont:[UIFont boldSystemFontOfSize:14] forConstraintSize:CGSizeMake(167, 999)].height, 38.0));
    }
    
}

- (void)showReservationList{
    if ([connectorId isEqualToString:@""] || [connectorDesc isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please select connector" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }else{
        [self reservationListButtonClicked:self];
    }
}

- (void)reserveButtonPressed
{
    if([_station.status isEqualToString:@"Faulted"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Cannot do reservation on faulted station." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }else if([_station.status isEqualToString:@"Offline"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Cannot do reservation on offline station." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }else{
        if ([connectorId isEqualToString:@""] || [connectorDesc isEqualToString:@""] || [connectorId isKindOfClass:[NSNull class]] || [connectorDesc isKindOfClass:[NSNull class]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please select connector." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }else{
            EVReservationViewController *evReserveViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"evReserve"];
            [evReserveViewcontroller setStation:_station];
            [evReserveViewcontroller setConnectorDesc:connectorDesc];
            [evReserveViewcontroller setConnectorId:connectorId];
            [evReserveViewcontroller setConnectorStatus:connectorStatus];
            [self.navigationController pushViewController:evReserveViewcontroller animated:YES];
        }
    }
}

-(NSString*)findChargingLevel:(NSString *)chargingLevel{
    NSArray *array = [chargingLevel componentsSeparatedByString:@","];
    if(!([array containsObject:@"1"]||[array containsObject:@"2"]||[array containsObject:@"3"]))
        return chargingLevel;
    
    NSMutableArray *charginglevels = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([array[idx] isEqualToString:@"1"])
            [charginglevels addObject:@"Level 1 : Low (Under 2kW)"];
        else if([array[idx] isEqualToString:@"2"])
            [charginglevels addObject:@"Level 2 : Medium (Over 2kW)"];
        else
            [charginglevels addObject:@"Level 3:  High (Over 40kW)"];
        
    }];
    
    return [charginglevels componentsJoinedByString:@","];
}

-(NSString*)findChargingUsageTypes:(NSString *)usageType{
    NSArray *array = [usageType componentsSeparatedByString:@","];
    if(!([array containsObject:@"0"] ||[array containsObject:@"1"] ||[array containsObject:@"3"] ||[array containsObject:@"4"] ||[array containsObject:@"5"] ||[array containsObject:@"6"] ||[array containsObject:@"7"] ||[array containsObject:@"2"] ))
        return usageType;
    
    
    NSMutableArray *usagetypes = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([array[idx] isEqualToString:@"0"])
            [usagetypes addObject:@"Unknown"];
        else if([array[idx] isEqualToString:@"1"])
            [usagetypes addObject:@"Public"];
        else if([array[idx] isEqualToString:@"2"])
            [usagetypes addObject:@"Private - Restricted Access"];
        else if([array[idx] isEqualToString:@"3"])
            [usagetypes addObject:@"Privately Owned - Notice Required"];
        else if([array[idx] isEqualToString:@"4"])
            [usagetypes addObject:@"Public - Membership Required"];
        else if([array[idx] isEqualToString:@"5"])
            [usagetypes addObject:@"Public - Pay At Location"];
        else if([array[idx] isEqualToString:@"6"])
            [usagetypes addObject:@"Private - For Staff and Visitors"];
        else
            [usagetypes addObject:@"Public - Notice Required"];
        
    }];
    
    return [usagetypes componentsJoinedByString:@","];
}

-(double)calculateDistance:(NSString * )latitude :(NSString *)longitude{
    
    EVAppDelegate *appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:appDelegete.currentLocation.coordinate.latitude longitude:appDelegete.currentLocation.coordinate.longitude];
    
    //    NSLog(@"degree %f",[self getHeadingForDirectionFromCoordinate:appDelegete.currentLocation.coordinate toCoordinate:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue])]);
    //
    //    float degree = [self getHeadingForDirectionFromCoordinate:appDelegete.currentLocation.coordinate toCoordinate:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue])];
    //
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    double distanceInMiles = distance * 0.000621371;//0.000621371192
    // double distcemile =degree/1609.344;
    
    return distanceInMiles;
}

-(NSString *)powerlevelFromCoredata{
    NSString *powerLevel;
    NSMutableArray *arrayPowerLevel = [NSMutableArray new];
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
    if(arrayLevel.count>0){
        [arrayLevel containsObject:@"1"]?[arrayPowerLevel addObject:@"Level 1 EVSE"]:nil;
        [arrayLevel containsObject:@"2"]?[arrayPowerLevel addObject:@"Level 2 EVSE"]:nil;
        [arrayLevel containsObject:@"dc_fast"]?[arrayPowerLevel addObject:@"DC Fast Charging"]:nil;
        powerLevel = [arrayPowerLevel componentsJoinedByString:@","];
    }else{
        powerLevel = @"Level 1 EVSE,Level 2 EVSE,DC Fast Charging";
    }
    return powerLevel;
}



- (CGSize)getHeightForString:(NSString *)string forFont:(UIFont *)font forConstraintSize:(CGSize)constrainSize {
    return [string sizeWithFont:font constrainedToSize:constrainSize lineBreakMode:NSLineBreakByWordWrapping];
}

#pragma mark - Table view delegate
-(void)showActionsheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a connector:"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for(int i=0;i<[connectorArray count];i++){
        [actionSheet addButtonWithTitle:[[connectorArray objectAtIndex:i] objectForKey:@"connectorDesc"]];
    }
    //    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"ActionSheet Index : %ld and Title : %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"From didDismissWithButtonIndex - Selected Color: %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
    connectorIndex = buttonIndex;
    connectorDesc = [[connectorArray objectAtIndex:connectorIndex] objectForKey:@"connectorDesc"];
    connectorId = [[connectorArray objectAtIndex:connectorIndex] objectForKey:@"ocppConnectorId"];
    connectorStatus = [[connectorArray objectAtIndex:connectorIndex] objectForKey:@"chargePointStatus"];
    NSLog(@"Selected Driver Index=%ld",(long)connectorIndex);
    NSLog(@" popup connectorId = %@",connectorId);
    NSLog(@"popup connectorDesc = %@",connectorDesc);
    [self.tableView reloadData];
}


-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"From willDismissWithButtonIndex - Selected Color: %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
    connectorIndex = buttonIndex;
    NSLog(@"Selected Driver Index=%ld",(long)connectorIndex);
    connectorDesc = [[connectorArray objectAtIndex:connectorIndex] objectForKey:@"connectorDesc"];
    connectorId = [[connectorArray objectAtIndex:connectorIndex] objectForKey:@"ocppConnectorId"];
    connectorStatus = [[connectorArray objectAtIndex:connectorIndex] objectForKey:@"chargePointStatus"];
    NSLog(@"Selected Driver Index : %ld",(long)connectorIndex);
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //a    NSString *phoneURLString;
    if(indexPath.row == 0 && _station.imageName.length > 0)
        [self gestureAction];
    else if(indexPath.row == 5){
        // a   phoneURLString = [NSString stringWithFormat:@"telprompt:%@", _station.contactTelephone1];
        // a    [self sendCall:phoneURLString];
        // [self popClickAction:self];
        //[self AssociateCardButtonPressed:self];
        if (connectorArray.count>0){
            [self showActionsheet];
        }
    }
}

-(void)sendCall:(NSString *)phoneURLString{
    NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    
}
-(void)getDirections:(NSDictionary *)dictLocation{
    CLLocation *location = [[CLLocation alloc]initWithLatitude:[_station.latitude doubleValue] longitude:[_station.longitude doubleValue]];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:dictLocation];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    if ([mapItem respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
    {
        [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving}];
    }
    else
    {
        // Google Maps fallback
        NSString *urlString = [NSString stringWithFormat:@"https://maps.google.com/maps?daddr=%f,%f&saddr=Current+Location", location.coordinate.latitude,location.coordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

-(void)findLocationFor{
    CLLocation *location1 = [[CLLocation alloc]initWithLatitude:[_station.latitude doubleValue] longitude:[_station.longitude doubleValue]];
    GeoCoder *geocoder = [[GeoCoder alloc]init];
    [geocoder reverseGeoCode:location1 inBlock:^(NSDictionary *locations) {
        NSString *postcode,*country,*countrycode,*state;
        postcode = locations[@"postcode"];
        country = locations[@"country"];
        countrycode = locations[@"countryCode"];
        state = locations[@"state"];
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        (state.length)?[dict setObject:state forKey:(id)kABPersonAddressStateKey]:nil;
        (country.length)?[dict setObject:country forKey:(id)kABPersonAddressCountryKey]:nil;
        (countrycode.length)?[dict setObject:countrycode forKey:(id)kABPersonAddressCountryCodeKey]:nil;
        (postcode.length)?[dict setObject:postcode forKey:(id)kABPersonAddressZIPKey]:nil;
        
        [self getDirections:dict];
    }];
}

-(void)gestureAction{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 400)];
    UIButton *popButton1 = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 290, 400)];
    EVImageCell *cell = (EVImageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [popButton1 setImage:cell.addedImage.image forState:UIControlStateNormal];
    [popButton1.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [contentView addSubview:popButton1];
    [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
}

-(void)fetchConnectorUsingChargerId{
    [modal show:@"Loading..."];
    EVStations *station = [[EVStations alloc]init];
    station.stationdId = _station.stationdId;
    station.chargerId = _station.chargerId;
    [station fetchConnectorUsingChargerIdWithCompletionBlock:^(BOOL success,id result, NSError *error) {
        [modal hide];
        if(success){
            NSArray *arrayResult = result;
            if(arrayResult.count > 0){
                NSLog(@"Fetch Connectors Response Data : %@",arrayResult);
                connectorArray = [result mutableCopy];
                
                for (int i=0; i < connectorArray.count; i++) {
                    if ([[[connectorArray objectAtIndex:i] objectForKey:@"connectorDesc"] isEqualToString:@"Whole"]) {
                        [connectorArray removeObjectAtIndex:i];
                        [self.tableView reloadData];
                    }
                   // if ([[[connectorArray objectAtIndex:i] objectForKey:@"connectorDesc"] isEqualToString:@"SAE J1772"]) {
                    if(i==0){
                        connectorDesc = [[connectorArray objectAtIndex:i] objectForKey:@"connectorDesc"];
                        connectorId = [[connectorArray objectAtIndex:i] objectForKey:@"ocppConnectorId"];
                        connectorStatus = [[connectorArray objectAtIndex:i] objectForKey:@"chargePointStatus"];
                        connectorIndex = i;
                        NSLog(@"Selected Driver Index : %ld",(long)connectorIndex);
                        [self.tableView reloadData];
                        break;
                    }else{
                        
                    }
                }
            }
            
        }else{
            [modal show:@"Unable to load charger info" for:1.5];
        }
    }];
}

- (IBAction)reservationListButtonClicked:(id)sender
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *startDate = [NSDate date];
    NSDate *sevenHoursAgo = [startDate dateByAddingTimeInterval:-7*60*60];
    NSLog(@"SevenHoursAgo date : %@", [dateFormat stringFromDate:sevenHoursAgo]);
    NSTimeInterval timeInMiliseconds = [sevenHoursAgo timeIntervalSince1970]*1000;
    double startTime = timeInMiliseconds;
    
    NSDate *endDate = [self dateWithHour:23 minute:59 second:59];
    NSLog(@"End date : %@", [dateFormat stringFromDate:endDate]);
    NSTimeInterval timeInMilliseconds2 = [endDate timeIntervalSince1970]*1000;
    double endTime = timeInMilliseconds2;
    NSLog(@"end timestamp = %f",endTime);
    
    EVReservationListViewController *evReserveViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"reservationListTest"];
    [evReserveViewcontroller setCurrentconnectorid:connectorId];
    [evReserveViewcontroller setReservationData:reservationList];
    [evReserveViewcontroller setCurrentstation:_station];
    [evReserveViewcontroller setCurrentconnctIndex:[NSString stringWithFormat:@"%ld",(long)connectorIndex]];
    [evReserveViewcontroller setCurrentStartTime:[NSString stringWithFormat:@"%1.0f", startTime]];
    [evReserveViewcontroller setCurrentEndTime:[NSString stringWithFormat:@"%1.0f", endTime]];
    [self.navigationController pushViewController:evReserveViewcontroller animated:YES];
}

-(NSDate *) dateWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSYearCalendarUnit|
                                    NSMonthCalendarUnit|
                                    NSDayCalendarUnit
                                               fromDate:[NSDate date]];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}

-(void)showModalWithMessage:(NSString*)message {
    [modal show:message];
}

-(void)showModalWithMessage:(NSString*)message forDuration:(CGFloat)duration {
    [modal show:message for:duration];
}

-(void)hideModal {
    [modal hide];
}

@end
