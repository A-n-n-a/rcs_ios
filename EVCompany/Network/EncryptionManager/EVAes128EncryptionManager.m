//
//  EVaes256Encryption.m
//  EVCompany
//
//  Created by Anna on 11/21/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVAes128EncryptionManager.h"
#import "EVSchedule.h"
#import "NSData+AES128Encryption.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation EVAes128EncryptionManager

+ (NSData*)encryptBool:(bool)boolValue withKey:(NSData *)key iv:(NSData *)iv {
    
    NSData *data = [NSData dataWithBytes:&boolValue length:sizeof(boolValue)];
    NSData *encryptedData = [data AES128EncryptedDataWithKey:key iv:iv];
    return encryptedData;
}

+ (NSData*)encryptFloat:(float)floatValue withKey:(NSData *)key iv:(NSData *)iv {
    
    NSData *data = [NSData dataWithBytes:&floatValue length:sizeof(floatValue)];
    NSData *encryptedData = [data AES128EncryptedDataWithKey:key iv:iv];
    return encryptedData;
}

+ (NSData*)encryptInt:(int)intValue withKey:(NSData *)key iv:(NSData *)iv {
    
    NSData *data = [NSData dataWithBytes: &intValue length:sizeof(intValue)];
    NSData *encryptedData = [data AES128EncryptedDataWithKey:key iv:iv];
    return encryptedData;
}

+ (NSData*)encryptSchedule:(EVSchedule*)schedule withKey:(NSData *)key iv:(NSData *)iv {
    NSData *data = [schedule getData];
    return [data AES128EncryptedDataWithKey:key iv:iv];
}

@end
