//
//  DirectionParser.h
//  MapDirections
//
//  Created by Vignesh R on 30/05/12.
//  Copyright (c) 2012 vignesh.raj@srishtis.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CLLocation.h"
#import <MapKit/MKPolyline.h>
@protocol directioParserDelegate
-(void)directionParser:(id)parser didFailParsingWithError:(NSError*)error;
-(void)directionParser:(id)parser didFInishParsingPolyline:(MKPolyline*)polyline;
@end
@interface DirectionParser : NSObject{
    NSMutableData *responsseData;
    id <directioParserDelegate> delegate;
    
}

@property (retain) id delegate;
@property (nonatomic,retain) NSString *distance;

-(void)findDirectionArrayFrom:(CLLocation*)source to:(CLLocation*)destination;
-(MKPolyline *)polylineWithEncodedStrings:(NSArray *)encodedStrings;
-(NSArray*)getPolyLinesFromRoute:(id)routes;
-(NSUInteger)getTotalLengthOfArray:(NSArray*)array;
@end
