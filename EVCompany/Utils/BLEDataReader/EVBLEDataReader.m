//
//  EVBLEDataReader.m
//  EVCompany
//
//  Created by Zins on 11/10/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVBLEDataReader.h"
#import "NSMutableData+ReadWrite.h"

@implementation EVBLEDataReader

+ (BOOL)readIsCharging:(NSData *)data {
    return [[NSMutableData dataWithData:data] readBool];
}

+ (float)readKWH:(NSData *)data {
    return [[NSMutableData dataWithData:data] readFloat];
}

+ (float)readAmperage:(NSData *)data {
    return [[NSMutableData dataWithData:data] readFloat];
}

+ (uint32_t)readDuration:(NSData *)data {
    return [[NSMutableData dataWithData:data] readInt];
}

+ (float)readCost:(NSData *)data {
    return [[NSMutableData dataWithData:data] readFloat];
}

+ (NSDate *)readStartDate:(NSData *)data {
    uint32_t timestamp =[[NSMutableData dataWithData:data] readUInt32Little];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
    return date;
}

+ (EVSchedule *)readSchedule:(NSData *)data {
    return [[EVSchedule alloc] initWithData:[NSMutableData dataWithData:data]];
}

+ (int)readStatus:(NSData *)data {
    return [[NSMutableData dataWithData:data] readInt];
}


+ (NSString *)readName:(NSData *)data {
    return [[NSMutableData dataWithData:data] readString];
}

+ (BOOL)readStartStop:(NSData *)data {
    return [[NSMutableData dataWithData:data] readBool];
}


@end
