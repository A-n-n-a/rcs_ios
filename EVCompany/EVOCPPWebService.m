//
//  EVOCPPWebService.m
//  EVCompany
//
//  Created by GridScape on 10/5/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVOCPPWebService.h"

@interface EVOCPPWebService() <NSURLConnectionDataDelegate>

@end
@implementation EVOCPPWebService{
    NSMutableData *_urlData;
    NSString *_mainURl;
    void (^finishLoading)(BOOL ,id , NSError *);
}


-(id)init{
    self = [super init];
    if (self) {
       _mainURl = kURLDemo;
    }
    return self;
}

+(void)fetchDataFromService:(NSString *)serviceName withParameters:(id)parameters withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion{
    EVOCPPWebService *conectionRequest = [self new];
    [conectionRequest httpRequestForService:serviceName withParameters:parameters inCompletionBlock:^(BOOL success, id result, NSError *error) {
        completion(success,result,error);
    }];
}

-(void)httpRequestForService:(NSString *)service withParameters:(NSData *)parameters inCompletionBlock:(void(^)(BOOL , id ,NSError *)) completion
{
    finishLoading = completion;
    NSLog(@"request = %@",[NSString stringWithFormat:@"%@%@",_mainURl,service]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_mainURl,service]];
    NSURLRequest *request = [self prepareRequestWithURL:url andParameters:parameters];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

-(NSURLRequest *)prepareRequestWithURL:(NSURL *)url andParameters:(NSData *) parameters
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
    

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    return req;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _urlData = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_urlData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:_urlData options:kNilOptions error:&error];
    finishLoading(json?YES:NO,json,error);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    finishLoading(NO,nil,error);
}

@end

