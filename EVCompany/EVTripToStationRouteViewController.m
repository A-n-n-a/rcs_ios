//
//  EVTripToStationRouteViewController.m
//  EVCompany
//
//  Created by GridScape on 4/29/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import "EVTripToStationRouteViewController.h"
#import "MKAnnotationView+WebCache.h"
#import "ECSlidingViewController.h"
#import "EVStations.h"
#import <CoreLocation/CoreLocation.h>
#import "AFHTTPClient.h"
#import "EVClientApi.h"
#import "EVStations.h"
#import "EVMapPin.h"
#import "GeoCoder.h"
#import "EVDetailsViewController.h"
#import "EVOCPPDetailsViewController.h"
#import "EVMapTableViewCell.h"
#import "EVAppDelegate.h"
#import "ECSlidingViewController.h"
#import "EVSearchViewController.h"
#import "EVMenuViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "EVAppDelegate.h"
#import "Filter.h"
#import "config.h"
#import "EVUser.h"
#import "EVAppDelegate.h"
#import "EVModal.h"

@interface EVTripToStationRouteViewController ()<MKMapViewDelegate,MKAnnotation,ADBannerViewDelegate>{
    CLLocation  *dealLocation ;
    CLLocation *sourceLoc;
    
    NSManagedObjectContext *managedObjectContext;
    //CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSString *latitude;
    NSString *longitude;
    
    NSMutableArray *arrayStations;
    NSMutableArray *arrayCurrentStations;
    NSMutableArray *arrayCurrentAnnotations;
    NSMutableArray *arrayAnnotations;
    
    NSMutableArray *arrayusage;
    
    NSMutableArray *arrayResultFetchFromServer;
    NSMutableArray *arrayResultFetchFromOCPPServer;
    NSArray *arrayFilterData;
    NSString *state;
    NSArray *lasrUpdatedAnnotations;
    NSString *searchedString;
    MKPointAnnotation *point;
    UIView *viewSearch;
    UIView *viewbanner;
    UISearchBar *searchBar;
    CLGeocoder * _geocoder;
    Filter *filter;;
    EVMapPin *pin,*currentEVMapPin;
    UILabel *labelSearch;
    
    EVModal *modal;
    
    int count;
    BOOL stop;
    BOOL isCurrent,isSearch;
    BOOL isFetch,isRefresh;
    IBOutlet ADBannerView *bannerAd;
    EVAppDelegate *AppDelegate;
}

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EVTripToStationRouteViewController
@synthesize isDirection;
@synthesize routeLine;
@synthesize routeLineView;
@synthesize ToLati,FromLati,FromLongi;
@synthesize ToLongi,imageName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"--------------EVTripToStationRouteViewController--------------");
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

     self.navigationItem.title = @"Station Route";
     AppDelegate = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
     _geocoder = [[CLGeocoder alloc] init];
     [self arrayInitialisation];
     if(_station){
         [self addSelectedAnnotation];
         [self zooming:arrayAnnotations];
     }
    /*else if(_searchStringfromEvstation.length>0 ){
     [self geocodeFromTimer:_searchStringfromEvstation];
     }*/
     else{
         locationManager = [[CLLocationManager alloc] init];
         locationManager.delegate = self;
        #ifdef __IPHONE_8_0
         if(IS_OS_8_OR_LATER) {
             // Use one or the other, not both. Depending on what you put in info.plist
             [locationManager requestWhenInUseAuthorization];
             [locationManager requestAlwaysAuthorization];
         }
        #endif
         if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
             [locationManager startUpdatingLocation];
             [modal show:@"Retrieving stations near you!"];
         } else {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                                             message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert setTag:4];
             [alert show];
         }
     }
     
     self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"];
     // allocate inmobi
    
     [self fetchDataFromCoreData];;
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
}

-(void)arrayInitialisation{
    stop = NO;
    isFetch = NO;
    count = 0;
    arrayAnnotations = [[NSMutableArray alloc]init];
    arrayCurrentAnnotations = [[NSMutableArray alloc]init];
    arrayStations = [[NSMutableArray alloc]init];
    arrayCurrentStations = [[NSMutableArray alloc]init];
    arrayusage = [[NSMutableArray alloc]init];
    arrayResultFetchFromServer = [[NSMutableArray alloc]init];
    arrayResultFetchFromOCPPServer = [[NSMutableArray alloc] init];
}

-(void)fetchDataFromCoreData{
    managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Filter" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        filter=results[0];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.screenName = @"Map View";
    bannerAd.backgroundColor=[UIColor clearColor];
    bannerAd.delegate = self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = locations[0];
    EVAppDelegate *appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegete.currentLocation = locations[0];
    if (currentLocation != nil && !point){
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        point = [[MKPointAnnotation alloc] init];
        point.coordinate = currentLocation.coordinate;
        point.title = @"Current Location";
        [self fetchStationUsingLocationWithLatitude:[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude] AndLongitude:[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)directionParser:(id)parser didFailParsingWithError:(NSError*)error{
    if (mapFlag==1) {
        mapFlag++;
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!!"
                                                            message:@"No Route Found" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}
-(void)directionParser:(id)parser didFInishParsingPolyline:(MKPolyline*)polyline{
    [self setRouteLine:polyline];
    [mapRouteView addOverlay:self.routeLine];
    
}
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    if(annotation==annotationUser)
    {
        annView.pinColor = MKPinAnnotationColorGreen;
        
    }
    else
    {
        [annView setEnabled:YES];
        [annView setCanShowCallout:YES];
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(calloutAction:) forControlEvents:UIControlEventTouchUpInside];
        //rightButton.tag=myAnnotation1.tagIndex;
        annView.rightCalloutAccessoryView = rightButton;
        annView.pinColor = MKPinAnnotationColorRed;
        
    }
    annView.canShowCallout = YES;
    
    return annView;
}

#pragma mark - MapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayView* overlayView = nil;
    
    if(overlay == self.routeLine)
    {
        //if we have not yet created an overlay view for this overlay, create it now.
        if(nil == self.routeLineView)
        {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine] ;
            self.routeLineView.fillColor = [UIColor blueColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 3;
        }
        
        overlayView = self.routeLineView;
        
    }
    return overlayView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    id<MKAnnotation>annotation = view.annotation;
    if ([annotation isKindOfClass:[EVMapPin class]])
        currentEVMapPin = (EVMapPin*) view.annotation;
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
    
    // Add an annotation
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = userLocation.coordinate;
    annotationPoint.title = @"Where am I?";
    annotationPoint.subtitle = @"I'm here!!!";
}

#pragma mark adbanner delegates
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"bannerview did not receive any banner due to %@", error);}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{NSLog(@"bannerview was selected");}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{return willLeave;}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {NSLog(@"banner was loaded");}



-(void)addSelectedAnnotation{
    [arrayAnnotations removeAllObjects];
    NSString *addressString;
    NSString *titleString;
    if([_station.isRCS isEqualToString:@"YES"]){
        addressString = [NSString stringWithFormat:@"%@",_station.adderssline1];
        titleString = [NSString stringWithFormat:@"%@(%@)",_station.title,_station.chargerId];
    }else{
        addressString = [NSString stringWithFormat:@"%@,%@,%@",_station.adderssline1,_station.town,_station.stateOrProvince];
        titleString = _station.title;
    }
    EVMapPin *selectedPin = [[EVMapPin alloc]initWithCoordinates:CLLocationCoordinate2DMake([_station.latitude doubleValue], [_station.longitude doubleValue]) placeName:titleString description:addressString tag:arrayStations.count-1 withStation:_station];
    [arrayAnnotations addObject:selectedPin];
    [_mapView addAnnotations:arrayAnnotations];
}

-(void)zooming:(NSArray *)annotationsArray{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotationsArray) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    [_mapView setVisibleMapRect:zoomRect animated:YES];
    // [self.mapView selectAnnotation:point animated:YES];
    
}

- (void)orientationChanged:(NSNotification *)notification{
    if(isSearch){
        viewSearch.frame = CGRectMake(0, 50, self.view.frame.size.width, 70);
        labelSearch.frame = CGRectMake(2, 5, self.view.frame.size.width, 30);
        searchBar.frame = CGRectMake(0, 30, self.view.frame.size.width, 44);
    }
}


-(void)fetchStationUsingLocationWithLatitude:(NSString *)selectedLatitude AndLongitude:(NSString *)selectedLongitude{
    __weak typeof(self) weakSelf = self;
    [arrayResultFetchFromServer removeAllObjects];
    EVStations *station = [[EVStations alloc]init];
    station.latitude = selectedLatitude;
    station.longitude = selectedLongitude;
    if(filter){
        NSArray *arrayLevel = [filter.chargingLevel componentsSeparatedByString:@","];
        station.powerLevel = arrayLevel.count >0?filter.chargingLevel:@"1,2,3";
        NSArray *arrayUsage = [filter.usageType componentsSeparatedByString:@","];
        station.usageType = arrayUsage.count >0?filter.usageType:@"0,1,2,3,4,5,6,7";
    }else{
        station.powerLevel = @"1,2,3";
        station.usageType = @"0,1,2,3,4,5,6,7";
    }
    [station fetchStationsUsingLatitudeAndLongitudeWithCompletionBlock:^(BOOL success,id result, NSError *error) {
        //a   [station fetchOCPPStationsUsingLatitudeAndLongitudeWithCompletionBlock:^(BOOL success,id result, NSError *error) {
        if(success){
            NSArray *arrayResult = result;
            NSLog(@"RCS data count : %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromServer = [arrayResult mutableCopy];
            }
            [weakSelf fetchOCPPStationUsingLocationWithLatitude:selectedLatitude AndLongitude:selectedLongitude];
            //a  [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            
        }else{
            [weakSelf fetchOCPPStationUsingLocationWithLatitude:selectedLatitude AndLongitude:selectedLongitude];
            //a    [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            //[self showAlert];
        }
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        //[locationManager startUpdatingLocation];
        //[modal show:@"Retrieving stations near you!"];
    }
}

-(void)fetchOCPPStationUsingLocationWithLatitude:(NSString *)selectedLatitude AndLongitude:(NSString *)selectedLongitude{
    __weak typeof(self) weakSelf = self;
    [arrayResultFetchFromOCPPServer removeAllObjects];
    EVStations *station = [[EVStations alloc]init];
    station.latitude = selectedLatitude;
    station.longitude = selectedLongitude;
    
    [station fetchOCPPStationsUsingLatitudeAndLongitudeWithCompletionBlock:^(BOOL success,id result, NSError *error) {
        if(success){
            NSArray *arrayResult = result;
            NSLog(@"OCPP Data Count : %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromOCPPServer = [arrayResult mutableCopy];
            }
            [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            
        }else{
            [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            //[self showAlert];
        }
        
    }];
}

-(void)fetchStations:(NSString *)latitudes :(NSString *)longitudes :(NSString *)zipcode{
    __weak typeof(self) weakSelf = self;
    NSDictionary *dict = [self setParameterwithZip:zipcode latitude:latitudes longitude:longitudes];
    
    [arrayCurrentAnnotations removeAllObjects];
    [arrayCurrentStations removeAllObjects];
    [[EVClientApi sharedClient] fetchStationWithParameters:dict Success:^(id result) {
        NSArray *arrayFetchFromApi = result;
        NSLog(@"API data count : %lu",(unsigned long)arrayFetchFromApi.count);
        if(  arrayFetchFromApi.count == 0 && arrayResultFetchFromServer.count == 0 && arrayResultFetchFromOCPPServer.count == 0 && !stop){
            [self showAlert];
        }else{
            [weakSelf combineStationFromServerAndApiWithArray:arrayFetchFromApi];
        }
    } Failure:^(NSError *error) {
        if(!stop)
            [self showAlert];
    }];
    
}

-(void)fetchStationsWithZipCode:(NSString *)zipcode{
    __weak typeof(self) weakSelf = self;
    NSDictionary *dict = [self setParameterwithZip:zipcode latitude:nil longitude:nil];
    
    [arrayCurrentAnnotations removeAllObjects];
    [arrayCurrentStations removeAllObjects];
    //a    [[EVClientApi sharedClient] fetchStationWithParameters:dict Success:^(id result) {
    
    //a        NSArray *arrayFetchFromApi = result[@"fuel_stations"] ;
    NSArray *arrayFetchFromApi = nil;
    if(arrayFetchFromApi.count == 0 && arrayResultFetchFromServer.count == 0 && !stop){
        [self showAlert];
    }else
        [weakSelf combineStationFromServerAndApiWithArray:arrayFetchFromApi];
    
    //a    } Failure:^(NSError *error) {
    //a        if(!stop)
    //a            [self showAlert];
    //a    }];
    
}

-(void)combineStationFromServerAndApiWithArray:(NSArray *)arrayFetchFromApi{
    __weak typeof(self) weakSelf = self;
    NSArray *arrayResult ;
    arrayResult = (arrayFetchFromApi.count > 0)?
    [arrayFetchFromApi arrayByAddingObjectsFromArray:[arrayResultFetchFromServer copy]] :
    arrayResultFetchFromServer;
    arrayResult = (arrayResultFetchFromOCPPServer.count > 0)?
    [arrayResult arrayByAddingObjectsFromArray:[arrayResultFetchFromOCPPServer copy]] :
    arrayResult;
    NSLog(@"Combine array result count : %lu",(unsigned long)arrayResult.count);
    if(arrayResult.count == 0 && !stop){
        [self showAlert];
    }else{
        [arrayResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            if(arrayResultFetchFromServer.count != 0 && ((arrayFetchFromApi.count == 0 && !(idx > (arrayFetchFromApi.count+arrayResultFetchFromServer.count-1)))|| (idx > arrayFetchFromApi.count - 1 && !(idx > (arrayFetchFromApi.count+arrayResultFetchFromServer.count-1))))){
                EVStations *stationFromServer = [[EVStations alloc] initWithDataFromServerWithDictionary:dict];
                [arrayCurrentStations addObject:stationFromServer];
                [arrayStations addObject:stationFromServer];
            }else if(arrayFetchFromApi.count == 0 || idx > (arrayFetchFromApi.count+arrayResultFetchFromServer.count -1)){
                EVStations *stationFromServer = [[EVStations alloc] initWithDataFromOCPPServerWithDictionary:dict];
                [arrayCurrentStations addObject:stationFromServer];
                [arrayStations addObject:stationFromServer];
            }
            else{
                EVStations *station = [[EVStations alloc] initWithDataFromDictionary:dict];
                [arrayCurrentStations addObject:station];
                [arrayStations addObject:station];
            }
            if(idx == arrayResult.count-1){
                [self sortArray];
            }
        }];
        NSLog(@"Total station count : %lu",(unsigned long)arrayCurrentStations.count);
    }
}

-(void)allocatePin:(EVStations *)station{
    NSString *addressString;
    NSString *titleString;
    if([station.isRCS isEqualToString:@"YES"]){
        addressString = [NSString stringWithFormat:@"%@",station.adderssline1];
        titleString = [NSString stringWithFormat:@"%@(%@)",station.title,station.chargerId];
    }else{
        addressString = [NSString stringWithFormat:@"%@,%@,%@,%@",station.adderssline1,station.town,station.stateOrProvince,station.postCode];
        titleString = station.title;
    }
    
    pin = [[EVMapPin alloc]initWithCoordinates:CLLocationCoordinate2DMake([station.latitude doubleValue], [station.longitude doubleValue]) placeName:titleString description:addressString tag:count withStation:station];
    [arrayCurrentAnnotations addObject:pin];
    [arrayAnnotations addObject:pin];
    count += 1;
}

-(void)showAlert{
    (([filter.chargingLevel componentsSeparatedByString:@","].count == 3 && [filter.usageType componentsSeparatedByString:@","].count == 8) || !filter )?[modal show:@"No stations found"]:[modal show:@"No Stations Found Please adjust your Filter."];
}

-(NSDictionary*)setParameterwithZip:(NSString*)zipcode latitude:(NSString *)selectedLatitude longitude:(NSString *)selectedLongitude{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:selectedLongitude forKey:@"longitude"];
    [dict setValue:selectedLatitude forKey:@"latitude"];
    [dict setValue:@"2000" forKey:@"distance"];
    [dict setValue:@"Miles" forKey:@"distanceunit"];
    if(filter){
        if(filter.chargingLevel.length>0){
            ([[filter.chargingLevel componentsSeparatedByString:@","] count] != 3)?
            [dict setValue:filter.chargingLevel forKey:@"levelid"]:nil;
        }
        else
            [dict setValue:@"4" forKey:@"levelid"];
        
        if(filter.usageType.length>0){
            ([[filter.usageType componentsSeparatedByString:@","] count] != 8)?
            [dict setValue:filter.usageType forKey:@"usagetypeid"]:nil;
        }
        else
            [dict setValue:@"8" forKey:@"usagetypeid"];
    }
    [dict setValue:@"json" forKey:@"output"];
    [dict setValue:@"500" forKey:@"maxresults"];
    return dict;
}

-(void)sortArray{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distanceInMiles" ascending:YES];
    [arrayStations sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSLog(@"Sort array count : %lu",(unsigned long)[arrayStations count]);
    for(int i=0;i<arrayStations.count;i++){
        EVStations *station = (EVStations *)[arrayStations objectAtIndex:i];
        float distace = [station.distance floatValue];
        NSLog(@"Station distance : %@",[NSString stringWithFormat:@"%.2f Mi",distace]);
    }
    [modal show:@"Success!" for:1.5];
    
    
    mapFlag=1;
    double lat  = [latitude doubleValue];
    double lon  = [longitude doubleValue];
    EVStations *stn = (EVStations *)[arrayStations objectAtIndex:0];
    double stnlat  = [stn.latitude doubleValue];
    double stnlon  = [stn.longitude doubleValue];
    //dealLocation = [[CLLocation alloc] initWithLatitude:[@"22.6819361" doubleValue] longitude:[@"72.8752975" doubleValue]];
    dealLocation = [[CLLocation alloc] initWithLatitude:stnlat longitude:stnlon];
    _station = stn;
    //[self addSelectedAnnotation];
    //[self zooming:arrayAnnotations];
    
    [arrayStations removeAllObjects];
    NSString *addressString;
    NSString *titleString;
    if([_station.isRCS isEqualToString:@"YES"]){
        addressString = [NSString stringWithFormat:@"%@",_station.adderssline1];
        titleString = [NSString stringWithFormat:@"%@(%@)",_station.title,_station.chargerId];
    }else{
        addressString = [NSString stringWithFormat:@"%@,%@,%@",_station.adderssline1,_station.town,_station.stateOrProvince];
        titleString = _station.title;
    }
    EVMapPin *selectedPin = [[EVMapPin alloc]initWithCoordinates:CLLocationCoordinate2DMake([_station.latitude doubleValue], [_station.longitude doubleValue]) placeName:titleString description:addressString tag:arrayStations.count-1 withStation:_station];
    [arrayAnnotations addObject:selectedPin];
    [mapRouteView addAnnotations:arrayAnnotations];
    
    
    //AddressAnnotation *annotation = [[AddressAnnotation alloc] initWithCoordinate:dealLocation.coordinate];
    //[mapRouteView addAnnotation:annotation];
    
     sourceLoc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
     //sourceLoc = [[CLLocation alloc] initWithLatitude:[FromLati doubleValue] longitude:[FromLongi doubleValue]];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.9,0.9);
    MKCoordinateRegion region = MKCoordinateRegionMake(sourceLoc.coordinate, span);
    [mapRouteView setRegion:region];
    
     DirectionParser *directionParser = [[DirectionParser alloc] init];
     [directionParser setDelegate:self];
     [directionParser findDirectionArrayFrom:dealLocation to:sourceLoc];
     annotationUser= [[AddressAnnotation alloc] initWithCoordinate:sourceLoc.coordinate];
     [mapRouteView addAnnotation:annotationUser];
}

-(void)calloutAction:(id)sender{
    UIButton *button = sender;
    [self gotoStationDetailView:button.tag];
}

-(void)gotoStationDetailView:(NSUInteger)index{
    if ([currentEVMapPin.stationSelected.isRCS isEqualToString:@"YES"]) {
        EVOCPPDetailsViewController *evOCPPDetailViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"evOCPPDetails"];
        [evOCPPDetailViewcontroller setStation:currentEVMapPin.stationSelected];
        [self.navigationController pushViewController:evOCPPDetailViewcontroller animated:YES];
    }else{
        EVDetailsViewController *evDetailViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"evDetails"];
        [evDetailViewcontroller setStation:currentEVMapPin.stationSelected];
        [self.navigationController pushViewController:evDetailViewcontroller animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}


@end
