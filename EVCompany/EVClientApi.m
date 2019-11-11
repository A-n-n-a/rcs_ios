//
//  INClientApi.m
//  Inspection
//
//  Created by mac on 8/30/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "EVClientApi.h"
#import "AFJSONRequestOperation.h"


@implementation EVClientApi
+(EVClientApi *)sharedClient {
    static EVClientApi *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.openchargemap.io/v2/"]];
    });
    return _sharedClient;
}

-(id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Content-Type" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
    return self;
}


- (void)fetchStationWithParameters : (NSDictionary*)parameters Success : (void(^)(id ))succes Failure : (void(^)(NSError *))failure {
    [self getPath:@"poi/?" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(jsonObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
        }
    }];
}
- (void)fetchNearestStationWithParameters : (NSDictionary*)parameters Success : (void(^)(id ))succes Failure : (void(^)(NSError *))failure {
    [self getPath:@"v1/nearest.json?" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSError *parseError = nil;
        //       id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
        if(succes){
            succes(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
        }
    }];
}


@end
