//
//  EVDirectionService.m
//  EVCompany
//
//  Created by GridScape on 12/3/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#import "EVDirectionService.h"
@interface EVDirectionService()<NSURLConnectionDataDelegate>
@end
@implementation EVDirectionService{
    NSMutableData *_urlData;
    NSString *_mainURl;
    void (^finishLoading)(BOOL ,id , NSError *);
}

-(id)init{
    self = [super init];
    if (self) {
        _mainURl = @"https://maps.googleapis.com/maps/api/distancematrix/json";
    }
    return self;
}

+(void)fetchDataFromServiceWithSource:(NSString *)source withDestination:(NSString *)destination withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion{
    EVDirectionService *conectionRequest = [self new];
    [conectionRequest httpRequestForServiceWithSource:(NSString *)source withDestination:(NSString *)destination inCompletionBlock:^(BOOL success, id result, NSError *error) {
        completion(success,result,error);
    }];
}

-(void)httpRequestForServiceWithSource:(NSString *)source withDestination:(NSString *)destination inCompletionBlock:(void(^)(BOOL , id ,NSError *)) completion
{
    finishLoading = completion;
    NSString *newsource1 = [source stringByReplacingOccurrencesOfString:@" " withString:@","];
    NSString *newsource = [newsource1 stringByReplacingOccurrencesOfString:@",," withString:@","];
    NSString *newdestination1 = [destination stringByReplacingOccurrencesOfString:@" " withString:@","];
    NSString *newdestination = [newdestination1 stringByReplacingOccurrencesOfString:@",," withString:@","];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?origins=%@&destinations=%@&sensor=false",_mainURl,newsource,newdestination]];
 //   NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_mainURl,service]];
    NSLog(@"url = %@",[NSString stringWithFormat:@"%@?origins=%@&destinations=%@&sensor=false",_mainURl,newsource,newdestination]);
 //   NSURLRequest *request = [self prepareRequestWithURL:url andParameters:nil];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
  /*  [request setHTTPMethod:@"GET"];
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@",charset, @"0xKhTmLbOuNdArY"];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody:nil]; */
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

-(NSURLRequest *)prepareRequestWithURL:(NSURL *)url andParameters:(NSData *) parameters
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
 //   if (parameters) {
        [request setHTTPMethod:@"POST"];
        NSString *charset =(NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@",charset, @"0xKhTmLbOuNdArY"];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        [request setHTTPBody:parameters];
 //   }
    
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
    NSLog(@"jsonnnnnnn----->%@",json);
    finishLoading(json?YES:NO,json,error);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    finishLoading(NO,nil,error);
}


@end
