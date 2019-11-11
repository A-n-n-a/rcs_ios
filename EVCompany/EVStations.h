//
//  EVStations.h
//  EVCompany
//
//  Created by Srishti on 11/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVStations : NSObject
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *adderssline1;
@property(nonatomic,retain) NSString *descriptions;
@property(nonatomic,retain) NSString *town;
@property(nonatomic,retain) NSString *stateOrProvince;
@property(nonatomic,retain) NSString *postCode;
@property(nonatomic,strong) NSString *distance;
@property(nonatomic,retain) NSString *status;
@property(nonatomic,retain) NSString *hoursOfOperation;
@property(nonatomic,retain) UIImage *image;
@property(nonatomic,retain) NSString *imageName;
@property(nonatomic,retain) NSString *usageType;
@property(nonatomic,retain) NSString *powerLevel;
@property(nonatomic,retain) NSString *latitude;
@property(nonatomic,retain) NSString *longitude;
@property(nonatomic,retain) NSString *contactTelephone1;
@property(nonatomic,retain) NSString *contactTelephone2;
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) NSString *favId;
@property(nonatomic,retain) NSString *connectorType;
@property(nonatomic,retain) NSString *operatorInfo;
@property(nonatomic,retain) NSString *keyType;
@property(nonatomic,retain) NSString *keyValue;
@property(assign) double distanceInMiles;


@property(nonatomic,retain) NSString *address;
@property(nonatomic,retain) NSString *chargerId;
@property(nonatomic,retain) NSString *ocppConnectorType;
@property(nonatomic,retain) NSString *descrp;
@property(nonatomic,retain) NSString *isApproved;
@property(nonatomic,retain) NSString *stnlatitude;
@property(nonatomic,retain) NSString *stnlongitude;
@property(nonatomic,retain) NSString *ocppChargePointStatus;
@property(nonatomic,retain) NSString *ocppPowerLevel;
@property(nonatomic,retain) NSString *siteName;
@property(nonatomic,retain) NSString *stationdId;
@property(nonatomic,retain) NSString *statusTimestamp;
@property(nonatomic,retain) NSString *ocppUserId;

@property(nonatomic,retain) NSString *isRCS;



-(id)initWithDataFromDictionary:(NSDictionary*)dataDictionary;
-(id)initWithDataFromServerWithDictionary:(NSDictionary*)dataDictionary;
-(id)initWithDataFromOCPPServerWithDictionary:(NSDictionary*)dataDictionary;

-(void)makeFavouritewithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock;
-(void)listFavouriteStationsWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock;
-(void)deleteFavouriteWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock;
-(void)addStationsWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock;
-(void)fetchStationsWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock;
-(void)fetchStationsUsingLatitudeAndLongitudeWithCompletionBlock:(void(^)(BOOL,id,NSError *))
completionBlock;
-(void)fetchVehiclesWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock;


-(void)fetchOCPPStationsUsingLatitudeAndLongitudeWithCompletionBlock:(void(^)(BOOL,id,NSError *))
completionBlock;
-(void)fetchOCPPStationsWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock;
-(void)fetchConnectorUsingChargerIdWithCompletionBlock:(void(^)(BOOL,id,NSError *))completionBlock;


@end
