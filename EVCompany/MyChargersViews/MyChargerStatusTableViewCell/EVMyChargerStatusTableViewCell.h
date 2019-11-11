//
//  EVMyChargerStatusTableViewCell.h
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVCharger.h"

@interface EVMyChargerStatusTableViewCell : UITableViewCell

@property (strong, nonatomic) EVCharger *currentCharger;

- (void)setupCell:(NSString *)status;
- (void)setupCell:(NSString *)status kWh:(NSString *)kWh amperage:(NSString *)amperage duration:(NSString *)duration cost:(NSString *)cost;

@end
