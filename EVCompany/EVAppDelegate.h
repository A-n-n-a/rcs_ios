//
//  EVAppDelegate.h
//  EVCompany
//
//  Created by Srishti on 11/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EVTripPlanTableViewController.h"

#define INMOBI_APP_ID           @"ac913e21dcc94be5b421a6cd82bfe9b9"
#define BANNER_APP_ID           INMOBI_APP_ID
#define INTERSTITIAL_APP_ID     INMOBI_APP_ID
@interface EVAppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong)CLLocation *currentLocation;

@property (strong, nonatomic) NSString *index_path;
@property (strong, nonatomic) NSString *btn_name;
@property (strong, nonatomic) NSString *tagId;

@property (strong, nonatomic) NSString *delegNotifyDistStr;
@property (strong, nonatomic) NSString *device_token;
@property (strong, nonatomic) NSString *currentLatitude;
@property (strong, nonatomic) NSString *currentLongitude;
@property (strong, nonatomic) NSString *TripLatitude;
@property (strong, nonatomic) NSString *TripLongitude;
@property (strong, nonatomic) NSString *tripStartLatitude;
@property (strong, nonatomic) NSString *tripStartLongitude;
@property (strong, nonatomic) NSString *batteryDistance;
@property (strong, nonatomic) NSString *tripStartLocation;
@property (strong, nonatomic) NSString *tripMovingLocation;
@property (strong, nonatomic) NSString *NotificationFlag;
@property (strong, nonatomic) NSString *OnOffFlag;
@property (weak, nonatomic) EVTripPlanTableViewController *tripTableVC;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)getcurrentlocation;
@end
