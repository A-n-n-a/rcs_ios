//
//  EVRequestManager.m
//  EVCompany
//
//  Created by Anna on 11/13/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "EVRequestManager.h"
#import "EVBaseRequest.h"
#import "EVRequestHandler.h"

@interface EVRequestManager () {
    
}


@end

@implementation EVRequestManager

+(EVRequestManager*)sharedInstance{
    static EVRequestManager *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

+ (void)runGetRequestWithModel:(EVBaseRequest *)model completion:(EVRequestHandler*)handler
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:10];
    
    if (model.requestHeaders)
    {
        for (NSString *key in model.requestHeaders.allKeys)
        {
            [manager.requestSerializer setValue:model.requestHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    [manager GET:model.baseUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self finalizeResponse:responseObject sessionTask:task andError:nil withCompletion:handler andModel:model];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self finalizeResponse:nil sessionTask:task andError:error withCompletion:handler andModel:model];
        
    }];
}

+ (void)finalizeResponse:(id)response sessionTask:(NSURLSessionDataTask *)task andError:(NSError *)error withCompletion:(EVRequestHandler*)handler andModel:(EVBaseRequest *)model
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    
    if (error)
    {
        handler(nil, httpResponse.statusCode, error);
    }
    else if (response)
    {
        handler(response, httpResponse.statusCode, nil);
    }
}

@end


