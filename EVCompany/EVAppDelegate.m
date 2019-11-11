//
//  EVAppDelegate.m
//  EVCompany
//
//  Created by Srishti on 11/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVAppDelegate.h"
#import "ECSlidingViewController.h"
#import "EVMapViewController.h"
#import "EVMenuViewController.h"
#import "GeoCoder.h"
#import "EVDirectionService.h"
#import "UserSetting.h"
#import "EVTripPlanTableViewController.h"
#import "EVBluetoothManager.h"

@interface EVAppDelegate ()
@property (nonatomic, strong) ECSlidingViewController *slidingViewController;
@property (nonatomic, strong) UIStoryboard *storyBoard;
@end
@implementation EVAppDelegate{
    UIStoryboard *storyBoard;
    UINavigationController *navigationController;
    CLLocationManager *locationManager;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize storyBoard = _storyBoard;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[self redirectConsoleLogToDocumentFolder];//for sending nslog to file
    [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
   // [Crashlytics startWithAPIKey:@"8bb50afe195b493d64e12009d000452c5941dad2"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
 
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
  

    UIImage *image = [UIImage imageNamed:@"whiteBack"];
    UIImage *backButton = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0,image.size.width,0,0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault]; 
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        //application.applicationIconBadgeNumber = 0;
    }
  
    UserSetting *userSetting;
    NSManagedObjectContext *managedObjectContext1 = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserSetting" inManagedObjectContext:managedObjectContext1]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext1 executeFetchRequest:request error:&error];
    if(results.count)
    {
        userSetting=results[0];
    }
    if (userSetting.notificationStr == nil) {
        _OnOffFlag = @"ON";
        NSLog(@"app delegate notification str = %@",userSetting.notificationStr);
        NSLog(@"app delegate notification str = %@",_OnOffFlag);
    }else if([userSetting.notificationStr isEqualToString:@"ON"]){
        _OnOffFlag = @"ON";
        NSLog(@"app delegate notification str = %@",userSetting.notificationStr);
        NSLog(@"app delegate notification str = %@",_OnOffFlag);
    }else if([userSetting.notificationStr isEqualToString:@"OFF"]){
        _OnOffFlag = @"OFF";
        NSLog(@"app delegate notification str = %@",userSetting.notificationStr);
        NSLog(@"app delegate notification str = %@",_OnOffFlag);
    }
    _delegNotifyDistStr = @"5";
    _TripLatitude = @"";
    _TripLongitude = @"";
    _tripStartLocation = @"";
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
       return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    NSString *tokenstr= [[[deviceToken description]
                                                    stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                                   stringByReplacingOccurrencesOfString:@" "
                                                   withString:@""];
    _device_token = tokenstr;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    if ([_OnOffFlag isEqualToString:@"ON"]) {
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification Message" message:@"Your reservation will start within a few minutes." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            alert.tag = 0;
            [alert show];
        }
    }else if ([_OnOffFlag isEqualToString:@"OFF"]){
        
    }else{
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification Message" message:@"Your reservation will start within a few minutes." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            alert.tag = 1;
            [alert show];
        }
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification Message"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
    }
  
    // Set icon badge number to zero
 //   application.applicationIconBadgeNumber = 0;
    // NSLog(@"didReceiveLocalNotification");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"enter in backgroud");
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([_NotificationFlag isEqualToString:@"false"]) {
        [locationManager startUpdatingLocation];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"become active");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[EVBluetoothManager shared] cancelAllConnection];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EVCompany" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EVCompany.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)getcurrentlocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"didFailWithError: %@", error);
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        _currentLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        _currentLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    }
    NSLog(@"Stop location Name latitude= %@",_currentLatitude);
    NSLog(@"Stop location Name longitude= %@",_currentLongitude);
    NSLog(@"trip start location = %@",_tripStartLocation);
    if(![_tripStartLocation isEqualToString:@""]){
        //CLLocation *locA = [[CLLocation alloc] initWithLatitude:[_TripLatitude doubleValue] longitude:[_TripLongitude doubleValue]];
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:[_currentLatitude doubleValue] longitude:[_currentLongitude doubleValue]];
        GeoCoder *reverseGeocoder = [GeoCoder new];
        [reverseGeocoder reverseGeoCode:locB inBlock:^(NSDictionary *statename) {
            NSLog(@"State Name = %@",statename);
            _tripMovingLocation = [statename objectForKey:@"address"];
        }];
        
        [EVDirectionService fetchDataFromServiceWithSource:_tripStartLocation withDestination:(NSString *)_tripMovingLocation withCompletionBlock:^(BOOL success, id result, NSError *error){
            if(success){
                NSLog(@"map service result = %@",result);
                NSArray *rowsArray = [result objectForKey:@"rows"];
                NSArray *elementArray = [[rowsArray objectAtIndex:0] objectForKey:@"elements"];
                NSArray *distanceArray = [[elementArray objectAtIndex:0] objectForKey:@"distance"];
                NSLog(@"distance = %@",distanceArray);
                NSString *distanceText = [distanceArray valueForKey:@"text"];
                
                NSRange range = [distanceText rangeOfString:@" " options:NSBackwardsSearch];
                NSLog(@"range.location: %lu", (unsigned long)range.location);
                NSString *substring = [distanceText substringFromIndex:range.location+1];
                NSLog(@"substring: '%@'", substring);
                
                NSString * rpString;
                double distanceinml = 0.0;
                
                if([substring isEqualToString:@"km"]){
                    rpString = [distanceText stringByReplacingOccurrencesOfString:@"km" withString:@""];
                    NSString *rmcomma = [rpString stringByReplacingOccurrencesOfString:@"," withString:@""];
                    NSLog(@"distanceText = %@",rmcomma);
                    distanceinml = [rmcomma doubleValue]*0.621371;
                }else if([substring isEqualToString:@"m"]){
                    rpString = [distanceText stringByReplacingOccurrencesOfString:@"m" withString:@""];
                    NSString *rmcomma = [rpString stringByReplacingOccurrencesOfString:@"," withString:@""];
                    NSLog(@"distanceText = %@",rmcomma);
                    distanceinml = [rmcomma doubleValue]*0.000621371;
                }
                NSLog(@"distance in ml=%f",distanceinml);
                NSLog(@"distance in ml=%d",(int)distanceinml );
                NSLog(@"distance in ml=%ld",(long)[_batteryDistance integerValue]);
                NSLog(@"distance in ml=%ld",(long)[_batteryDistance integerValue] - [_delegNotifyDistStr integerValue]);
                int checkDistance = [_batteryDistance integerValue] - [_delegNotifyDistStr integerValue];
                if (checkDistance < (int)distanceinml && [_NotificationFlag isEqualToString:@"false"]) {
                    _NotificationFlag = @"true";
                    [self addNotification];
                    [locationManager stopUpdatingLocation];
                }
            }else{
                [locationManager stopUpdatingLocation];
            }
        }];
    }
}

- (void)addNotification{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
   // localNotification.alertTitle = @"Notification Message";
    localNotification.alertBody = @"There is not enough battery charge to reach your destination.  Please recharge your battery.";
    localNotification.alertAction = @"";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

/*for sending nslog to file*/
- (void) redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.txt"];
    freopen([logPath fileSystemRepresentation],"a+",stderr);
}
/*for sending nslog to file*/

//--------------------------------------------------------------------------------------------------
// AlertView's Button Event
//--------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 2) {
        if (buttonIndex == 0) {
            NSLog(@"notification alert click");
            [self.tripTableVC goTripToStationRouteVC];
        }
        else if (buttonIndex == 1){
        }
    }
}
@end
