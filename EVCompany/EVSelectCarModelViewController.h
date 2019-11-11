//
//  EVSelectCarModelViewController.h
//  Sample
//
//  Created by Bala on 01/04/14.
//  Copyright (c) 2014 bala. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol didFinishSelectingCar <NSObject>

-(void)didFinishSelecting :(NSString *)carModel;

@end
@interface EVSelectCarModelViewController : UITableViewController
@property(nonatomic,strong)id <didFinishSelectingCar>delegate;
@end
