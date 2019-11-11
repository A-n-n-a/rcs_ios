//
//  MapDetailsRouteViewController.m
//  UserAppFlow
//
//  Created by Vignesh R on 13/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EVMapDetailsRouteViewController.h"
#import "MKAnnotationView+WebCache.h"

@interface EVMapDetailsRouteViewController ()<MKMapViewDelegate,MKAnnotation,ADBannerViewDelegate>{
    CLLocation  *dealLocation ;
    IBOutlet ADBannerView *bannerView;
}
- (IBAction)backButtonAction:(id)sender;
@end

@implementation EVMapDetailsRouteViewController
@synthesize isDirection;
@synthesize routeLine;
@synthesize routeLineView;
@synthesize ToLati;
@synthesize ToLongi,imageName;
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
    NSLog(@"--------------EVMapDetailsRouteViewController--------------");
        //for setting custom font
       [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated{
    mapFlag=1;
    double lat  = [ToLati doubleValue];
    double lon  = [ToLongi doubleValue];
    dealLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; 
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; 
    [locationManager startUpdatingLocation];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(dealLocation.coordinate, span);
    [mapRouteView setRegion:region];
    AddressAnnotation *annotation = [[AddressAnnotation alloc] initWithCoordinate:dealLocation.coordinate];
    [mapRouteView addAnnotation:annotation];
    
    bannerView.backgroundColor = [UIColor clearColor];
    bannerView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    DirectionParser *directionParser = [[DirectionParser alloc] init];
    [directionParser setDelegate:self];
    [directionParser findDirectionArrayFrom:dealLocation to:newLocation];
    annotationUser= [[AddressAnnotation alloc] initWithCoordinate:newLocation.coordinate];
    [mapRouteView addAnnotation:annotationUser];
    [locationManager stopUpdatingLocation];
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

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
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
