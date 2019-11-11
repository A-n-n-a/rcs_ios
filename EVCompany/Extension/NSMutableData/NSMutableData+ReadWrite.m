//
//  EVNSMutableData+ReadWrite.m
//  EVCompany
//
//  Created by Zins on 11/9/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "NSMutableData+ReadWrite.h"

@implementation NSMutableData (ReadWrite)

#pragma mark - Read

- (char)readByte {
    char value = *(char*)([[self subdataWithRange:NSMakeRange(0, 1)] bytes]);
    [self replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
    return value;
}

- (short)readShort {
    short value = CFSwapInt16BigToHost(*(short*)([[self subdataWithRange:NSMakeRange(0, 2)] bytes]));
    [self replaceBytesInRange:NSMakeRange(0, 2) withBytes:NULL length:0];
    return value;
}

- (int)readInt {
    if (self.length == 0) {
        return 0;
    }
    int value = CFSwapInt32HostToLittle(*(int*)([[self subdataWithRange:NSMakeRange(0, 4)] bytes]));
    [self replaceBytesInRange:NSMakeRange(0, 4) withBytes:NULL length:0];
    return value;
}

- (uint32_t)readUInt32 {
    if (self.length == 0) {
        return 0;
    }
    uint32_t value = CFSwapInt32HostToBig(*(uint32_t*)([[self subdataWithRange:NSMakeRange(0, 4)] bytes]));
    [self replaceBytesInRange:NSMakeRange(0, 4) withBytes:NULL length:0];
    return value;
}

- (uint32_t)readUInt32Little {
    if (self.length == 0) {
        return 0;
    }
    uint32_t value = CFSwapInt32HostToLittle(*(uint32_t*)([[self subdataWithRange:NSMakeRange(0, 4)] bytes]));
    [self replaceBytesInRange:NSMakeRange(0, 4) withBytes:NULL length:0];
    return value;
}


- (long long)readLong {
    long long value = CFSwapInt64BigToHost(*(long long*)([[self subdataWithRange:NSMakeRange(0, 8)] bytes]));
    [self replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
    return value;
}


- (double)readDouble {
    double doubleValue;
    [[self subdataWithRange:NSMakeRange(0, 8)] getBytes:&doubleValue length:sizeof(double)];
    [self replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
    return doubleValue;
}

- (float)readFloat {
    float floatValue;
    [[self subdataWithRange:NSMakeRange(0, 4)] getBytes:&floatValue length:4];
    [self replaceBytesInRange:NSMakeRange(0, 4) withBytes:NULL length:0];
    return floatValue;
}

- (BOOL)readBool {
    char value = *(char*)([[self subdataWithRange:NSMakeRange(0, 1)] bytes]);
    [self replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
    return [@(value) boolValue];
}

- (NSString *)readString{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

#pragma mark - Write

- (void)writeBool:(BOOL)value {
    char _value = [@(value) intValue];
    [self appendBytes:&_value length:sizeof(uint8_t)];
}

- (void)writeSting:(NSString *)value {
    NSData *_valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self appendData:_valueData];
}

- (void)writeInt:(int)value {
    NSMutableArray *bytesArray = [NSMutableArray arrayWithCapacity:4];
    int _value = value;
    char mask8Bit = 0xFF;
    
    for (char i = sizeof(int); i > 0; i--) {
        char v = _value & mask8Bit;
        [bytesArray insertObject:@(v) atIndex:0];
        _value >>= 8;
    }
    
    for (NSNumber *number in bytesArray) {
        char result = [number charValue];
        [self appendBytes:&result length:1];
    }
}


@end
