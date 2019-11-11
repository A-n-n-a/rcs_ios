//
//  GeoCoder.m
//  GoogleMapDemo
//
//  Created by Siju karunakaran on 10/1/13.
//  Copyright (c) 2013 Srishti Innovative. All rights reserved.
//

#import "GeoCoder.h"
#import "NSString+NSStringAdditions.h"
@interface GeoCoder()<NSURLConnectionDataDelegate>
@end
@implementation GeoCoder
{
    NSMutableData *geodata;
    void (^finishGeoCoding)(CLLocation *);
    void (^finishedReverseGeocoding)(NSDictionary *);

}
-(void)geoCodeAddress:(NSString *)address inBlock:(void (^)(CLLocation *))completionBlock{
    
    finishGeoCoding = completionBlock;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",[address escape]]]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
}
-(void)reverseGeoCode:(CLLocation *)location inBlock:(void (^)(NSDictionary *))completionBlock{
    
    finishedReverseGeocoding = completionBlock;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",location.coordinate.latitude,location.coordinate.longitude]]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    geodata = [NSMutableData data];
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [geodata appendData:data];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    id jsonData = [NSJSONSerialization JSONObjectWithData:geodata options:kNilOptions error:nil];

    if (finishGeoCoding) {
        if([jsonData[@"status"] isEqualToString: @"ZERO_RESULTS"])
        {
          CLLocation *location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
           finishGeoCoding(location);
            return;
        }else{
        id lattitude = jsonData[@"results"][0][@"geometry"][@"location"][@"lat"];
        id longitude = jsonData[@"results"][0][@"geometry"][@"location"][@"lng"];

        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[lattitude doubleValue] longitude:[longitude doubleValue]];
        
        finishGeoCoding(location);
        
        return;
        }
    }
    NSMutableDictionary *dictionaryAddress = [[NSMutableDictionary alloc]init];
    if(![jsonData[@"error_message"] isEqualToString:@"You have exceeded your daily request quota for this API."]){
    NSString *stringState,*stringPostCode,*country,*countryCode;
        NSArray *root = jsonData[@"results"];
        if (root.count!=0) {
            NSArray *arrayAddressComponents = [[root objectAtIndex:0] objectForKey:@"address_components"];
            for (NSDictionary *dict in arrayAddressComponents) {
                if ([[[dict objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_1"])
                {
                    
                    stringState = [dict objectForKey:@"short_name"];
                    
                    
                }
                if([[[dict objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"postal_code"]){
                    stringPostCode=[dict objectForKey:@"long_name"];
                }
                if([[[dict objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"country"]){
                    country = [dict objectForKey:@"long_name"];
                    countryCode = [dict objectForKey:@"short_name"];
                }
                
            }
//             NSLog(@"json %@",jsonData[@"results"]);
//            NSLog(@"state %@",stringCountry);
//            dictionaryAddress = [[NSMutableDictionary alloc]init];
//            [dictionaryAddress setObject:stringCountry forKey:@"country"];
//            if (![stringCity isKindOfClass:[NSNull class]]&&stringCity.length!=0) {
//                [dictionaryAddress setObject:stringCity forKey:@"city"];
//            }else{
//                [dictionaryAddress setObject:stringCountry forKey:@"city"];
//            }
           
            [dictionaryAddress setObject:stringState forKey:@"state"];
            (stringPostCode.length > 0)?[dictionaryAddress setObject:stringPostCode forKey:@"postcode"]:[dictionaryAddress setObject:@"" forKey:@"postcode"];
            if(country.length > 0){
                [dictionaryAddress setObject:country forKey:@"country"];
                [dictionaryAddress setObject:countryCode forKey:@"countryCode"];
            }
            [dictionaryAddress setObject:jsonData[@"results"][0][@"formatted_address"] forKey:@"address"];
            finishedReverseGeocoding(dictionaryAddress);
        }
        
          finishedReverseGeocoding(dictionaryAddress);
        }
        
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    finishGeoCoding?
        finishGeoCoding(nil):
        finishedReverseGeocoding(nil);
    
}


@end
