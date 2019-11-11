//
//  EVRouteViewController.m
//  EVCompany
//
//  Created by Srishti on 13/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVRouteViewController.h"
#import "MapView.h"
#import "Place.h"
#import<QuartzCore/QuartzCore.h>
#import "EVAppDelegate.h"
#import <iAd/iAd.h>

@interface EVRouteViewController (){
    MapView* mapView;
    UIView *viewbanner;
    ADBannerView *bannerView;
}

@end

@implementation EVRouteViewController

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
    NSLog(@"--------------EVRouteViewController--------------");
    [super viewDidLoad];
    [self drawRoute];
     [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    viewbanner  = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    [self.navigationController.view addSubview:viewbanner];
    
    [self addBannerView];
	// Do any additional setup after loading the view.
}
-(void)addBannerView{
    
    bannerView = [[ADBannerView alloc]initWithFrame:CGRectZero];
    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        [bannerView setFrame:CGRectMake(0, self.view.frame.size.height-32, self.view.frame.size.width, 32)];
    } else {
        [bannerView setFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    }
    // Optional to set background color to clear color
    [bannerView setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.view addSubview:bannerView];
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        [bannerView setFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    } else {
        [bannerView setFrame:CGRectMake(0, self.view.frame.size.height-32, self.view.frame.size.width, 32)];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];

}

-(void)drawRoute
{
    EVAppDelegate *appdelegate = (EVAppDelegate*)[[UIApplication sharedApplication] delegate];
     mapView = [[MapView alloc] initWithFrame:
                        CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	
	[self.view addSubview:mapView];
    
	
	Place* home = [[Place alloc] init] ;
	home.name = @"Current Location";
	home.description = @"";
	home.latitude =appdelegate.currentLocation.coordinate.latitude;
	home.longitude =appdelegate.currentLocation.coordinate.longitude;
    
    
    
	Place* restLocation = [[Place alloc] init];
	restLocation.name =@"" ;
	restLocation.description = @"";
	restLocation.latitude = [_station.latitude doubleValue];
    restLocation.longitude= [_station.longitude doubleValue];
   	[mapView showRouteFrom:restLocation to:home];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
