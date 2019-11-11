//
//  Filter.h
//  EVCompany
//
//  Created by Srishti on 01/04/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Filter : NSManagedObject

@property (nonatomic, retain) NSString * chargingLevel;
@property (nonatomic, retain) NSString * usageType;

@end
