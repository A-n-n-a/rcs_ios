//
//  EVcurrentReservation.h
//  EVCompany
//
//  Created by GridScape on 10/20/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVStations.h"

@interface EVcurrentReservation : UITableViewController

@property (nonatomic,retain) NSMutableArray *reservationData;
@property (nonatomic,retain) EVStations *currentstation;
@property (nonatomic,retain) NSString *currentconnectorid;
@property (nonatomic,retain) NSString *currentconnctIndex;
@property (nonatomic,retain) NSString *currentStartTime;
@property (nonatomic,retain) NSString *currentEndTime;

@end
