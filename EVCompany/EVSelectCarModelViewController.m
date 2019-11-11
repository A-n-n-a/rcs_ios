//
//  EVSelectCarModelViewController.m
//  Sample
//
//  Created by Bala on 01/04/14.
//  Copyright (c) 2014 bala. All rights reserved.
//

#import "EVSelectCarModelViewController.h"

@interface EVSelectCarModelViewController ()<didFinishSelectingCar>
{
    NSMutableArray *arrayCars;
    NSMutableArray *arrayObjects ;
    NSInteger lastInsertedIndex;
    NSArray *arrayCopy;
    
}

@end

@implementation EVSelectCarModelViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"--------------EVSelectCarModelViewController--------------");
    [super viewDidLoad];
    arrayCars = [[NSMutableArray alloc]initWithObjects:@"Audi",@"BMW",@"Chevrolet",@"Coda",@"Fiat",@"Fisker",@"Ford",@"Honda",@"Mini",@"Mitsubishi",@"Nissan",@"Smart",@"Tesla",@"Think",@"Toyota", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayCars.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == Nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = (indexPath.row == 0 || [arrayObjects containsObject:arrayCars[indexPath.row]])? UITableViewCellAccessoryNone :UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = arrayCars[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || [arrayObjects containsObject:arrayCars[indexPath.row]])
    {
        NSString *selectedCar =[arrayCars[indexPath.row] stringByReplacingOccurrencesOfString:@" " withString:@""];
        [_delegate didFinishSelecting:selectedCar];
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        if (arrayObjects.count == 0)
        {
            [self getCarmodelForIndexpath:indexPath.row];
        }else
        {
                [arrayObjects enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop)
                 {
                     if ([arrayCars containsObject:obj])
                     {
                         [arrayCars removeObject:obj];
                     }
                 }];
            
              if (lastInsertedIndex > indexPath.row ) {
                  
                [self checkTheObject:indexPath.row + arrayCopy.count];
                
            }else
            {
                [self getCarmodelForIndexpath:indexPath.row-arrayCopy.count];

            }
        }
    }
}
-(void)checkTheObject : (NSInteger)indexpath
{
      indexpath =  (indexpath == 15)?indexpath-1:indexpath;
    if ([arrayObjects containsObject:arrayCars[indexpath]])
    {
        [arrayObjects removeObject:arrayCars[indexpath]];
        [self checkTheObject:indexpath +1];
    }else
    {
        [arrayObjects enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop)
        {
            if ([arrayCars containsObject:obj])
            {
                [arrayCars removeObject:obj];
            }
        }];
        [self getCarmodelForIndexpath:indexpath-arrayCopy.count ];
    }
}
-(void)getCarmodelForIndexpath :(NSInteger)index
{
    
    arrayObjects = [NSMutableArray new];
    NSString *pad = [[NSString string] stringByPaddingToLength:4 withString:@" " startingAtIndex:0];
    switch (index) {
        case 1:
        {
            [arrayObjects addObject:[pad stringByAppendingString:@"Active E"]];
        }
            break;
        case 2:
        {
            [arrayObjects addObject:[pad stringByAppendingString:@"Spark EV"]];
            [arrayObjects addObject:[pad stringByAppendingString:@"Volt"]];
        }
            break;
        case 3:
            [arrayObjects addObject:[pad stringByAppendingString:@"Coda Sedan"]];
            break;
        case 4:
            [arrayObjects addObject:[pad stringByAppendingString:@"500 e"]];
            break;
        case 5:
            [arrayObjects addObject:[pad stringByAppendingString:@"Karma"]];
            break;
        case 6:
            [arrayObjects addObject:[pad stringByAppendingString:@"C-MAX Energi"]];
            break;
        case 7:
            [arrayObjects addObject:[pad stringByAppendingString:@"Accord Plugin"]];
            break;
        case 8:
            [arrayObjects addObject:[pad stringByAppendingString:@"Mini-E Cooper"]];
            break;
        case 9:
            {
            [arrayObjects addObject:[pad stringByAppendingString:@"Outlander PHEV"]];
            [arrayObjects addObject:[pad stringByAppendingString:@"i-Miev"]];
           }
            break;
        case 10:
            [arrayObjects addObject:[pad stringByAppendingString:@"Leaf"]];
            break;
        case 11:
            [arrayObjects addObject:[pad stringByAppendingString:@"Fortwo Electric"]];
            break;
        case 12:
        {
            [arrayObjects addObject:[pad stringByAppendingString:@"Model S"]];
            [arrayObjects addObject:[pad stringByAppendingString:@"Roadster"]];
        }
            break;
        case 13:
            [arrayObjects addObject:[pad stringByAppendingString:@"City"]];
            break;
        case 14:
            [arrayObjects addObject:[pad stringByAppendingString:@"Prius Plug-in Hybrid"]];
            break;
        default:
            break;
    }
    [self reloadDataWith:arrayObjects atindexpath:index];
}
-(void)reloadDataWith : (NSMutableArray *)arraySelected atindexpath : (NSInteger)index
{
       [arraySelected enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop)
    {
        if (arrayCopy.count == 0) {
            [arrayCars insertObject:obj atIndex:index + idx + 1];
            lastInsertedIndex =index + idx + 1;

        }else
        {
            [arrayCars insertObject:obj atIndex:(arrayCopy.count == 2)?index + idx +arrayCopy.count -1:index +idx +1];
            lastInsertedIndex =index + idx +arrayCopy.count +1;

        }
        
    }];
    arrayCopy = arraySelected.mutableCopy;
    [self.tableView reloadData];
}
@end
