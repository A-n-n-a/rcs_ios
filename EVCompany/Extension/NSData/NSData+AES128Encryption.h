//
//  NSData+AES256Encryption.h
//  EVCompany
//
//  Created by Anna on 11/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSchedule.h"

@interface NSData (AES128Encryption)

- (NSData *)AES128EncryptedDataWithKey:(NSData *)key iv:(NSData *)iv;
- (NSData *)AES128DecryptedDataWithKey:(NSData *)key iv:(NSData *)iv;
- (NSString*)decryptToStringWithKey:(NSData *)key iv:(NSData *)iv;
- (BOOL)decryptToBoolWithKey:(NSData *)key iv:(NSData *)iv;
- (float)decryptToFloatWithKey:(NSData *)key iv:(NSData *)iv;
- (int)decryptToIntWithKey:(NSData *)key iv:(NSData *)iv;
- (NSDate*)decryptToDateWithKey:(NSData *)key iv:(NSData *)iv;
- (EVSchedule*)decryptToScheduleWithKey:(NSData *)key iv:(NSData *)iv;

@end
