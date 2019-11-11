//
//  EVNSMutableData+ReadWrite.h
//  EVCompany
//
//  Created by Zins on 11/9/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (ReadWrite)


#pragma mark - Read

- (char)readByte;
- (short)readShort;
- (int)readInt;
- (uint32_t)readUInt32;
- (uint32_t)readUInt32Little;
- (long long)readLong;
- (float)readFloat;
- (double)readDouble;
- (BOOL)readBool;
- (NSString *)readString;
- (NSString *)readUTF;

#pragma mark Write

- (void)writeBool:(BOOL)value;
- (void)writeSting:(NSString *)value;
- (void)writeInt:(int)value;

@end
