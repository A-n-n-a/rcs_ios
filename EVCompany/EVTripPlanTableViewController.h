//
//  EVTripPlanTableViewController.h
//  EVCompany
//
//  Created by GridScape on 9/4/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface EVTripPlanTableViewController : UITableViewController <UITextFieldDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UITextViewDelegate>

- (void)calculateDistanceWithSource:(NSString *)source withDestination:(NSString *)destination WithCompletionBlock:(void(^)(BOOL success, id result, NSError *error))completionBlock;
- (void)goTripToStationRouteVC;

@end
