//
//  EVTripToStationRouteViewController.h
//  EVCompany
//
//  Created by GridScape on 4/29/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddressAnnotation.h"
#import "DirectionParser.h"
#import "EVStations.h"

@interface EVTripToStationRouteViewController : UIViewController<CLLocationManagerDelegate>{
    IBOutlet ADBannerView *bannerView;
    IBOutlet MKMapView *mapRouteView;
    CLLocationManager *locationManager;
    AddressAnnotation *annotationUser ;
    MKPinAnnotationView *annView;
    int mapFlag;
}

@property(nonatomic,strong)EVStations *station;
@property(nonatomic)BOOL isDirection;
@property(nonatomic,retain) NSString *FromLati;
@property(nonatomic,retain) NSString *FromLongi;
@property(nonatomic,retain) NSString *ToLati;
@property(nonatomic,retain) NSString *ToLongi;
@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) MKPolylineView* routeLineView;
@property (nonatomic,strong) NSString *imageName;
@property(nonatomic,strong)NSString *searchStringfromEvstation;
@property(assign)BOOL needBack;

- (IBAction)backButtonAction:(id)sender;

@end
