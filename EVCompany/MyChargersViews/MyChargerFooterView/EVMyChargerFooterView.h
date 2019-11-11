//
//  EVMyChargerFooterView.h
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChargerStartStopButtonDelegate <NSObject>

- (void)startButtonClicked:(id)sender;
- (void)stopButtonClicked:(id)sender;

@end

@interface EVMyChargerFooterView : UITableViewHeaderFooterView

@property (nonatomic, weak) id<ChargerStartStopButtonDelegate> delegate;

@property (nonatomic, assign) long long identifier;

@end
