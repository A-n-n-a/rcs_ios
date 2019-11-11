//
//  EVOwnReservationTableViewController.h
//  EVCompany
//
//  Created by GridScape on 2/26/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVStations.h"
#import "EVReservationListViewController.h"

@interface EVOwnReservationTableViewController : UITableViewController

@property (nonatomic,retain) NSMutableArray *reservationData;
@property (nonatomic,retain)EVStations *currentstation;
@property (nonatomic,retain)NSString *currentconnectorid;
@property (nonatomic,retain) NSString *currentconnctIndex;
@property (nonatomic,retain)NSString *currentStartTime;
@property (nonatomic,retain) NSString *currentEndTime;
@property (nonatomic) BOOL isRefresh;
@property (nonatomic, weak) id<EVReservationModalDelegate> delegate;

@end
