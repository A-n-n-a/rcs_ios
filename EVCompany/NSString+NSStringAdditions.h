//
//  NSString+NSStringAdditions.h
//  iClubTonight
//
//  Created by Bilal on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringAdditions)

+ (NSString *) escapedString:(NSString *)text;
- (NSString *) escape;
- (NSString *) md5;
@end
