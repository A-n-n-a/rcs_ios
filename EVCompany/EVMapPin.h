//
//  FAMapPin.h
//  FollowersApp
//
//  Created by SICS on 31/01/14.
//  Copyright (c) 2014 Farhan Yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "EVStations.h"

@interface EVMapPin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) int tagIndex;
@property(nonatomic, readonly)NSString *relationship;
@property (nonatomic, readonly)EVStations *stationSelected;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description tag:(NSUInteger)tag withStation:(EVStations *)station;

@end
