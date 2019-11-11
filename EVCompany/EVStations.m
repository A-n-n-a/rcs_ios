//
//  EVStations.m
//  EVCompany
//
//  Created by Srishti on 11/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVStations.h"
#import "NSMutableData+PostDataAdditions.h"
#import "EVWebService.h"
#import "NSMutableData+PostDataAdditions.h"
#import <MapKit/MapKit.h>
#import "EVAppDelegate.h"
#import "EVOCPPWebService.h"
#import "config.h"
#import "UserSetting.h"

#define degreesToRadians(x) (M_PI * x / 180.0) 
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@implementation EVStations
-(id)initWithDataFromDictionary:(NSDictionary*)dataDictionary{
    
    self=[super init];
    if (self)
    {
        if(![dataDictionary[@"UsageType"] isKindOfClass:[NSNull class]])
            self.usageType = dataDictionary[@"UsageType"][@"Title"];
        else
            self.usageType = @"";
        if(![dataDictionary[@"AddressInfo"] isKindOfClass:[NSNull class]]){
            self.title = dataDictionary[@"AddressInfo"][@"Title"];
            self.adderssline1 = dataDictionary[@"AddressInfo"][@"AddressLine1"];
            self.town = dataDictionary[@"AddressInfo"][@"Town"];
            self.stateOrProvince = dataDictionary[@"AddressInfo"][@"StateOrProvince"];
            self.postCode = dataDictionary[@"AddressInfo"][@"Postcode"];
            self.latitude = dataDictionary[@"AddressInfo"][@"Latitude"];
            self.longitude = dataDictionary[@"AddressInfo"][@"Longitude"];
            self.contactTelephone1 = dataDictionary[@"AddressInfo"][@"ContactTelephone1"];
            self.contactTelephone2 = dataDictionary[@"AddressInfo"][@"ContactTelephone2"];
            self.descriptions = dataDictionary[@"AddressInfo"][@"AccessComments"];
            
        }else{
            self.title = @"";
            self.adderssline1 = @"";
            self.town = @"";
            self.stateOrProvince = @"";
            self.postCode = @"";
            self.latitude = @"";
            self.longitude = @"";
            self.contactTelephone1 = @"";
            self.contactTelephone2 = @"";
            self.descriptions = @"";
            
        }
        if(![dataDictionary[@"OperatorInfo"] isKindOfClass:[NSNull class]]){
            self.operatorInfo = dataDictionary[@"OperatorInfo"][@"Title"];
        }else self.operatorInfo = @"";
        if(![dataDictionary[@"Connections"] isKindOfClass:[NSNull class]]){
            NSMutableArray *array = [NSMutableArray new];
            [dataDictionary[@"Connections"] enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                [array addObject:obj[@"ConnectionType"][@"Title"]];
                self.connectorType = [array componentsJoinedByString:@","];
            }];
        }else self.connectorType = @"";
        self.distance =[NSString stringWithFormat:@"%.2f",[self calculateDistance:self.latitude :self.longitude]];
        self.distanceInMiles = [self calculateDistance:self.latitude :self.longitude];
        
        if(![dataDictionary[@"StatusType"] isKindOfClass:[NSNull class]])
            self.status= dataDictionary[@"StatusType"][@"Title"];
        else self.status = @"";
        if(![dataDictionary[@"Connections"] isKindOfClass:[NSNull class]]){
            NSMutableArray *arrayPowerlevel = [[NSMutableArray alloc]init];
            NSArray *levels = dataDictionary[@"Connections"];
            [levels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *dict = levels[idx];
                if(![dict[@"Level"]isKindOfClass:[NSNull class]] && ![arrayPowerlevel containsObject:dict[@"Level"][@"Title"] ])
                    
                    [arrayPowerlevel addObject:dict[@"Level"][@"Title"]];
                if(levels.count-1 == idx)
                    self.powerLevel = [arrayPowerlevel componentsJoinedByString:@","];
            }];
            
        }else  self.powerLevel = @"";
        self.isRCS = @"NO";
    }
    return self;
    
}

-(id)initWithDataFromServerWithDictionary:(NSDictionary*)dataDictionary{
    
    self=[super init];
    if (self)
    {
        self.status = dataDictionary[@"Operational_Status"];
        self.powerLevel = dataDictionary[@"powerLevel"];
        self.usageType = dataDictionary[@"usageType"];
        self.title = dataDictionary[@"title"];
        self.adderssline1 = dataDictionary[@"addressline1"];
        self.descriptions = dataDictionary[@"description"];
        self.town = dataDictionary[@"town"];
        self.stateOrProvince = dataDictionary[@"stateOrProvince"];
        self.postCode = dataDictionary[@"postCode"];
        self.latitude = dataDictionary[@"latitude"];
        self.longitude = dataDictionary[@"longitude"];
        self.connectorType = dataDictionary[@"connectorType"];
        self.distance = [NSString stringWithFormat:@"%.2f",[self calculateDistance:self.latitude :self.longitude]];
        self.distanceInMiles = [self calculateDistance:self.latitude :self.longitude];
        self.contactTelephone1= dataDictionary[@"contactTelephone1"];
        self.contactTelephone2= dataDictionary[@"contactTelephone2"];
        self.hoursOfOperation = dataDictionary[@"hours_operation"];
        self.favId = dataDictionary[@"fav_id"];
        self.imageName = dataDictionary[@"image"];
        self.operatorInfo = dataDictionary[@"Operator"];
        
        self.isRCS = @"NO";
    }
    return self;
}

-(id)initWithDataFromOCPPServerWithDictionary:(NSDictionary*)dataDictionary{
    
    self=[super init];
    if (self)
    {
        self.status = dataDictionary[@"ocppChargePointStatus"];
        self.powerLevel = dataDictionary[@"powerLevel"];
        self.usageType = dataDictionary[@"ISPUBLIC"];
        self.title = dataDictionary[@"siteName"];
        self.adderssline1 = dataDictionary[@"address"];
        self.descriptions = dataDictionary[@"description"];
        self.town = dataDictionary[@"town"];
        self.stateOrProvince = dataDictionary[@"stateOrProvince"];
        self.postCode = dataDictionary[@"postCode"];
        self.latitude = dataDictionary[@"latitude"];
        self.longitude = dataDictionary[@"longitude"];
        self.connectorType = dataDictionary[@"connectorType"];
        self.distance = [NSString stringWithFormat:@"%.2f",[self calculateDistance:self.latitude :self.longitude]];
        self.distanceInMiles = [self calculateDistance:self.latitude :self.longitude];
        self.contactTelephone1= dataDictionary[@"contactTelephone1"];
        self.contactTelephone2= dataDictionary[@"contactTelephone2"];
        self.hoursOfOperation = dataDictionary[@"hours_operation"];
        self.favId = dataDictionary[@"fav_id"];
        self.imageName = dataDictionary[@"image"];
        self.operatorInfo = @"RCS";
        
        self.chargerId = dataDictionary[@"chargerId"];
        self.ocppConnectorType = dataDictionary[@"connectorType"];
        self.isApproved = dataDictionary[@"isApproved"];
        self.ocppPowerLevel = dataDictionary[@"powerLevel"];
        self.stationdId = dataDictionary[@"station_id"];
        self.statusTimestamp = dataDictionary[@"statusTimestamp"];
        self.ocppUserId = dataDictionary[@"userId"];
        
        self.isRCS = @"YES";
    }
    return self;
}

//-(double)findDistanceToLat :(NSString *)latTo andToLong :(NSString *)longTo
//{
//     EVAppDelegate *appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
//    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:appDelegete.currentLocation.coordinate.latitude longitude:appDelegete.currentLocation.coordinate.longitude];
//    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:[latTo doubleValue] longitude:[longTo doubleValue]];
//    int distance =[self distanceInMetersFromLocation:location1 toLocation:location2];
//    NSLog(@"distance  value %d",distance);
//    double distanceInMiles = distance * 0.000621371;
//    return distanceInMiles;
//}
//
//- (int)distanceInMetersFromLocation:(CLLocation*)location1 toLocation:(CLLocation*)location2 {
//    CLLocationDistance distanceInMeters = [location1 distanceFromLocation:location2];
//    return distanceInMeters;
//}

-(double)calculateDistance:(NSString * )latitude :(NSString *)longitude{
    
    EVAppDelegate *appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:appDelegete.currentLocation.coordinate.latitude longitude:appDelegete.currentLocation.coordinate.longitude];
    
    //    NSLog(@"degree %f",[self getHeadingForDirectionFromCoordinate:appDelegete.currentLocation.coordinate toCoordinate:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue])]);
    //
    //    float degree = [self getHeadingForDirectionFromCoordinate:appDelegete.currentLocation.coordinate toCoordinate:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue])];
    //
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    double distanceInMiles = distance * 0.000621371;//0.000621371192
    // double distcemile =degree/1609.344;
    return distanceInMiles;
}

//- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
//{
//    float fLat = degreesToRadians(fromLoc.latitude);
//    float fLng = degreesToRadians(fromLoc.longitude);
//    float tLat = degreesToRadians(toLoc.latitude);
//    float tLng = degreesToRadians(toLoc.longitude);
//
//    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
//    if (degree >= 0) {
//        return degree;
//    } else {
//        return 360+degree;
//    }
//}

-(void)makeFavouritewithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    //[self getPropertiesAsData];
    [EVWebService fetchDataFromService:@"favourites.php" withParameters:[self getPropertiesAsData] withCompletionBlock:^(BOOL success, id result, NSError *error) {
        NSLog(@"favourite station result ------>%@",result[@"result"]);
        if(success){
            if([result[@"result"]isEqualToString:@"Success"]){
                completionBlock(YES,@"success",error);
            }else {
                completionBlock(NO,result[@"Error"],error);
            }
        }
    }];
 
}
-(void)listFavouriteStationsWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.userId forKey:@"userID"];
    [EVWebService fetchDataFromService:@"view_fav_station.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            if([result[@"result"]isEqualToString:@"success"]){
                completionBlock(YES,result[@"Stations"],error);
            }else {
                completionBlock(NO,result[@"Stations"],error);
            }
        }else
            completionBlock(NO,@"",error);
    }];
    
}
-(void)deleteFavouriteWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.userId forKey:@"userId"];
    [body addValue:self.favId forKey:@"fav_id"];
    [EVWebService fetchDataFromService:@"del_fav_station.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            if([result[@"result"]isEqualToString:@"Sucess"]){
                completionBlock(YES,@"success",error);
            }else {
                completionBlock(NO,result[@"Error"],error);
            }
        }
    }];
    
}
-(void)addStationsWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    [EVWebService fetchDataFromService:@"add_stationnew.php" withParameters:[self getPropertiesAsData] withCompletionBlock:^(BOOL success, id result, NSError *error) {
        NSLog(@"add station result ------>%@",result);
        if(success){
            if([result[@"result"]isEqualToString:@"Success"]){
                completionBlock(YES,@"success",error);
            }else {
                completionBlock(NO,result[@"Error"],error);
            }
        }
    }];
    
}
-(void)fetchStationsWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.keyType forKey:@"key_type"];
    [body addValue:self.keyValue forKey:@"key_value"];
    [body addValue:self.powerLevel forKey:@"power_level"];
    [body addValue:self.usageType forKey:@"usage_type"];
    [EVWebService fetchDataFromService:@"search_postcode_version2_new.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            if([result[@"result"]isEqualToString:@"success"]){
                completionBlock(YES,result[@"Stations"],error);
            }else {
                completionBlock(NO,result[@"Stations"],error);
            }
        }else
            completionBlock(NO,result,error);
    }];
}

-(void)fetchOCPPStationsWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    UserSetting *userSetting;
    NSManagedObjectContext *managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserSetting" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        userSetting=results[0];
    }
    
    NSMutableDictionary *body = [NSMutableDictionary new];
    [body setValue:kCutomerId forKey:@"customerId"];
    [body setValue:[NSString stringWithFormat:@"%@",self.latitude] forKey:@"latitude"];
    [body setValue:[NSString stringWithFormat:@"%@",self.longitude] forKey:@"longitude"];
    [body setValue:@"all" forKey:@"flag"]; // for all set it all,nearBy
    if (userSetting.searchNearbyDistance == nil) {
        [body setValue:@"10" forKey:@"distance"];
    }else{
        [body setValue:userSetting.searchNearbyDistance forKey:@"distance"];
    }
    //[body setValue:userSetting.searchNearbyDistance forKey:@"distance"];
    NSLog(@"get charger parameter data = %@",body);
    
    [EVOCPPWebService fetchDataFromService:@"getChargerDtlMobileApp" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        NSLog(@"get Charger responce data = %@",result);
        if(success){
            if([result[@"result"]isEqualToString:@"success"]){
                completionBlock(YES,result[@"Charger"],error);
            }else {
               completionBlock(YES,result[@"Charger"],error);
            }
        }else
            completionBlock(NO,result,error);
    }];
}

-(void)fetchStationsUsingLatitudeAndLongitudeWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    NSLog(@"latitude : %@",self.latitude);
    NSLog(@"longitude : %@",self.longitude);
    NSLog(@"powerlevel : %@",self.powerLevel);
    NSLog(@"usageType : %@",self.usageType);
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.latitude forKey:@"lattitude"];
    [body addValue:self.longitude forKey:@"longitude"];
    [body addValue:self.powerLevel forKey:@"power_level"];
    [body addValue:self.usageType forKey:@"usage_type"];
    //old view_station_version2.php
    [EVWebService fetchDataFromService:@"view_station_version2_new.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            NSLog(@"view_station_version2_new.php result ------> %@",result);
            if([result[@"result"]isEqualToString:@"success"]){
                completionBlock(YES,result[@"Stations"],error);
            }else {
                completionBlock(NO,result[@"Stations"],error);
            }
        }else
            completionBlock(NO,result,error);
    }];
}

-(void)fetchOCPPStationsUsingLatitudeAndLongitudeWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    UserSetting *userSetting;
    NSManagedObjectContext *managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserSetting" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        userSetting=results[0];
    }
    
    NSMutableDictionary *body = [NSMutableDictionary new];
    [body setValue:kCutomerId forKey:@"customerId"];
    [body setValue:[NSString stringWithFormat:@"%@",self.latitude] forKey:@"latitude"];
    [body setValue:[NSString stringWithFormat:@"%@",self.longitude] forKey:@"longitude"];
    if (userSetting.searchNearbyDistance == nil) {
        [body setValue:@"10" forKey:@"distance"];
    }else{
        [body setValue:userSetting.searchNearbyDistance forKey:@"distance"];
    }
    [body setValue:@"nearBy" forKey:@"flag"]; // for all set it all,nearBy
    NSLog(@"search near by distance = %@",userSetting.searchNearbyDistance);
  //  [body setValue:userSetting.searchNearbyDistance forKey:@"distance"];
    //[body setValue:@"5" forKey:@"distance"];
    NSLog(@"get charger parameter data = %@",body);
    [EVOCPPWebService fetchDataFromService:@"getChargerDtlMobileApp" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        NSLog(@"get charger response : %@",result);
        if(success){
            if([result[@"status"]isEqualToString:@"true"]){
                completionBlock(YES,result[@"Charger"],error);
            }else {
                completionBlock(NO,result[@"Charger"],error);
            }
        }else
            completionBlock(NO,result,error);
    }];
}


-(void)fetchConnectorUsingChargerIdWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    
    NSDictionary *body = [[NSDictionary alloc] initWithObjectsAndKeys:self.chargerId, @"chargerId",nil];
    NSLog(@"get connector parameter data = %@",body);
    [EVOCPPWebService fetchDataFromService:@"getConnectorByEvseIdMobileApp" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            if([result[@"status"]isEqualToString:@"true"]){
                NSLog(@"get connector responce data = %@",result);
                completionBlock(YES,result[@"Connector"],error);
            }else {
                completionBlock(NO,result[@"Connector"],error);
            }
        }else
            completionBlock(NO,result[@"Connector"],error);
    }];
}

-(void)fetchVehiclesWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock{
    
    [EVWebService fetchDataFromService:@"view_vehicles_new.php" withParameters:nil withCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            if([result[@"Result"]isEqualToString:@"success"]){
                completionBlock(YES,result[@"Vehicles"],error);
            }else {
                completionBlock(NO,nil,error);
            }
        }else
            completionBlock(NO,nil,error);
    }];
}


-(NSData *)getPropertiesAsData{
    NSLog(@"userId : %@",self.userId);
    NSLog(@"title : %@",self.title);
    NSLog(@"addressline1 : %@",self.adderssline1);
    NSLog(@"town : %@",self.town);
    NSLog(@"description : %@",self.descriptions);
    NSLog(@"stateOrProvince : %@",self.stateOrProvince);
    NSLog(@"postCode : %@",self.postCode);
    NSLog(@"Operational_Status : %@",self.status);
    NSLog(@"usageType : %@",self.usageType);
    NSLog(@"powerLevel : %@",self.powerLevel);
    NSLog(@"latitude : %@",self.latitude);
    NSLog(@"longitude : %@",self.longitude);
    NSLog(@"contactTelephone1 : %@",self.contactTelephone1);
    NSLog(@"connectorType : %@",self.connectorType);
    NSLog(@"operatorInfo : %@",self.operatorInfo);
    NSLog(@"imageName : %@",self.imageName);
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.userId forKey:@"userId"];
    [body addValue:self.title  forKey:@"title"];
    (self.adderssline1.length > 0)? [body addValue:self.adderssline1  forKey:@"addressline1"]:[body addValue:@""  forKey:@"addressline1"];
    (self.town.length > 0)?[body addValue:self.town  forKey:@"town"]:[body addValue:@"" forKey:@"town"];
    (![self.descriptions isKindOfClass:[NSNull class]])?[body addValue:self.descriptions forKey:@"description"]:[body addValue:@"" forKey:@"description"];
    
    (![self.stateOrProvince isKindOfClass:[NSNull class]])?[body addValue:self.stateOrProvince forKey:@"stateOrProvince"]:[body addValue:@"" forKey:@"stateOrProvince"];
    
    (![self.postCode isKindOfClass:[NSNull class]])?[body addValue:self.postCode forKey:@"postCode"]:[body addValue:@"" forKey:@"postCode"];
    
    [body addValue:@"" forKey:@"distance"];
    
    (![self.status isKindOfClass:[NSNull class]])? [body addValue:self.status forKey:@"Operational_Status"]:[body addValue:@"" forKey:@"Operational_Status"];
    
    (![self.usageType isKindOfClass:[NSNull class]])?[body addValue:self.usageType forKey:@"usageType"]:[body addValue:@"" forKey:@"usageType"];
    
    (![self.powerLevel isKindOfClass:[NSNull class]])?[body addValue:self.powerLevel forKey:@"powerLevel"]:[body addValue:@"" forKey:@"powerLevel"];
    
    (![self.latitude isKindOfClass:[NSNull class]])? [body addValue:self.latitude forKey:@"latitude"]:[body addValue:@"" forKey:@"latitude"];
    
    (![self.longitude isKindOfClass:[NSNull class]])?[body addValue:self.longitude forKey:@"longitude"]:[body addValue:@"" forKey:@"longitude"];
    
    (![self.contactTelephone1 isKindOfClass:[NSNull class]])?[body addValue:self.contactTelephone1 forKey:@"contactTelephone1"]:[body addValue:@"" forKey:@"contactTelephone1"];
 
    (![self.connectorType isKindOfClass:[NSNull class]])?[body addValue:self.connectorType forKey:@"connectorType"]:[body addValue:@"" forKey:@"connectorType"];

    (![self.operatorInfo isKindOfClass:[NSNull class]])?[body addValue:self.operatorInfo forKey:@"Operator"]:[body addValue:@"" forKey:@"Operator"];
    
    [body addValue:@"" forKey:@"contactTelephone2"];
    if (self.imageName.length > 0){
        self.imageName = [self makeFileName];
        [body addValue:UIImageJPEGRepresentation(_image, 0.2f) forKey:@"image" withFileName:_imageName];
    }
    return body;
}

-(NSString *)makeFileName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMddHHmmssSSS"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    int randomValue = arc4random() % 1000;
    NSString *fileName = [NSString stringWithFormat:@"%@%d.png",dateString,randomValue];
    return fileName;
}


@end
