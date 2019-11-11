//
//  EVAes256Encryption.h
//  EVCompany
//
//  Created by Anna on 11/21/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVSchedule.h"

@interface EVAes128EncryptionManager: NSObject  


+ (NSData*)encryptBool:(bool)boolValue withKey:(NSData *)key iv:(NSData *)iv;
+ (NSData*)encryptFloat:(float)floatValue withKey:(NSData *)key iv:(NSData *)iv;
+ (NSData*)encryptInt:(int)intValue withKey:(NSData *)key iv:(NSData *)iv;
+ (NSData*)encryptSchedule:(EVSchedule*)schedule withKey:(NSData *)key iv:(NSData *)iv;

@end

