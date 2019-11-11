//
//  MapDetailsRouteViewController.h
//  UserAppFlow
//
//  Created by Vignesh R on 13/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddressAnnotation.h"
#import "DirectionParser.h"

@interface EVMapDetailsRouteViewController : UIViewController<CLLocationManagerDelegate>
{
    IBOutlet MKMapView *mapRouteView;
    CLLocationManager *locationManager;
    AddressAnnotation *annotationUser ;
    MKPinAnnotationView *annView;
    int mapFlag;
}
@property(nonatomic)BOOL isDirection;
@property(nonatomic,retain) NSString *ToLati;
@property(nonatomic,retain) NSString *ToLongi;
@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) MKPolylineView* routeLineView;
@property (nonatomic,strong) NSString *imageName;

@end
