//
//  EVFavoritesViewController.m
//  EVCompany
//
//  Created by Srishti on 28/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVFavoritesViewController.h"
#import "EVStations.h"
#import "EVUser.h"
#import "EVSlidingViewController.h"
#import "EVDetailsViewController.h"
#import "EVModal.h"

@interface EVFavoritesViewController (){
    NSMutableArray *arrayStations;
    EVModal *modal;
}

@end

@implementation EVFavoritesViewController

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
    NSLog(@"--------------EVFavoritesViewController--------------");
    [super viewDidLoad];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

    self.navigationItem.title = kNAV_TITLE;
    arrayStations = [[NSMutableArray alloc]init];
    [self fetchFavorites];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fetchFavorites{
    [modal show:@"Loading..."];

    EVStations *station = [[EVStations alloc]init];
    station.userId = [[EVUser currentUser]userId];
    [station listFavouriteStationsWithCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            [modal hide];
            for(NSDictionary *dict in result)
            {
                [arrayStations addObject:[[EVStations alloc] initWithDataFromServerWithDictionary:dict]];
            }
            [self.tableView reloadData];
        }else {
            [modal show:@"No favorites found" for:1.5];
        }
    }];
}
-(void)deleteFavourite:(NSUInteger)index{
    EVStations *station =[[EVStations alloc]init];
    station.userId = [[EVUser currentUser] userId];
    EVStations *selectedStation = arrayStations[index];
    station.favId = selectedStation.favId;
    [station deleteFavouriteWithCompletionBlock:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return arrayStations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    EVStations *station = arrayStations[indexPath.row];
    cell.textLabel.text = station.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self deleteFavourite:indexPath.row];
        [arrayStations removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
#pragma mark tableview delegates
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self gotoStationDetailView:indexPath.row];
}
-(void)gotoStationDetailView:(NSUInteger)index{
    EVDetailsViewController *evDetailViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"evDetails"];
    [evDetailViewcontroller setStation:arrayStations[index]];
    [evDetailViewcontroller setPreviousView:@"Favourite"];
    [self.navigationController pushViewController:evDetailViewcontroller animated:YES ];
}

@end
