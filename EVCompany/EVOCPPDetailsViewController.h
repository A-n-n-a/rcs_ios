//
//  EVOCPPDetailsViewControllerTableViewController.h
//  EVCompany
//
//  Created by GridScape on 11/27/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVStations.h"
#import "EVReservationListViewController.h"
@interface EVOCPPDetailsViewController : UITableViewController<UIActionSheetDelegate, EVReservationModalDelegate>

@property (nonatomic,retain)EVStations *station;
@property (nonatomic,retain)NSString *previousView;

@end
