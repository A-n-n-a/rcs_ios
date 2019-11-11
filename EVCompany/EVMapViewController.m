//
//  EVMapViewController.m
//  EVCompany
//
//  Created by Srishti on 11/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVMapViewController.h"
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



@interface EVMapViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDelegate,UISearchBarDelegate,zoomtoSelectedLocation,ADBannerViewDelegate>
{
    NSManagedObjectContext *managedObjectContext;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSString *latitude;
    NSString *longitude;
    NSMutableData *receivedData;
    NSMutableArray *arrayStations;
    NSMutableArray *arrayCurrentStations;
    NSMutableArray *arrayCurrentAnnotations;
    NSMutableArray *arrayAnnotations;
    NSMutableArray *arraylevels;
    NSMutableArray *arrayusage;
    NSMutableArray *arrayStatus;
    NSMutableArray *arrayResultFetchFromServer;
    NSMutableArray *arrayResultFetchFromOCPPServer;
    NSArray *arrayFilterData;
    NSString *state;
    NSArray *lasrUpdatedAnnotations;
    NSString *searchedString;
    CLLocation *searchLocation;
    MKPointAnnotation *point;
    UIView *viewSearch;
    UIView *viewbanner;
    UISearchBar *searchBar;
    CLGeocoder * _geocoder;
    Filter *filter;
    EVMapPin *pin,*currentEVMapPin;
    UILabel *labelSearch;
    NSTimer *timerRefresh;
    UIActivityIndicatorView *activityIndicator;
    EVModal *modal;
    
    int count;
    BOOL stop;
    BOOL isCurrent,isSearch;
    BOOL isFetch,isRefresh;
    IBOutlet ADBannerView *bannerAd;
    EVAppDelegate *AppDelegate;
    bool isVisible;
    
}
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation EVMapViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"initWithNibName");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}


- (void)viewDidLoad{
    NSLog(@"viewDidLoad");
    NSLog(@"--------------EVMapViewController--------------");
    self.navigationItem.title = kNAV_TITLE;
    AppDelegate = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSLog(@"Device Token : %@",AppDelegate.device_token);
    NSLog(@"Device tagid : %@",[EVUser currentUser].tagId);
    NSLog(@"User : %@",[EVUser currentUser].email);
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSString *tzName = [timeZone name];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
    
    [super viewDidLoad];
    _geocoder = [[CLGeocoder alloc] init];
    [self arrayInitialisation];
    if(_station){
        [self addSelectedAnnotation];
        [self zooming:arrayAnnotations];
    }else if(_searchStringfromEvstation.length>0 ){
        [self geocodeFromTimer:_searchStringfromEvstation];
    }else{
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        #ifdef __IPHONE_8_0
            if(IS_OS_8_OR_LATER) {
                // Use one or the other, not both. Depending on what you put in info.plist
                [locationManager requestWhenInUseAuthorization];
                [locationManager requestAlwaysAuthorization];
            }
        #endif
        if([CLLocationManager locationServicesEnabled] &&
           [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            [locationManager startUpdatingLocation];
            
            [self showModalWithMessage: @"Retrieving stations near you!"];
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
    
    [self setBarButton];
    [self setRightBarbutton];
        [self fetchDataFromCoreData];;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        timerRefresh = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(refreshRate) userInfo:nil repeats:YES];
}

- (void)viewWillLayoutSubviews {
//    CGRect screenBounds = [[UIScreen mainScreen] bounds];
//    
//    CGRect modalFrame = modal.frame;
//    if (modalFrame.size.height == 0 || modalFrame.size.width == 0) {
//        modalFrame.size = CGSizeMake(160, 160);
//    }
//    modalFrame.origin = CGPointMake((screenBounds.size.width - modalFrame.size.width) / 2, (screenBounds.size.height - modalFrame.size.height) / 2);
//    modal.frame = modalFrame;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)orientationChanged:(NSNotification *)notification{
    if(isSearch){
        viewSearch.frame = CGRectMake(0, 50, self.view.frame.size.width, 70);
        labelSearch.frame = CGRectMake(2, 5, self.view.frame.size.width, 30);
        searchBar.frame = CGRectMake(0, 30, self.view.frame.size.width, 44);
    }
}

-(void)setRightBarbutton{
    NSLog(@"setRightBarbutton");
    UIButton *refreshBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [refreshBarButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    [refreshBarButton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithCustomView:refreshBarButton];
    
    UIButton *searchBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [searchBarButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [searchBarButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithCustomView:searchBarButton];
    
    
    activityIndicator = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    // I've tried Gray, White, and WhiteLarge
    //[activityIndicator startAnimating];
    //activityIndicator.hidden = NO;
    //UIBarButtonItem* spinner = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    
    NSArray *tempArray2= [[NSArray alloc] initWithObjects:search,refresh,nil];
    self.navigationItem.rightBarButtonItems=tempArray2;
}

-(void)refreshAction{
    NSLog(@"refreshAction");
    isRefresh = YES;
    [self arrayInitialisation];
    [self.mapView removeAnnotations:self.mapView.annotations];
    CGPoint pointPin = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:pointPin toCoordinateFromView:self.mapView];
    searchLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self processForwardGeocodingResults:searchLocation searchString:searchedString];
    [self showModalWithMessage:@"Retrieving stations near you!"];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    bannerAd.backgroundColor=[UIColor clearColor];
    bannerAd.delegate = self;
    isVisible = true;
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
    }
}

-(void)setBarButton{
    NSLog(@"setBarButton");
    if(!_needBack){
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
        UIButton *sliderBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [sliderBarButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
        [sliderBarButton setBackgroundImage:[UIImage imageNamed:@"lines.png"] forState:UIControlStateNormal];
        UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithCustomView:sliderBarButton];
        [self.navigationItem setLeftBarButtonItem:barButtonLeft];
    }else{
        //[self setBackBarButton];
    }
}

-(void)setBackBarButton{
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(BackButtonClick:)];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
}

- (IBAction)BackButtonClick:(id)sender{
    NSLog(@"back click");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)arrayInitialisation{
    NSLog(@"arrayInitialisation");
    stop = NO;
    isFetch = NO;
    count = 0;
    arrayAnnotations = [[NSMutableArray alloc]init];
    arrayCurrentAnnotations = [[NSMutableArray alloc]init];
    arrayStations = [[NSMutableArray alloc]init];
    arrayCurrentStations = [[NSMutableArray alloc]init];
    arraylevels = [[NSMutableArray alloc]init];
    arrayStatus = [[NSMutableArray alloc]init];
    arrayusage = [[NSMutableArray alloc]init];
    arrayResultFetchFromServer = [[NSMutableArray alloc]init];
    arrayResultFetchFromOCPPServer = [[NSMutableArray alloc] init];
    receivedData = [[NSMutableData alloc]init];
    
    //    locationManager = [[CLLocationManager alloc] init];
    //    locationManager.delegate = self;
    //    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");
    isVisible = false;
}

-(void)zooming:(NSArray *)annotationsArray{
    NSLog(@"zooming annotationsArray");
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
-(void)zoomToLocationGiven:(BOOL)isCurrentLocation{
    NSLog(@"zoomToLocationGiven isCurrentLocation");
    MKCoordinateRegion region;
    region.center = point.coordinate;
    //Set Zoom level using Span
    MKCoordinateSpan span;
    if(isCurrentLocation){
        span.latitudeDelta = 0.01;
        span.longitudeDelta = 0.01;
    }else{
        span.latitudeDelta = 0.1;
        span.longitudeDelta = 0.1;
    }
    region.span = span;
    [self.mapView setRegion:region animated:YES];
}

-(void)addSelectedAnnotation{
    NSLog(@"addSelectedAnnotation");
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"locationManager didFailWithError");
    [modal hide];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //NSLog(@"locationManager didUpdateLocations");
    currentLocation = locations[0];
    EVAppDelegate *appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegete.currentLocation = locations[0];
    if (currentLocation != nil && !point){
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        point = [[MKPointAnnotation alloc] init];
        point.coordinate = currentLocation.coordinate;
        point.title = @"Current Location";
        NSLog(@"All data load start time ------------:%@",[NSDate date]);
        [self fetchStationUsingLocationWithLatitude:[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude] AndLongitude:[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude]];
    }
}

-(void)refreshRate{
    NSLog(@"refreshRate");
    if (currentLocation != nil && !isRefresh && !isSearch){
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        NSLog(@"current latitude : %@ and longitude : %@",latitude,longitude);
        point = [[MKPointAnnotation alloc] init];
        point.coordinate = currentLocation.coordinate;
        point.title = @"Current Location";
        [self fetchStationUsingLocationWithLatitude:[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude] AndLongitude:[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"locationManager didChangeAuthorizationStatus");
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
    }
}

-(void)fetchDataFromCoreData{
    NSLog(@"fetchDataFromCoreData");
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

-(void)fetchStateName:(double )latitudes :(double)longitudes{
    NSLog(@"fetchStateName latitudes longitudes");
    __weak typeof(self) weakSelf = self;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:latitudes longitude:longitudes];
    GeoCoder *reverseGeocoder = [GeoCoder new];
    [reverseGeocoder reverseGeoCode:location inBlock:^(NSDictionary *statename) {
        state = statename[@"state"];
        if(!isFetch)
            [weakSelf fetchStationsFromServer:[NSString stringWithFormat:@"%.8f", latitudes] :[NSString stringWithFormat:@"%.8f", longitudes]:nil];
    }];
}

-(void)fetchStationsFromServer:(NSString *)latitudes :(NSString *)longitudes :(NSString *)zipcode{
    NSLog(@"fetchStationsFromServer");
    isFetch = YES;
    __weak typeof(self) weakSelf = self;
    [arrayResultFetchFromServer removeAllObjects];
    EVStations *station = [[EVStations alloc]init];
    if(zipcode.length > 0){
        station.keyType = @"postcode";
        station.keyValue = zipcode;
    }else{
        station.keyType = @"state";
        station.keyValue = state;
    }
    if(filter){
        NSArray *arrayLevel = [filter.chargingLevel componentsSeparatedByString:@","];
        station.powerLevel=(arrayLevel.count > 0)?[arrayLevel componentsJoinedByString:@","]:@"1,2,3";
        NSArray *arrayUsagetype = [filter.usageType componentsSeparatedByString:@","];
        station.usageType=(arrayUsagetype.count > 0)?[arrayUsagetype componentsJoinedByString:@","]:@"0,1,2,3,4,5,6,7";
    }else{
        station.powerLevel = @"1,2,3";
        station.usageType = @"0,1,2,3,4,5,6,7";
    }
    [station fetchStationsWithCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            NSArray *arrayResult = result;
            if(arrayResult.count > 0){
                arrayResultFetchFromServer = [arrayResult mutableCopy];
            }
        }
        [weakSelf fetchStationsWithZipCode:zipcode];
    }];
    
}
-(void)fetchStationUsingLocationWithLatitude:(NSString *)selectedLatitude AndLongitude:(NSString *)selectedLongitude{
    NSLog(@"fetchStationUsingLocationWithLatitude selectedLatitude");
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
    NSLog(@"RCS API start time ---------------------------: %@",[NSDate date]);
    [station fetchStationsUsingLatitudeAndLongitudeWithCompletionBlock:^(BOOL success,id result, NSError *error) {
 //a   [station fetchOCPPStationsUsingLatitudeAndLongitudeWithCompletionBlock:^(BOOL success,id result, NSError *error) {
        if(success){
            NSLog(@"RCS API stop time ---------------------------: %@",[NSDate date]);
            NSArray *arrayResult = result;
            NSLog(@"RCS data count : %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromServer = [arrayResult mutableCopy];
            }
            [weakSelf fetchOCPPStationUsingLocationWithLatitude:selectedLatitude AndLongitude:selectedLongitude];
          //a  [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            
        }else{
            NSLog(@"RCS API stop time ---------------------------: %@",[NSDate date]);
            //[[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"RCS API Fail with result : %@ and Error : %@",result,(error == NULL?@"":[error localizedDescription])] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            [weakSelf fetchOCPPStationUsingLocationWithLatitude:selectedLatitude AndLongitude:selectedLongitude];
        //a    [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            //[self showAlert];
        }
        
    }];
}

-(void)fetchOCPPStationUsingLocationWithLatitude:(NSString *)selectedLatitude AndLongitude:(NSString *)selectedLongitude{
    NSLog(@"fetchOCPPStationUsingLocationWithLatitude selectedLatitude");
    __weak typeof(self) weakSelf = self;
    [arrayResultFetchFromOCPPServer removeAllObjects];
    EVStations *station = [[EVStations alloc]init];
    station.latitude = selectedLatitude;
    station.longitude = selectedLongitude;
    NSLog(@"OCPP API start time ---------------------------: %@",[NSDate date]);
    [station fetchOCPPStationsUsingLatitudeAndLongitudeWithCompletionBlock:^(BOOL success,id result, NSError *error) {
        if(success){
            NSLog(@"OCPP API stop time ---------------------------: %@",[NSDate date]);
            NSArray *arrayResult = result;
            NSLog(@"OCPP Data Count : %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromOCPPServer = [arrayResult mutableCopy];
            }else{
                //[[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"OCPP API Stations :%lu",(unsigned long)arrayResult.count] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            }
            [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            
        }else{
           // [[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"OCPP API Fail with result : %@ and Error : %@",@"Fail",(error == NULL?@"":[error localizedDescription])] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            NSLog(@"OCPP API stop time ---------------------------: %@",[NSDate date]);
            [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            //[self showAlert];
        }
        
    }];
}

-(void)fetchStations:(NSString *)latitudes :(NSString *)longitudes :(NSString *)zipcode{
    NSLog(@"fetchStations latitudes longitudes zipcode");
    __weak typeof(self) weakSelf = self;
    NSDictionary *dict = [self setParameterwithZip:zipcode latitude:latitudes longitude:longitudes];
    
    [arrayCurrentAnnotations removeAllObjects];
    [arrayCurrentStations removeAllObjects];
    NSLog(@"Opencharge API start time ---------------------------: %@",[NSDate date]);
    [[EVClientApi sharedClient] fetchStationWithParameters:dict Success:^(id result) {
        NSArray *arrayFetchFromApi = result;
        NSLog(@"API data count : %lu",(unsigned long)arrayFetchFromApi.count);
        if (arrayFetchFromApi.count == 0) {
           // [[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Opencharge API Stations :%lu",(unsigned long)arrayFetchFromApi.count] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
        NSLog(@"Opencharge API stop time ---------------------------: %@",[NSDate date]);
        if(  arrayFetchFromApi.count == 0 && arrayResultFetchFromServer.count == 0 && arrayResultFetchFromOCPPServer.count == 0 && !stop){
            [self showAlert];
        }else{
            [weakSelf combineStationFromServerAndApiWithArray:arrayFetchFromApi];
        }
    } Failure:^(NSError *error) {
       // [[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Opencharge API Fail with Error : %@",[error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        NSLog(@"Opencharge API stop time ---------------------------: %@",[NSDate date]);
        if(!stop)
            [self showAlert];
    }];
    
}

-(void)fetchStationsWithZipCode:(NSString *)zipcode{
    NSLog(@"fetchStationsWithZipCode zipcode");
    __weak typeof(self) weakSelf = self;
    NSDictionary *dict = [self setParameterwithZip:zipcode latitude:nil longitude:nil];
    
    [arrayCurrentAnnotations removeAllObjects];
    [arrayCurrentStations removeAllObjects];
//a    [[EVClientApi sharedClient] fetchStationWithParameters:dict Success:^(id result) {
        
//a        NSArray *arrayFetchFromApi = result[@"fuel_stations"] ;
    NSArray *arrayFetchFromApi = nil;
        if(arrayFetchFromApi.count == 0 && arrayResultFetchFromServer.count == 0 && arrayResultFetchFromOCPPServer.count == 0 && !stop){
            [self showAlert];
        }else
            [weakSelf combineStationFromServerAndApiWithArray:arrayFetchFromApi];
        
//a    } Failure:^(NSError *error) {
//a        if(!stop)
//a            [self showAlert];
//a    }];
    
}

-(void)combineStationFromServerAndApiWithArray:(NSArray *)arrayFetchFromApi{
    NSLog(@"combineStationFromServerAndApiWithArray");
    __weak typeof(self) weakSelf = self;
    NSArray *arrayResult ;
    arrayResult = (arrayFetchFromApi.count > 0)?
    [arrayFetchFromApi arrayByAddingObjectsFromArray:[arrayResultFetchFromServer copy]] :
    arrayResultFetchFromServer;
    arrayResult = (arrayResultFetchFromOCPPServer.count > 0)?
    [arrayResult arrayByAddingObjectsFromArray:[arrayResultFetchFromOCPPServer copy]] :
    arrayResult;
    NSLog(@"Combine array result : %lu",(unsigned long)arrayResult.count);
    if(arrayResult.count == 0 && !stop){
        [self showAlert];
    }else{
        [arrayResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            if(arrayResultFetchFromServer.count != 0 &&
               ((arrayFetchFromApi.count == 0 && !(idx > (arrayFetchFromApi.count+arrayResultFetchFromServer.count-1)))
                ||
                (idx > arrayFetchFromApi.count - 1 && !(idx > (arrayFetchFromApi.count+arrayResultFetchFromServer.count-1)))
                )){
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
            EVStations *station = arrayCurrentStations[arrayCurrentStations.count-1];
            [weakSelf allocatePin:station];
            if(idx == arrayResult.count-1){
                [weakSelf addAnnotationToMapView];
            }
        }];
        NSLog(@"All station count : %lu",(unsigned long)arrayCurrentStations.count);
    }
}

-(NSDictionary*)setParameterwithZip:(NSString*)zipcode latitude:(NSString *)selectedLatitude longitude:(NSString *)selectedLongitude{
    NSLog(@"setParameterwithZip zipcode selectedLatitude selectedLongitude");
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:selectedLongitude forKey:@"longitude"];
    [dict setValue:selectedLatitude forKey:@"latitude"];
    [dict setValue:@"500" forKey:@"distance"];
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
    NSLog(@"API Parameters : %@",dict);
    return dict;
}

-(void)showAlert{
    
    NSLog(@"showAlert");
    [modal hide];

    if (isVisible) {
        (([filter.chargingLevel componentsSeparatedByString:@","].count == 3 && [filter.usageType componentsSeparatedByString:@","].count == 8) || !filter )
        ? [self showModalWithMessage:@"No stations found"]
        : [self showModalWithMessage:@"No stations found. Please adjust your filters and try again."];
    }
}
           
-(void) showModalWithMessage : (NSString*)message {
    [modal setMessage:message];
    [modal show];
}

-(void)showModalWithMessage:(NSString*)message forDuration:(CGFloat)duration {
    [modal setMessage: message];
    [modal showWithoutSpinner];
    
    [NSTimer scheduledTimerWithTimeInterval: duration target:modal selector:@selector(hide) userInfo:nil repeats:NO];
}

-(void)hideModal {
    [modal hide];
}

-(void)addAnnotationToMapView{
    NSLog(@"addAnnotationToMapView");
    [modal hide];
    //[activityIndicator stopAnimating];
    NSMutableArray *loadingAnnotations = [[NSMutableArray alloc]init];
    loadingAnnotations =  arrayCurrentAnnotations;
    if(isRefresh){
        isRefresh = NO;
    }else if(!stop){
        stop = YES;
        [self zoomToLocationGiven:YES];
    }else if(isSearch){
        NSLog(@"Distance from search location : %f",[currentLocation distanceFromLocation:searchLocation]);
        if([currentLocation distanceFromLocation:searchLocation]< 500*1609.34 /* 500 miles */) [self zoomToLocationGiven:YES];
        else [self zoomToLocationGiven:NO];
    }
    [_mapView removeAnnotations:self.mapView.annotations];
    [_mapView addAnnotations:arrayCurrentAnnotations];
    lasrUpdatedAnnotations = loadingAnnotations;
}

-(void)removeLastAnnotaions:(NSArray*)loadingAnnotations{
    NSLog(@"removeLastAnnotaions");
    lasrUpdatedAnnotations = loadingAnnotations;
}

-(void)filter:(EVStations *)station{
    NSLog(@"filter station");
    [self allocatePin:station];
}

-(void)allocatePin:(EVStations *)station{
    NSLog(@"allocatePin");
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

-(NSString *)setPowerLevel:(NSArray *)arrayPowerLevel{
    NSLog(@"setPowerLevel");
    NSMutableArray *arrayLevel =[NSMutableArray new];
    [arrayPowerLevel enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([arrayPowerLevel[idx] isEqualToString:@"1"])
            [arrayLevel addObject:@"Level 1 EVSE"];
        else if([arrayPowerLevel[idx] isEqualToString:@"2"])
            [arrayLevel addObject:@"Level 2 EVSE"];
        else
            [arrayLevel addObject:@"DC Fast Charging"];
        
    }];
    return [arrayLevel componentsJoinedByString:@","];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSLog(@"mapView viewForAnnotation");
    MKAnnotationView *annView;
    if ([annotation isKindOfClass:[EVMapPin class]])
    {
        annView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        [annView setEnabled:YES];
        [annView setCanShowCallout:YES];
        EVMapPin* myAnnotation1=(EVMapPin *)annotation;
        if ([myAnnotation1.stationSelected.isRCS isEqualToString:@"NO"]) {
            annView.image = [UIImage imageNamed:[NSString stringWithFormat:@"green_pin.png"]];
        }else{
            if([myAnnotation1.stationSelected.status isEqualToString:@"Available"]) {
                annView.image = [UIImage imageNamed:[NSString stringWithFormat:@"purple_pin.png"]];
            }else if([myAnnotation1.stationSelected.status isEqualToString:@"Offline"]){
                annView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gray_pin.png"]];
            }else if([myAnnotation1.stationSelected.status isEqualToString:@"Reserved"]){
                annView.image = [UIImage imageNamed:[NSString stringWithFormat:@"skyblue_pin.png"]];
            }else if([myAnnotation1.stationSelected.status isEqualToString:@"Faulted"]){
                annView.image = [UIImage imageNamed:[NSString stringWithFormat:@"red_pin.png"]];
            }else if([myAnnotation1.stationSelected.status isEqualToString:@"Occupied"]){
                annView.image = [UIImage imageNamed:[NSString stringWithFormat:@"orange_pin.png"]];
            }else{
                annView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gray_pin.png"]];
            }
        }
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(calloutAction:) forControlEvents:UIControlEventTouchUpInside];
        rightButton.tag=myAnnotation1.tagIndex;
        annView.rightCalloutAccessoryView = rightButton;
    }
    NSLog(@"All data load end time ------------:%@",[NSDate date]);
    return annView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"mapView didSelectAnnotationView");
    id<MKAnnotation>annotation = view.annotation;
    if ([annotation isKindOfClass:[EVMapPin class]])
        currentEVMapPin = (EVMapPin*) view.annotation;
}

-(void)calloutAction:(id)sender{
    NSLog(@"calloutAction");
    UIButton *button = sender;
    [self gotoStationDetailView:button.tag];
}

-(void)gotoStationDetailView:(NSUInteger)index{
    NSLog(@"gotoStationDetailView");
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

#pragma mark interface Methods
-(void)zoomtoLocation:(CLLocation *)selectedLocation :(NSString *)stationName :(BOOL)isStation{
    NSLog(@"zoomtoLocation");
    if(!isStation){
        point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake(selectedLocation.coordinate.latitude, selectedLocation.coordinate.longitude);
        point.title = stationName;
        [self.mapView addAnnotation:point];
        NSString *latitudes = [NSString stringWithFormat:@"%f",selectedLocation.coordinate.latitude];
        NSString *longitudes = [NSString stringWithFormat:@"%f",selectedLocation.coordinate.longitude];
        [self showModalWithMessage:@"Retrieving stations!"];
        [self fetchStations:latitudes :longitudes:nil];
    }else{
        [arrayCurrentStations enumerateObjectsUsingBlock:^(EVStations *stationsObj, NSUInteger idx, BOOL *stop) {
            if([stationsObj.title isEqualToString:stationName]){
                NSArray *arrayAnnotation = [NSArray arrayWithObject:arrayCurrentAnnotations[idx]];
                [self zooming:arrayAnnotation];
            }
        }];
    }
}

- (IBAction)revealMenu:(id)sender{
    NSLog(@"revealMenu");
    [self searchBarCancelButtonClicked:searchBar];
    [self.slidingViewController anchorTopViewTo:ECRight];
}


#pragma mark Search Actions
-(IBAction)search:(id)sender{
    NSLog(@"search");
    isSearch = YES;
    if(viewSearch.frame.origin.y == 50){
        [self searchBarCancelButtonClicked:searchBar];
    }else{
        if(viewSearch == nil){
            
            viewSearch = [[UIView alloc]initWithFrame:CGRectMake(0, -100, self.view.frame.size.width, 70)];
            viewSearch.backgroundColor = [UIColor darkGrayColor];
            labelSearch = [[UILabel alloc]initWithFrame:CGRectMake(2, 5, self.view.frame.size.width, 30)];
            labelSearch.text = @"Search By Address, Zip code or Location Name";
            labelSearch.textColor = [UIColor whiteColor];
            labelSearch.font = [UIFont systemFontOfSize:12];
            searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 44)];
            searchBar.delegate = self;
            searchBar.showsCancelButton = YES;
            
            
            [viewSearch addSubview:labelSearch];
            [viewSearch addSubview:searchBar];
            [self.view addSubview:viewSearch];
        }else{
            viewSearch.frame = CGRectMake(0, 50, self.view.frame.size.width, 70);
            labelSearch.frame = CGRectMake(2, 5, self.view.frame.size.width, 30);
            searchBar.frame = CGRectMake(0, 30, self.view.frame.size.width, 44);
            
        }
        searchBar.text = @"";
        [UIView animateWithDuration:0.5 animations:^{
            viewSearch.frame = CGRectMake(0, 50, self.view.frame.size.width, 70);
            [searchBar becomeFirstResponder];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBars{
    NSLog(@"searchBarCancelButtonClicked");
    isSearch = NO;
    [searchBars resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        viewSearch.frame = CGRectMake(0, -100, self.view.frame.size.width, 70);
    } completion:^(BOOL finished) {
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBars{
    NSLog(@"searchBarSearchButtonClicked");
    [searchBars resignFirstResponder];
    [self showModalWithMessage:@"Retrieving stations..."];
    [self geocodeFromTimer:searchBars.text];
}

- (void) geocodeFromTimer:(NSString *)searchString{
    NSLog(@"geocodeFromTimer");
    //a stop = YES;
    stop = NO;
    GeoCoder *geocoder = [GeoCoder new];
    [geocoder geoCodeAddress:searchString inBlock:^(CLLocation *location) {
        if(location.coordinate.latitude  == 0){
            [self showModalWithMessage:@"No stations found"];
        }else{
            searchedString = searchString;
            [self processForwardGeocodingResults:location searchString:searchString];
        }
    }];
}

- (void) processForwardGeocodingResults:(CLLocation *)placemarks searchString:(NSString*)searchString{
    NSLog(@"processForwardGeocodingResults");
    isFetch = NO;
    searchLocation = placemarks;
    point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemarks.coordinate.latitude, placemarks.coordinate.longitude);
    point.title = searchString;
    [self fetchStationUsingLocationWithLatitude:[NSString stringWithFormat:@"%f",placemarks.coordinate.latitude] AndLongitude:[NSString stringWithFormat:@"%f",placemarks.coordinate.longitude]];
}

#pragma mark adbanner delegates
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{return willLeave;}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
