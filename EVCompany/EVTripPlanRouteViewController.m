//
//  EVTripPlanRouteViewController.m
//  EVCompany
//
//  Created by GridScape on 3/29/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVTripPlanRouteViewController.h"
#import "MKAnnotationView+WebCache.h"
#import "EVAppDelegate.h"
#import "EVMapPin.h"
#import "Filter.h"
#import "EVClientApi.h"
#import "EVModal.h"
#import "EVDetailsViewController.h"
#import "EVOCPPDetailsViewController.h"

@interface EVTripPlanRouteViewController ()<MKMapViewDelegate,MKAnnotation,ADBannerViewDelegate>{
    EVAppDelegate     *AppDelegate;
    
    CLLocation  *dealLocation ;
    IBOutlet ADBannerView *bannerView;
    CLLocation *sourceLoc;
    double lat;
    double lon;
    NSMutableArray *arrayCurrentStations;
    NSMutableArray *arrayResultFetchFromServer;
    NSMutableArray *arrayResultFetchFromOCPPServer;
    NSMutableArray *arrayStations;
    NSMutableArray *arrayCurrentAnnotations;
    NSMutableArray *arrayAnnotations;
    CLLocationCoordinate2D midPoint;
    int count;
    BOOL stop;

    Filter *filter;
}
- (IBAction)backButtonAction:(id)sender;
@end

@implementation EVTripPlanRouteViewController
@synthesize isDirection;
@synthesize routeLine;
@synthesize routeLineView;
@synthesize ToLati,FromLati,FromLongi;
@synthesize ToLongi,imageName;
@synthesize fromCoords, toCoords;

int sourceTag = -10;
int destinationTag = -11;
CLLocationDistance radius = 0;
EVModal *modal;
EVMapPin *currentEVMapPin;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"--------------EVTripPlanRouteViewController--------------");
    //for setting custom font
    [super viewDidLoad];
    
    arrayCurrentStations = [[NSMutableArray alloc] init];
    arrayResultFetchFromServer = [[NSMutableArray alloc]init];
    arrayResultFetchFromOCPPServer = [[NSMutableArray alloc] init];
    arrayStations = [[NSMutableArray alloc] init];
    arrayCurrentAnnotations = [[NSMutableArray alloc] init];
    arrayAnnotations = [[NSMutableArray alloc]init];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
    
    AppDelegate = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [self getFilter];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    midPoint = [self findCenterPoint:fromCoords :toCoords];
    point.coordinate = midPoint;
    point.title = @"Current Location";
    
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:fromCoords.latitude longitude:fromCoords.longitude];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:toCoords.latitude longitude:toCoords.longitude];
    
    CLLocationDistance straightLineDistanceMeters = [startLocation distanceFromLocation:endLocation];
    double tempRadiusMiles = ((straightLineDistanceMeters / 1609.34) / 2) + 15 ; // meters per mile
    radius = tempRadiusMiles > 30 ? tempRadiusMiles : 30;
    
    [self fetchStationUsingLocationWithLatitude:[NSString stringWithFormat:@"%f",midPoint.latitude] AndLongitude:[NSString stringWithFormat:@"%f",midPoint.longitude]];
}

-(void)viewWillAppear:(BOOL)animated
{
    mapFlag=1;
    lat  = [ToLati doubleValue];
    lon  = [ToLongi doubleValue];
    dealLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.9,0.9);
    MKCoordinateRegion region = MKCoordinateRegionMake(dealLocation.coordinate, span);
    [mapRouteView setRegion:region];
    
    sourceLoc = [[CLLocation alloc] initWithLatitude:[FromLati doubleValue] longitude:[FromLongi doubleValue]];
    
    bannerView.backgroundColor = [UIColor clearColor];
    bannerView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(CLLocationCoordinate2D)findCenterPoint:(CLLocationCoordinate2D)_lo1 :(CLLocationCoordinate2D)_loc2 {
    CLLocationCoordinate2D center;
    
    double lon1 = _lo1.longitude * M_PI / 180;
    double lon2 = _loc2.longitude * M_PI / 180;
    
    double lat1 = _lo1.latitude * M_PI / 180;
    double lat2 = _loc2.latitude * M_PI / 180;
    
    double dLon = lon2 - lon1;
    
    double x = cos(lat2) * cos(dLon);
    double y = cos(lat2) * sin(dLon);
    
    double lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) );
    double lon3 = lon1 + atan2(y, cos(lat1) + x);
    
    center.latitude  = lat3 * 180 / M_PI;
    center.longitude = lon3 * 180 / M_PI;
    
    return center;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)getFilter{
    NSLog(@"fetchDataFromCoreData");
    NSManagedObjectContext *managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Filter" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        filter=results[0];
    }
}

-(void)fetchStationUsingLocationWithLatitude:(NSString *)selectedLatitude AndLongitude:(NSString *)selectedLongitude{
    NSLog(@"fetchStationUsingLocationWithLatitude selectedLatitude");
    [modal show:@"Locating chargers along your route"];
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
        if(success){
            NSLog(@"RCS API stop time ---------------------------: %@",[NSDate date]);
            NSArray *arrayResult = result;
            NSLog(@"RCS data count : %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromServer = [arrayResult mutableCopy];
            }
            [weakSelf fetchOCPPStationUsingLocationWithLatitude:selectedLatitude AndLongitude:selectedLongitude];
            
        }else{
            NSLog(@"RCS API stop time ---------------------------: %@",[NSDate date]);
            [weakSelf fetchOCPPStationUsingLocationWithLatitude:selectedLatitude AndLongitude:selectedLongitude];
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
            }
            [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
            
        }else{
            NSLog(@"OCPP API stop time ---------------------------: %@",[NSDate date]);
            [weakSelf fetchStations:selectedLatitude :selectedLongitude :nil];
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
        [modal hide];
        NSArray *arrayFetchFromApi = result;
        NSLog(@"API data count : %lu",(unsigned long)arrayFetchFromApi.count);
        if (arrayFetchFromApi.count == 0) {
        }
        NSLog(@"Opencharge API stop time ---------------------------: %@",[NSDate date]);
        if(!(arrayFetchFromApi.count == 0
           && arrayResultFetchFromServer.count == 0
           && arrayResultFetchFromOCPPServer.count == 0
           && !stop)){
            [weakSelf combineStationFromServerAndApiWithArray:arrayFetchFromApi];
        } else {
            DirectionParser *directionParser = [[DirectionParser alloc] init];
            [directionParser setDelegate:self];
            [directionParser findDirectionArrayFrom:dealLocation to:sourceLoc];
        }
    } Failure:^(NSError *error) {
        [modal hide];
        NSLog(@"Opencharge API stop time ---------------------------: %@",[NSDate date]);
    }];
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
    
    DirectionParser *directionParser = [[DirectionParser alloc] init];
    [directionParser setDelegate:self];
    [directionParser findDirectionArrayFrom:dealLocation to:sourceLoc];
}

-(void)addAnnotationToMapView{
    NSLog(@"addAnnotationToMapView");
//    [modal hide];
    //[activityIndicator stopAnimating];
    NSMutableArray *loadingAnnotations = [[NSMutableArray alloc]init];
    loadingAnnotations =  arrayCurrentAnnotations;
//    if(isRefresh){
//        isRefresh = NO;
//    }else
    if(!stop){
        stop = YES;
//        [self zoomToLocationGiven:YES];
    }
//    else if(isSearch){
//        NSLog(@"Distance from search location : %f",[currentLocation distanceFromLocation:searchLocation]);
//        if([currentLocation distanceFromLocation:searchLocation]< 500*1609.34 /* 500 miles */) [self zoomToLocationGiven:YES];
//        else [self zoomToLocationGiven:NO];
//    }
//    [_mapView removeAnnotations:self.mapView.annotations];
    [mapRouteView addAnnotations:arrayCurrentAnnotations];
    //31.8618
    //34.8164

//    EVMapPin *pin = [[EVMapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake(31.8618, 34.8164) placeName:@"MIDPOINT" description:nil tag:0 withStation:nil];
//    [mapRouteView addAnnotation:pin];

//    lasrUpdatedAnnotations = loadingAnnotations;
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
    EVMapPin *pin = [[EVMapPin alloc]initWithCoordinates:CLLocationCoordinate2DMake([station.latitude doubleValue], [station.longitude doubleValue]) placeName:titleString description:addressString tag:count withStation:station];
    [arrayCurrentAnnotations addObject:pin];
    [arrayAnnotations addObject:pin];
    count += 1;
}

-(NSDictionary*)setParameterwithZip:(NSString*)zipcode latitude:(NSString *)selectedLatitude longitude:(NSString *)selectedLongitude{
    NSLog(@"setParameterwithZip zipcode selectedLatitude selectedLongitude");
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:selectedLongitude forKey:@"longitude"];
    [dict setValue:selectedLatitude forKey:@"latitude"];
    [dict setValue:[NSString stringWithFormat:@"%f", radius] forKey:@"distance"];
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
    
    EVMapPin *destinationPin = [[EVMapPin alloc] initWithCoordinates:dealLocation.coordinate placeName:nil description:nil tag:destinationTag withStation:nil];
    [mapRouteView addAnnotation:destinationPin];
    
    EVMapPin *sourcePin = [[EVMapPin alloc] initWithCoordinates:sourceLoc.coordinate placeName:nil description:nil tag:sourceTag withStation:nil];
    [mapRouteView addAnnotation:sourcePin];
}

- (void) mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *view in views)
    {
        EVMapPin *annotation = (EVMapPin *)view.annotation;
        
        if (annotation.tagIndex == sourceTag || annotation.tagIndex == destinationTag)
        {
            [[view superview] bringSubviewToFront:view];
        }
        else
        {
            [[view superview] sendSubviewToBack:view];
        }
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
//    annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
//    if(annotation==annotationUser){
////        annView.pinColor = MKPinAnnotationColorGreen;
//        annView.image = [UIImage imageNamed:@"ic_route_endpoint_white"];
//    }else{
//        annView.pinColor = MKPinAnnotationColorRed;
//    }
//    annView.canShowCallout = YES;
//    
//    return annView;
    EVMapPin *pin = (EVMapPin *)annotation;
    
    if (pin.tagIndex == sourceTag) {
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:pin reuseIdentifier:@"from"];
        UIImage *pinImage = [UIImage imageNamed:@"ic_route_endpoint_white"];

        UIImage *newImage = [pinImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(newImage.size, NO, newImage.scale);
        [[UIColor colorWithRed:0.27 green:0.71 blue:0.34 alpha:1.0] set];
        [newImage drawInRect:CGRectMake(0, 0, pinImage.size.width, pinImage.size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        view.image = newImage;
        return view;
    } else if (pin.tagIndex == destinationTag) {
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:pin reuseIdentifier:@"to"];
        UIImage *pinImage = [UIImage imageNamed:@"ic_route_endpoint_white"];
        
        UIImage *newImage = [pinImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(newImage.size, NO, newImage.scale);
        [[UIColor redColor] set];
        [newImage drawInRect:CGRectMake(0, 0, pinImage.size.width, pinImage.size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        view.image = newImage;
        return view;
    } else {
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:pin reuseIdentifier:@"pin"];
        [view setEnabled:YES];
        [view setCanShowCallout:YES];
        
        if ([pin.stationSelected.isRCS isEqualToString:@"NO"]) {
            view.image = [UIImage imageNamed:[NSString stringWithFormat:@"green_pin.png"]];
        }else{
            if([pin.stationSelected.status isEqualToString:@"Available"]) {
                view.image = [UIImage imageNamed:[NSString stringWithFormat:@"purple_pin.png"]];
            }else if([pin.stationSelected.status isEqualToString:@"Offline"]){
                view.image = [UIImage imageNamed:[NSString stringWithFormat:@"gray_pin.png"]];
            }else if([pin.stationSelected.status isEqualToString:@"Reserved"]){
                view.image = [UIImage imageNamed:[NSString stringWithFormat:@"skyblue_pin.png"]];
            }else if([pin.stationSelected.status isEqualToString:@"Faulted"]){
                view.image = [UIImage imageNamed:[NSString stringWithFormat:@"red_pin.png"]];
            }else if([pin.stationSelected.status isEqualToString:@"Occupied"]){
                view.image = [UIImage imageNamed:[NSString stringWithFormat:@"orange_pin.png"]];
            }else{
                view.image = [UIImage imageNamed:[NSString stringWithFormat:@"gray_pin.png"]];
            }
        }
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(calloutAction:) forControlEvents:UIControlEventTouchUpInside];
        rightButton.tag=pin.tagIndex;
        view.rightCalloutAccessoryView = rightButton;

        return view;
    }
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"mapView didSelectAnnotationView");
    [[view superview] bringSubviewToFront:view];
    id<MKAnnotation>annotation = view.annotation;
    if ([annotation isKindOfClass:[EVMapPin class]])
        currentEVMapPin = (EVMapPin*) view.annotation;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [[view superview] sendSubviewToBack:view];
}

#pragma mark - MapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    MKOverlayView* overlayView = nil;
    
    if(overlay == self.routeLine){
        //if we have not yet created an overlay view for this overlay, create it now.
        if(nil == self.routeLineView){
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine] ;
            self.routeLineView.fillColor = [UIColor blueColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 3;
        }
        overlayView = self.routeLineView;
        
    }
    return overlayView;
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startNavigation:(id)sender {
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(lat, lon);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinates addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = userLocation.coordinate;
    point.title = @"Where am I?";
    point.subtitle = @"I'm here!!!";
}

#pragma mark adbanner delegates
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"bannerview did not receive any banner due to %@", error);}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{NSLog(@"bannerview was selected");}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{return willLeave;}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {NSLog(@"banner was loaded");}

@end
