//
//  NSMutableData+PostDataAdditions.h
//  LoginDemo
//
//  Created by Siju karunakaran on 12/12/13.
//  Copyright (c) 2013 Srishti Innovative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (PostDataAdditions)

+(id)postData;
-(void)addValue:(id)value forKey:(NSString *)key;
-(void)addValue:(id)value forKey:(NSString *)key withFileName:(NSString*)fileName;

@end
