//
//  EVRequestManager.h
//  EVCompany
//
//  Created by Anna on 11/13/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "AFNetworking.h"
#import "EVBaseRequest.h"
#import "EVRequestHandler.h"

@interface EVRequestManager: NSObject


+ (id)sharedInstance;
+ (void)runGetRequestWithModel:(EVBaseRequest *)model completion:(EVRequestHandler*)handler;
+ (void)finalizeResponse:(id)response sessionTask:(NSURLSessionDataTask *)task andError:(NSError *)error withCompletion:(EVRequestHandler*)handler andModel:(EVBaseRequest *)model;


@end
