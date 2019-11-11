//
//  EVListReservationViewController.h
//  EVCompany
//
//  Created by GridScape on 10/20/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVStations.h"

@interface EVListReservationViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic,retain) EVStations *station;
@property (nonatomic,retain) NSString *connectorDesc;
@property (nonatomic,retain) NSString *connectorId;
@property (nonatomic,retain) NSString *connctIndex;

@end
