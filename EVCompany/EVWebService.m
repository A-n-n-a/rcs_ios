//
//  EVWebService.m
//  EVCompany
//
//  Created by Srishti on 11/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVWebService.h"
@interface EVWebService()<NSURLConnectionDataDelegate>
@end
@implementation EVWebService{
    NSMutableData *_urlData;
    NSString *_mainURl;
    void (^finishLoading)(BOOL ,id , NSError *);
}

-(id)init{
    self = [super init];
    if (self) {
        
        _mainURl = @"https://revitalizechargingsolutions.com/rcsappdatabase/";
    }
    return self;
}

+(void)fetchDataFromService:(NSString *)serviceName withParameters:(id)parameters withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion{
    
    EVWebService *conectionRequest = [self new];
    [conectionRequest httpRequestForService:serviceName withParameters:parameters inCompletionBlock:^(BOOL success, id result, NSError *error) {
        completion(success,result,error);
    }];
}

-(void)httpRequestForService:(NSString *)service withParameters:(NSData *)parameters inCompletionBlock:(void(^)(BOOL , id ,NSError *)) completion
{
    finishLoading = completion;
    NSLog(@"RCS Request Url : %@",[NSString stringWithFormat:@"%@%@",_mainURl,service]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_mainURl,service]];
    NSURLRequest *request = [self prepareRequestWithURL:url andParameters:parameters];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

-(NSURLRequest *)prepareRequestWithURL:(NSURL *)url andParameters:(NSData *) parameters
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    if (parameters) {
        [request setHTTPMethod:@"POST"];
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@",charset, @"0xKhTmLbOuNdArY"];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        [request setHTTPBody:parameters];
    }
    
    return request;
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
