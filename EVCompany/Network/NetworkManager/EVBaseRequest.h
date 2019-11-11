//
//  EVBaseRequest.h
//  EVCompany
//
//  Created by Anna on 11/13/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVBaseRequest: NSObject

@property (nonatomic, strong) NSString* baseUrl;
@property (nonatomic, strong) NSDictionary* requestHeaders;


@end
