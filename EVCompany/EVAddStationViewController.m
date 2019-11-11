//
//  EVAddStationViewController.m
//  EVCompany
//
//  Created by Srishti on 29/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVAddStationViewController.h"
#import <MapKit/MapKit.h>
#import "EVAppDelegate.h"
#import "EVSlidingViewController.h"
#import "EVAddStationTableViewController.h"
@interface EVAddStationViewController (){
    CLLocation *selectedLocation;
}
@property (nonatomic,strong)IBOutlet MKMapView *mapView;

@end

@implementation EVAddStationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"--------------EVAddStationViewController--------------");
    [super viewDidLoad];
    EVAppDelegate *appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
    selectedLocation = appDelegete.currentLocation;
    NSString *longitude = [NSString stringWithFormat:@"%.8f", appDelegete.currentLocation.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%.8f", appDelegete.currentLocation.coordinate.latitude];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    point.title = @"New Location";
    point.subtitle=@"Press and hold pin to move.";
    [self.mapView addAnnotation:point];
    [self zoomToLocationGiven:point];
    [self.mapView selectAnnotation:point animated:YES];
}

-(IBAction)changeMapViewType:(id)sender{
    UIButton *button = sender;
    self.mapView.mapType = (button.tag == 0)?MKMapTypeStandard:MKMapTypeSatellite;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil)
    {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = YES;
        pav.canShowCallout = YES;
    }
    else
    {
        pav.annotation = annotation;
    }
    return pav;
}
- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        selectedLocation = [[CLLocation alloc]initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
    }
}
-(void)zoomToLocationGiven:(MKPointAnnotation *)point{
    
    MKCoordinateRegion region;
    region.center = point.coordinate;
    MKCoordinateSpan span;//Set Zoom level using Span
    span.latitudeDelta = 0.001;
    span.longitudeDelta = 0.001;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
}

-(IBAction)nextAction:(id)sender{
    EVAddStationTableViewController *evAddStationTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addStationTableview"];
    [evAddStationTableViewController setLocation:selectedLocation];
    [self.navigationController pushViewController:evAddStationTableViewController animated:YES ];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
