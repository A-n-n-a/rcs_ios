//
//  EVMyChargerScheduleTableViewCell.m
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVMyChargerScheduleTableViewCell.h"
#import "EVCharger.h"

@interface EVMyChargerScheduleTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;


@end

@implementation EVMyChargerScheduleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleUpdated:) name:@"ChargerScheduleDidUpdated" object:nil];
}

- (void)setupCell:(NSString *)value {
    self.valueLabel.text = value;
}

-(void)scheduleUpdated:(NSNotification *)notif {
    EVCharger *charger = [notif object];
    NSString *daysOfWeek = [charger.schedule getWeekDaysString];
    NSString *startStopTime = [charger.schedule scheduleTimeString];
    NSString *kWtHForDay = [NSString stringWithFormat:@"%ld kWt/h for week", charger.schedule.kWHLimitPerWeek];
    NSString *result;
    if (charger.schedule.kWHLimitPerWeek != 0) {
        result = [NSString stringWithFormat:@"%@", kWtHForDay];
    } else if (daysOfWeek != nil && startStopTime != nil){
        result = [NSString stringWithFormat:@"%@\n%@", daysOfWeek, startStopTime];
    } else {
        result = @"";
    }
    self.valueLabel.text = result;
    [self setNeedsDisplay];
}
@end
