//
//  AddressAnnotation.h
//  iClubTonight
//
//  Created by Russel on 02/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AddressAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *mTitle;
	NSString *mSubTitle;
	NSInteger *mTag;
}
@property (nonatomic,retain)NSString *mTitle;
@property (nonatomic,assign)NSInteger *mTag;
@property (nonatomic,retain)NSString *mSubTitle;
-(id)initWithCoordinate:(CLLocationCoordinate2D) c;

@end
