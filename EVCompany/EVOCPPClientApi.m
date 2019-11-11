//
//  EVOCPPClientApi.m
//  EVCompany
//
//  Created by GridScape on 9/24/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVOCPPClientApi.h"
#import "AFJSONRequestOperation.h"

@implementation EVOCPPClientApi

+(EVOCPPClientApi *)sharedOcppClient {
    static EVOCPPClientApi *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        //_sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://demo.grid-scape.com/"]];
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kURLDemo]];
    });
    return _sharedClient;
}

-(id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Content-Type" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
    return self;
}


- (void)addUserToOcppServerWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure{
    [self postPath:@"addMobileAppUser" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }
    }];
}

- (void)getChargerDetailsWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure{
    NSLog(@"Get Charger Details Parameter : %@",parameters);
    [self postPath:@"getChargerDtlMobileApp" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response object : %@",responseObject);
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }
    }];
}

- (void)getConnectorWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure{
    [self postPath:@"getConnectorByEvseIdMobileApp" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }
    }];
}

- (void)getReservationWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure{
    [self postPath:@"mobileAppreserveOffline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }
    }];
}

- (void)getReservationListWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure{
    [self postPath:@"mobileAppGetreserveOffline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }
    }];
}

- (void)getCancelReservationWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure{
    [self postPath:@"mobileAppCancelReservation" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }
    }];
}

- (void)RemoteChargingStartWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure{
    [self postPath:@"mobileAppStartTrans" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }
    }];
}

- (void)RemoteChargingStopWithParameters : (NSDictionary*)parameters Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure{
    [self postPath:@"mobileAppStopTrans" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }
    }];
}


@end