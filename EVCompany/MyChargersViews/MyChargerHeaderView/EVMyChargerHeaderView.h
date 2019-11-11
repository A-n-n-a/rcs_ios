//
//  EVMyChargerHeaderView.h
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVCharger.h"

@interface EVMyChargerHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) EVCharger *currentCharger;

- (void)setupHeaderView:(NSString *)name progress:(float)progress;

@end
