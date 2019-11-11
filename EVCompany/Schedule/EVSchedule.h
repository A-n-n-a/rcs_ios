//
//  EVSchedule.h
//  EVCompany
//
//  Created by Zins on 11/14/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVSchedule : NSObject <NSCopying>

@property (nonatomic, assign) BOOL monday;
@property (nonatomic, assign) BOOL tuestay;
@property (nonatomic, assign) BOOL wednesday;
@property (nonatomic, assign) BOOL thursday;
@property (nonatomic, assign) BOOL friday;
@property (nonatomic, assign) BOOL saturday;
@property (nonatomic, assign) BOOL sunday;
@property (nonatomic, assign) int timeStart;
@property (nonatomic, assign) int timeEnd;
@property (nonatomic, assign) long kWHLimitPerWeek;

- (instancetype)initWithData:(NSMutableData *)data;
- (NSString *)getWeekDaysString;
- (NSString *)scheduleTimeString;
- (NSData *)getData;
- (NSString *)getTimeStart;
- (NSString *)getTimeEnd;

@end
