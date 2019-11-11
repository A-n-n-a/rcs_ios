//
//  EVReservationListViewController.h
//  EVCompany
//
//  Created by GridScape on 2/25/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVStations.h"

@protocol EVReservationModalDelegate <NSObject>

-(void)showModalWithMessage:(NSString*)message;
-(void)showModalWithMessage:(NSString*)message forDuration:(CGFloat)duration;
-(void)hideModal;

@end

@interface EVReservationListViewController : UIViewController <EVReservationModalDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segment_outlet;

@property (strong, nonatomic) IBOutlet UIView *parentView_outlet;
@property (nonatomic,retain) NSMutableArray *reservationData;
@property (nonatomic,retain) EVStations *currentstation;
@property (nonatomic,retain) NSString *currentconnectorid;
@property (nonatomic,retain) NSString *currentconnctIndex;
@property (nonatomic,retain) NSString *currentStartTime;
@property (nonatomic,retain) NSString *currentEndTime;

- (IBAction)segmentValueChanged:(id)sender;

@end
