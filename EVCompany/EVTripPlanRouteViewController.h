//
//  EVTripPlanRouteViewController.h
//  EVCompany
//
//  Created by GridScape on 3/29/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddressAnnotation.h"
#import "DirectionParser.h"

@interface EVTripPlanRouteViewController : UIViewController<CLLocationManagerDelegate>
{
    IBOutlet MKMapView *mapRouteView;
    CLLocationManager *locationManager;
    AddressAnnotation *annotationUser ;
    MKPinAnnotationView *annView;
    int mapFlag;
}
@property(nonatomic)BOOL isDirection;
@property(nonatomic,retain) NSString *FromLati;
@property(nonatomic,retain) NSString *FromLongi;
@property(nonatomic,retain) NSString *ToLati;
@property(nonatomic,retain) NSString *ToLongi;
@property(nonatomic) CLLocationCoordinate2D fromCoords;
@property(nonatomic) CLLocationCoordinate2D toCoords;
@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) MKPolylineView* routeLineView;
@property (nonatomic,strong) NSString *imageName;

@end
