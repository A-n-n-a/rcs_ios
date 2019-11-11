//
//  GeoCoder.h
//  GoogleMapDemo
//
//  Created by Siju karunakaran on 10/1/13.
//  Copyright (c) 2013 Srishti Innovative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface GeoCoder : NSObject
-(void)geoCodeAddress:(NSString *)address inBlock:(void(^)(CLLocation *))completionBlock;
-(void)reverseGeoCode:(CLLocation *)location inBlock:(void (^)(NSDictionary *))completionBlock;
@end
