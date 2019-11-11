//
//  EVSearchViewController.h
//  EVCompany
//
//  Created by Srishti on 21/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@protocol zoomtoSelectedLocation <NSObject>
-(void)zoomtoLocation:(CLLocation*)selectedLocation :(NSString *)stationName :(BOOL)isStation;
@end

@interface EVSearchViewController : UITableViewController
@property(nonatomic,strong)id <zoomtoSelectedLocation> delegate;
@property (nonatomic,strong)NSArray *arrayStations;
@end
