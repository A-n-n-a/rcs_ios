//
//  NSMutableData+PostDataAdditions.m
//  LoginDemo
//
//  Created by Siju karunakaran on 12/12/13.
//  Copyright (c) 2013 Srishti Innovative. All rights reserved.
//

#import "NSMutableData+PostDataAdditions.h"
#define kPostDataBoundry @"0xKhTmLbOuNdArY"

@implementation NSMutableData (PostDataAdditions)

+(id)postData{
    
    NSMutableData *data = [NSMutableData data];
    
    [data appendPostBoundry];
    
    return data;
    
}
-(void) appendPostBoundry{
    
    [self appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", kPostDataBoundry] dataUsingEncoding:NSUTF8StringEncoding]];

}
-(void)addValue:(id)value forKey:(NSString *)key{
    
    [self appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key,value] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self appendPostBoundry];
}

-(void)addValue:(id)value forKey:(NSString *)key withFileName:(NSString*)fileName{
    
    [self appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",key, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self appendData:value];
    
    [self appendPostBoundry];

}

@end
