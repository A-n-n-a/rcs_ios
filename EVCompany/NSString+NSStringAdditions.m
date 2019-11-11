//
//  NSString+NSStringAdditions.m
//  iClubTonight
//
//  Created by Bilal on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+NSStringAdditions.h"

@implementation NSString (NSStringAdditions)

+ (NSString *) escapedString:(NSString *)text
{
	return ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 ( CFStringRef)text,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}


- (NSString *) escape{
    return ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 ( CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}
- (NSString *) md5
{
    //const char *cStr = [self UTF8String];
    unsigned char result[16];
    //CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}
@end
