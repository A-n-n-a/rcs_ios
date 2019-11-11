//
//  EVMapViewController.h
//  EVCompany
//
//  Created by Srishti on 11/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "EVStations.h"
#import "EVReservationListViewController.h"

@interface EVMapViewController : UIViewController <EVReservationModalDelegate>
@property(nonatomic,strong)EVStations *station;
@property(nonatomic,strong)NSString *searchStringfromEvstation;
@property(assign)BOOL needBack;
@end
