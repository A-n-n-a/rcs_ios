//
//  EVSchedule.m
//  EVCompany
//
//  Created by Zins on 11/14/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVSchedule.h"
#import "NSMutableData+ReadWrite.h"

@implementation EVSchedule

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString *)getWeekDaysString {
    
    NSMutableString *result = [NSMutableString new];
    NSMutableArray<NSString *> *daysOfWeek = [NSMutableArray<NSString *> new];
    
    if (_monday) {
        [daysOfWeek addObject:@"Mon"];
    }
    if (_tuestay) {
        [daysOfWeek addObject:@"Tue"];
    }
    if (_wednesday) {
        [daysOfWeek addObject:@"Wed"];
    }
    if (_thursday) {
        [daysOfWeek addObject:@"Thu"];
    }
    if (_friday) {
        [daysOfWeek addObject:@"Fri"];
    }
    if (_saturday) {
        [daysOfWeek addObject:@"Sat"];
    }
    if (_sunday) {
        [daysOfWeek addObject:@"Sun"];
    }
    if (daysOfWeek.count == 0) {
        return nil;
    } else if (daysOfWeek.count == 1) {
        return [daysOfWeek objectAtIndex:0];
    } else {
        for (int dayId = 0; dayId < daysOfWeek.count - 1; dayId++) {
            [result appendString:[daysOfWeek objectAtIndex:dayId]];
            [result appendString:@", "];
        }
        [result appendString:[daysOfWeek lastObject]];
        return result;
    }
}

- (NSString *)scheduleTimeString {
    return [NSString stringWithFormat:@"%@ - %@", [self getTimeStart], [self getTimeEnd]];
}

- (NSString *)getTimeStart {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:_timeStart];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mmtt"];
    return [NSString stringWithFormat:@"%@", [self fromIntToTimeStr:_timeStart]];
}

- (NSString *)getTimeEnd {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:_timeEnd];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mmtt"];
    return [NSString stringWithFormat:@"%@", [self fromIntToTimeStr:_timeEnd]];
}

- (instancetype)initWithData:(NSMutableData *)data {
    if (self = [self init]) {
        _monday = [data readBool];
        _tuestay = [data readBool];
        _wednesday = [data readBool];
        _thursday = [data readBool];
        _friday = [data readBool];
        _saturday = [data readBool];
        _sunday = [data readBool];
        _timeStart = [data readUInt32Little];
        _timeEnd = [data readUInt32Little];
        _kWHLimitPerWeek = [data readInt];
    }
    return self;
}

- (NSData *)getData {
    NSMutableData *data = [NSMutableData new];
    [data writeBool:_monday];
    [data writeBool:_tuestay];
    [data writeBool:_wednesday];
    [data writeBool:_thursday];
    [data writeBool:_friday];
    [data writeBool:_saturday];
    [data writeBool:_sunday];
    [data writeInt:_timeStart];
    [data writeInt:_timeEnd];
    return data;
}

- (NSString *)fromIntToTimeStr:(uint32_t)elapsedSeconds {
    NSUInteger h = elapsedSeconds / 3600;
    NSUInteger m = (elapsedSeconds - h * 3600) / 60;
    
    return [NSString stringWithFormat:@"%02lu:%02lu %@", h >= 12 ? h - 12 : h, m, h >= 12 ? @"pm" : @"am"];
}

- (id)copyWithZone:(NSZone *)zone {
    EVSchedule *schedule = [EVSchedule new];
    schedule.monday = self.monday;
    schedule.tuestay = self.tuestay;
    schedule.wednesday = self.wednesday;
    schedule.thursday = self.thursday;
    schedule.friday = self.friday;
    schedule.saturday = self.saturday;
    schedule.sunday = self.sunday;
    schedule.timeStart = self.timeStart;
    schedule.timeEnd = self.timeEnd;
    schedule.kWHLimitPerWeek = self.kWHLimitPerWeek;
    return schedule;
}

@end
