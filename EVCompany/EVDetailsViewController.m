//
//  EVDetailsViewController.m
//  EVCompany
//
//  Created by Srishti on 19/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVDetailsViewController.h"
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
#import "EVModal.h"


@interface EVDetailsViewController (){
    NSArray *arrayDetails;
    NSArray *connectorArray;
    UIButton *reserveListButton;
    UIButton *reserveButton;
    
    NSURL *url;
    NSUInteger index;
    NSManagedObjectContext *managedObjectContext;
    NSInteger driverIndex;
    NSString *connectorDesc;
    NSString *connectorId;
    NSString *connectorStatus;
    UILabel *labelTitle;
    UILabel *labelAddress;
    EVModal *modal;
}

@end

@implementation EVDetailsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"--------------EVDetailsViewController--------------");
/*  connectorDesc = @"";
    connectorId = @"";
    [self fetchConnectorUsingChargerId]; */
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
    
    if(_station.imageName.length > 0){
        arrayDetails = @[@"Photo Added",@"Distance",@"Status",@"Usage Type",@"Charging Level",@"Access Information",@"Connector Types",@"Operator",@"Contact Telephone",@"",@""];
        index = 1;
    }
    else
        arrayDetails = @[@"Distance",@"Status",@"Usage Type",@"Charging Level",@"Access Information",@"Connector Types",@"Operator",@"Contact Telephone",@"",@""];
    
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
    
    
    NSArray *tempArray2;
    if([[EVUser currentUser]userId])
        tempArray2= [[NSArray alloc] initWithObjects:favourite,buttonShare,direction,buttonRoute,nil];
    else
        tempArray2= [[NSArray alloc] initWithObjects:buttonShare,direction,nil];
    self.navigationItem.rightBarButtonItems=tempArray2;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    NSString *addressString = _station.imageName.length > 0?[NSString stringWithFormat:@"%@",_station.adderssline1]: [NSString stringWithFormat:@"%@,%@,%@,%@",_station.adderssline1,_station.town,_station.stateOrProvince,_station.postCode];
    labelTitle.frame = CGRectMake(0, 5, self.view.frame.size.width, [self getHeightForString:_station.title  forFont:[labelTitle font] forConstraintSize:CGSizeMake(320, 999)].height);
    labelAddress.frame = CGRectMake(0, labelTitle.frame.size.height, self.view.frame.size.width, [self getHeightForString:addressString  forFont:[labelAddress font] forConstraintSize:CGSizeMake(320, 999)].height+5);
}

-(void)shareAction:(id)sender{
//     Electric Car (EV) Charging Station at - Address: Zaferaniye asef 1th ave, Description: - Information provided by PlugShare, the world's most popular map for finding electric car (EV) charging stations.
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
//    EVRouteViewController *evRouteViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"route"];
//    [evRouteViewcontroller setStation:_station];
//    [self.navigationController pushViewController:evRouteViewcontroller animated:YES ];
}

-(void)favoriteAction{
    [modal show:@"Loading..."];
    EVStations *stations = _station;
    if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ] isKindOfClass:[EVImageCell class]]){
    EVImageCell *cell = (EVImageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    stations.image = cell.addedImage.image;
    }
    stations.userId = [[EVUser currentUser] userId];
    [stations makeFavouritewithCompletionBlock:^(BOOL success, id result, NSError *error) {
        NSLog(@"Favourite Service Response Data : %@",result);
        if(success){
            [modal show:@"Success" for:1.5];
        }else {
            [modal show:@"Failed" for:1.5];
            [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Already added as Favorite." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0 && _station.imageName.length > 0){
        index = 1;
        NSString *cellIdentifier = @"cellImage";
        EVImageCell *cell = (EVImageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[EVImageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        cell.labelTitle.text = arrayDetails[indexPath.row];
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://revitalizechargingsolutions.com/rcsappdatabase/stations/%@",_station.imageName ]];
        cell.addedImage.frame = CGRectMake(153, 2, 35, 35);
        [cell.addedImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return  cell;
        
    }else{
        NSString *cellIdentifier = @"cellText";
        EVDetailCell *cell = (EVDetailCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[EVDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        
        
        cell.labelTitle.text = arrayDetails[indexPath.row];
        cell.labelDetails.numberOfLines = 1;
        
        if(indexPath.row == 0+index){
            float distace = [self calculateDistance:_station.latitude :_station.longitude];
            cell.labelDetails.text =  [NSString stringWithFormat:@"%.2f Mi",distace];
        }
        else if(indexPath.row == 1+index)
            cell.labelDetails.text =  _station.status;
        else if(indexPath.row == 2+index)
            cell.labelDetails.text =  [self findChargingUsageTypes:_station.usageType];
        else if (indexPath.row == 3+index){
            cell.labelDetails.text = [self findChargingLevel:_station.powerLevel];
        }
        else if(indexPath.row == 4+index){
            if(![_station.descriptions isKindOfClass:[NSNull class]]){
                cell.labelDetails.text = _station.descriptions;
                
            }
        }
        else if (indexPath.row == 5+index){
            cell.labelDetails.text = _station.connectorType;
        }
        else if (indexPath.row == 6+index){
            cell.labelDetails.text = _station.operatorInfo;
        }
        else if(indexPath.row == 7+index){
            if(![_station.contactTelephone1 isKindOfClass:[NSNull class]])
            //{
                //if ([_station.contactTelephone1 isEqualToString:@"(null)"]) {
                //    cell.labelDetails.text = @"";
                //}else{
                    cell.labelDetails.text =  [_station.contactTelephone1 componentsSeparatedByString:@" "][0];
                //}
            //}
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else{
            cell.labelDetails.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.labelDetails.frame = CGRectMake(153, 0, 167, MAX([self getHeightForString:cell.labelDetails.text  forFont:[cell.labelDetails font] forConstraintSize:CGSizeMake(167, 999)].height,38.0));
        cell.labelDetails.numberOfLines = 4;
        
        
        return cell;
    }
   
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    labelTitle = [[UILabel alloc]init];
    labelTitle.numberOfLines = 2;
    labelTitle.text = _station.title;
   //a labelTitle.text = _station.siteName;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
    labelTitle.font = [UIFont systemFontOfSize:14];
    labelTitle.frame = CGRectMake(0, 5, self.view.frame.size.width, [self getHeightForString:_station.title  forFont:[labelTitle font] forConstraintSize:CGSizeMake(320, 999)].height);
    
    NSString *addressString = _station.imageName.length > 0?[NSString stringWithFormat:@"%@",_station.adderssline1]: [NSString stringWithFormat:@"%@,%@,%@,%@",_station.adderssline1,_station.town,_station.stateOrProvince,_station.postCode];
    labelAddress = [[UILabel alloc]init];
    labelAddress.text = addressString;
  //a  labelAddress.text = _station.address;
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
            if(![_station.descriptions isKindOfClass:[NSNull class]]){
                displayContent = _station.descriptions;
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
        EVListReservationViewController *listReservation = [self.storyboard instantiateViewControllerWithIdentifier:@"listReservationVC"];
        [listReservation setStation:_station];
        [listReservation setConnectorDesc:connectorDesc];
        [listReservation setConnectorId:connectorId];
        [listReservation setConnctIndex:[NSString stringWithFormat:@"%ld",(long)driverIndex]];
        [self.navigationController pushViewController:listReservation animated:YES];
    }
}

- (void)reserveButtonPressed{
  if([_station.ocppChargePointStatus isEqualToString:@"Offline"]){
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Cannot do reservation on offline station." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
      [alert show];
    }else{
        if ([connectorId isEqualToString:@""] || [connectorDesc isEqualToString:@""] || [connectorId isKindOfClass:[NSNull class]] || [connectorDesc isKindOfClass:[NSNull class]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please select connector" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *phoneURLString;
    if(indexPath.row == 0 && _station.imageName.length > 0)
        [self gestureAction];
    else if(indexPath.row == arrayDetails.count - 3){
        phoneURLString = [NSString stringWithFormat:@"telprompt:%@", _station.contactTelephone1];
        [self sendCall:phoneURLString];
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
    }else{
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
    EVStations *station = [[EVStations alloc]init];
    station.stationdId = _station.stationdId;
    station.chargerId = _station.chargerId;
    [station fetchConnectorUsingChargerIdWithCompletionBlock:^(BOOL success,id result, NSError *error) {
        if(success){
            NSArray *arrayResult = result;
            if(arrayResult.count > 0){
                NSLog(@"Fetch Connector Responce Data : %@",arrayResult);
                connectorArray = result;
           //a     [self.tableView reloadData];
            }
            
        }else{
            //[self showAlert];
        }
    }];
}

@end
