//
//  NSString+AES128Encryption.m
//  EVCompany
//
//  Created by Anna on 11/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "NSData+AES128Encryption.h"
#import "NSString+AES128Encryption.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (AES128Encryption)

- (NSData*)encryptWithKey:(NSString*)key {
    
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = nil;
    
    return encryptedData;
}

@end

