//
//  AddressAnnotation.m
//  iClubTonight
//
//  Created by Russel on 02/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"


@implementation AddressAnnotation

@synthesize mTitle;
@synthesize mTag;
@synthesize mSubTitle;
@synthesize coordinate;
- (NSString *)subtitle{
	return mSubTitle;
}

- (NSString *)title{
	return mTitle;
}
- (NSInteger *)tag{
	return mTag;
}
-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end
