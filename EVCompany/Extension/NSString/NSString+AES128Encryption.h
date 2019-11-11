//
//  NSString+AES128Encryption.h
//  EVCompany
//
//  Created by Anna on 11/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AES128Encryption)

- (NSData*)encryptWithKey:(NSString*)key;

@end
