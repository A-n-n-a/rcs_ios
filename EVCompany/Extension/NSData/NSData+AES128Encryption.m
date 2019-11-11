//
//  NSData + AES256Encryption.m
//  EVCompany
//
//  Created by Anna on 11/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "NSData+AES128Encryption.h"
#import "NSMutableData+ReadWrite.h"
#import "EVSchedule.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES128Encryption)

- (NSData *)AES128EncryptedDataWithKey:(NSData *)key iv:(NSData *)iv {
    return [self AES128OperationWithEncriptionMode:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptedDataWithKey:(NSData *)key iv:(NSData *)iv {
    return [self AES128OperationWithEncriptionMode:kCCDecrypt key:key iv:iv];
}


- (NSData *)AES128OperationWithEncriptionMode:(CCOperation)operation key:(NSData *)key iv:(NSData *)iv {
    
    
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = CCCryptorCreateWithMode(operation, kCCModeCFB, kCCAlgorithmAES128, ccNoPadding, [iv bytes], [key bytes], [key length], NULL, 0, 0, kCCModeOptionCTR_LE, &cryptor);
    
    NSAssert(status == kCCSuccess, @"Failed to create a cryptographic context.");
    
    NSMutableData *retData = [NSMutableData new];
    
    NSMutableData *buffer = [NSMutableData data];
    [buffer setLength:CCCryptorGetOutputLength(cryptor, [self length], true)];
    
    size_t dataOutMoved;
    status = CCCryptorUpdate(cryptor, self.bytes, self.length, buffer.mutableBytes, buffer.length, &dataOutMoved);
    NSAssert(status == kCCSuccess, @"Failed to encrypt or decrypt data");
    [retData appendData:[buffer subdataWithRange:NSMakeRange(0, dataOutMoved)]];
    
    status = CCCryptorFinal(cryptor, buffer.mutableBytes, buffer.length, &dataOutMoved);
    NSAssert(status == kCCSuccess, @"Failed to finish the encrypt or decrypt operation");
    [retData appendData:[buffer subdataWithRange:NSMakeRange(0, dataOutMoved)]];
    CCCryptorRelease(cryptor);
    
    return [retData copy];
}

- (NSString*)decryptToStringWithKey:(NSData *)key iv:(NSData *)iv {
    NSData *decryptedData = [self AES128DecryptedDataWithKey:key iv:iv];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

- (BOOL)decryptToBoolWithKey:(NSData*)key iv:(NSData *)iv {
    NSData *decryptedData = [self AES128DecryptedDataWithKey:key iv:iv];
    float boolValue = [decryptedData.mutableCopy readBool];
    return boolValue;
}

- (float)decryptToFloatWithKey:(NSData *)key iv:(NSData *)iv {
    NSData *decryptedData = [self AES128DecryptedDataWithKey:key iv:iv];
    float floatValue = [decryptedData.mutableCopy readFloat];
    return floatValue;
}

- (int)decryptToIntWithKey:(NSData *)key iv:(NSData *)iv {
    NSData *decryptedData = [self AES128DecryptedDataWithKey:key iv:iv];
    float intValue = [decryptedData.mutableCopy readInt];
    return intValue;
}

- (NSDate*)decryptToDateWithKey:(NSData *)key iv:(NSData *)iv {
    NSData *decryptedData = [self AES128DecryptedDataWithKey:key iv:iv];
    uint32_t timestamp =[decryptedData.mutableCopy readUInt32Little];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
    return date;
}

- (EVSchedule*)decryptToScheduleWithKey:(NSData *)key iv:(NSData *)iv {
    NSData *decryptedData = [self AES128DecryptedDataWithKey:key iv:iv];
    return [[EVSchedule alloc] initWithData:decryptedData.mutableCopy];
}
@end

