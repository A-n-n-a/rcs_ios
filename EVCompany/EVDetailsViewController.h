//
//  EVDetailsViewController.h
//  EVCompany
//
//  Created by Srishti on 19/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVStations.h"

@interface EVDetailsViewController : UITableViewController<UIActionSheetDelegate>
@property (nonatomic,retain)EVStations *station;
@property (nonatomic,retain)NSString *previousView;

@end
