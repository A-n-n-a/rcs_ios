//
//  EVDirectionClient.m
//  EVCompany
//
//  Created by GridScape on 12/3/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVDirectionClient.h"
#import "AFJSONRequestOperation.h"

@implementation EVDirectionClient

+(EVDirectionClient *)sharedClient {
    static EVDirectionClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?origin=%@&destination=%@",@"https://maps.googleapis.com/maps/api/directions/json",@"vadodara",@"anand"]]];
        NSLog(@"url = %@",[NSString stringWithFormat:@"%@?origin=%@&destination=%@",@"https://maps.googleapis.com/maps/api/directions/json",@"vadodara",@"anand"]);
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

-(void)fetchDataFromServiceWithSource:(NSString *)source withDestination:(NSString *)destination Success : (void(^)(id))succes Failure : (void(^)(NSError *))failure {
  //  NSString *urlpath = [NSString stringWithFormat:@"?origin=%@&destination=%@",source,destination];
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

@end
