//
//  DirectionParser.m
//  MapDirections
//
//  Created by Vignesh R on 30/05/12.
//  Copyright (c) 2012 vignesh.raj@srishtis.com. All rights reserved.
//

#import "DirectionParser.h"

@implementation DirectionParser
@synthesize delegate;
-(void)findDirectionArrayFrom:(CLLocation*)source to:(CLLocation*)destination{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *sourceString = [NSString stringWithFormat:@"%f,%f",source.coordinate.latitude,source.coordinate.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f",destination.coordinate.latitude,destination.coordinate.longitude];
    
    // NSString *urlString = @"http://maps.googleapis.com/maps/api/directions/json?origin=8.556778,76.881665&destination=8.885483,76.595463&sensor=false";
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false",sourceString,destinationString];
    
    responsseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *connection  = [[NSURLConnection alloc] initWithRequest:request delegate:self ];

    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(directionParser:didFailParsingWithError:)]) {
        [self.delegate directionParser:self didFailParsingWithError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responsseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError *error;
    id resultJson = [NSJSONSerialization JSONObjectWithData:responsseData options:kNilOptions error:&error];

//    NSMutableArray  *pointsArray = [[NSMutableArray alloc] init];
    NSString *status = [resultJson objectForKey:@"status"];
    if ([status isEqualToString:@"OK"]) {
        
        self.distance = [[[[[[resultJson objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"distance"] objectForKey:@"text"];
        

        NSArray *routes  = [resultJson objectForKey:@"routes"];
        NSArray  *polyLines = [self getPolyLinesFromRoute:routes];
        if ([polyLines count]>0) {
            
            if (self.delegate&&[self.delegate respondsToSelector:@selector(directionParser:didFInishParsingPolyline:)]) {
                MKPolyline *polyline =  [self polylineWithEncodedStrings:polyLines];
                [self.delegate directionParser:self didFInishParsingPolyline:polyline];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];                
            }
        }
        else {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(directionParser:didFailParsingWithError:)]) {
                NSError *error = [NSError errorWithDomain:@"DirectionParser error" code:-101 userInfo:nil];
                [self.delegate directionParser:self didFailParsingWithError:error];                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        }
        
    }else{
        NSError *error = [NSError errorWithDomain:@"DirectionParser error" code:-101 userInfo:nil];
        [self.delegate directionParser:self didFailParsingWithError:error];

    }
}

-(NSArray*)getPolyLinesFromRoute:(id)routes{
    NSMutableArray *anArray = [[NSMutableArray alloc] init];    
    
    if ([routes count]>0) {
        NSArray *legs    = [[routes objectAtIndex:0] objectForKey:@"legs"];
        if ([legs count]>0) {
            NSArray *steps    = [[legs objectAtIndex:0] objectForKey:@"steps"];
            for (id step in steps) {
                NSString *polyLine = [[step objectForKey:@"polyline"] objectForKey:@"points"];
                [anArray addObject:polyLine];
            }
        }
    }
    return anArray;
}

- (MKPolyline *)polylineWithEncodedStrings:(NSArray *)encodedStrings {
    
    NSUInteger totalLength = [self getTotalLengthOfArray:encodedStrings];
   
    NSUInteger count = totalLength / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    for (NSString *encodedString in encodedStrings) {
        const char *bytes = [encodedString UTF8String];
        NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSUInteger idx = 0;
        
        float latitude = 0;
        float longitude = 0;
        while (idx < length) {
            char byte = 0;
            int res = 0;
            char shift = 0;
            
            do {
                byte = bytes[idx++] - 63;
                res |= (byte & 0x1F) << shift;
                shift += 5;
            } while (byte >= 0x20);
            
            float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
            latitude += deltaLat;
            
            shift = 0;
            res = 0;
            
            do {
                byte = bytes[idx++] - 0x3F;
                res |= (byte & 0x1F) << shift;
                shift += 5;
            } while (byte >= 0x20);
            
            float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
            longitude += deltaLon;
            
            float finalLat = latitude * 1E-5;
            float finalLon = longitude * 1E-5;
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
            coords[coordIdx++] = coord;
            
            if (coordIdx == count) {
                NSUInteger newCount = count + 10;
                coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
                count = newCount;
            }
        }
        
    }
     MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
        free(coords);
    return polyline;
}

-(NSUInteger)getTotalLengthOfArray:(NSArray*)array{
    NSUInteger length = 0;
    for (NSString *aString in array) {
        length += [aString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    }
    return length;
}

@end
