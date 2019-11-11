//
//  FAMapPin.m
//  FollowersApp
//
//  Created by SICS on 31/01/14.
//  Copyright (c) 2014 Farhan Yousuf. All rights reserved.
//

#import "EVMapPin.h"

@implementation EVMapPin
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize tagIndex;
@synthesize relationship;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description tag:(NSUInteger)tag withStation:(EVStations *)station {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = placeName;
        subtitle = description;
        tagIndex = tag;
        _stationSelected = station;
    }
    return self;
}

@end
