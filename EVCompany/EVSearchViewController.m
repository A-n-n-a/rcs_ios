//
//  EVSearchViewController.m
//  EVCompany
//
//  Created by Srishti on 21/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVSearchViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "EVSearchCell.h"
#import "EVMapTableViewCell.h"
#import "EVStations.h"


@interface EVSearchViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>{
    CLGeocoder * _geocoder;
    NSMutableArray * _geocodingResults;
    NSTimer *_searchTimer;
    UIActivityIndicatorView *activityIndicator;
    UILabel *labelLoading;
    UIView *headerView;
    NSArray *arrayPlacemark;
    BOOL isSearching;
    IBOutlet UISearchBar *searchbar;
    
}
@property (nonatomic, strong) UISearchDisplayController *searchController;

@end

@implementation EVSearchViewController

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
    NSLog(@"--------------EVSearchViewController--------------");
    [super viewDidLoad];
    isSearching = NO;
    arrayPlacemark = [[NSArray alloc]init];
    _geocodingResults = [NSMutableArray array];
    _geocoder = [[CLGeocoder alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UISearchDisplayController Delegate Methods
NSString * const kSearchTextKey = @"Search Text";

//- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
//    
//    // Use a timer to only start geocoding when the user stops typing
//    if ([_searchTimer isValid])
//        [_searchTimer invalidate];
//    [activityIndicator startAnimating];
//    labelLoading.hidden = NO;
//    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"name grey.png"]];
//
//    const NSTimeInterval kSearchDelay = .25;
//    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:searchString
//                                                          forKey:kSearchTextKey];
//    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:kSearchDelay
//                                                    target:self
//                                                  selector:@selector(geocodeFromTimer:)
//                                                  userInfo:userInfo
//                                                   repeats:NO];
//    
//    return NO;
//}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissView:(CLLocation *)location :(NSString *)stationName :(BOOL)isStation{
    [self.delegate zoomtoLocation:location :stationName :isStation];
    [self dismissViewControllerAnimated:YES completion:nil];
  
}
-(IBAction)backAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
//{
//    [self performSelector:@selector(removeOverlay) withObject:nil afterDelay:.01f];
//}
//
//- (void)removeOverlay
//{
//    [[self.view.subviews lastObject] removeFromSuperview];
//}

//-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
//{
//    //[self filterListForSearchText:text];
//        self.searchDisplayController.searchResultsTableView.hidden = YES;
//        [self.tableView reloadData];
//}
//
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_geocodingResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";

    if(indexPath.row == arrayPlacemark.count-1 || indexPath.row < arrayPlacemark.count){
//        EVMapTableViewCell *cell = (EVMapTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        EVMapTableViewCell *cell;
        
        if (cell == nil) {
            cell = [[EVMapTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
            cell.labelAddress.text = @"Tap to Zoom Map to this Address.";
            CLPlacemark * placemark = [_geocodingResults objectAtIndex:indexPath.row];
            NSString * formattedAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            cell.labelTitle.text = formattedAddress;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else {
        EVSearchCell *cell;
//    EVSearchCell *cell = (EVSearchCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[EVSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
        EVStations *station = _geocodingResults[indexPath.row];
        cell.labelTitle.text = station.title;
        NSString *addressString = [NSString stringWithFormat:@"%@,%@,%@",station.adderssline1,station.town,station.stateOrProvince];
        cell.labelAddress.text = addressString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
    }
   
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    
    
    //Create and add the Activity Indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.alpha = 1.0;
    activityIndicator.frame = CGRectMake(5, 2, 20, 20) ;
    activityIndicator.hidesWhenStopped = YES;
    [headerView addSubview:activityIndicator];
    
    labelLoading = [[UILabel alloc]initWithFrame:CGRectMake(28, 2, 150, 20)];
    labelLoading.font = [UIFont systemFontOfSize:14];
    labelLoading.textColor = [UIColor whiteColor];
    labelLoading.text = @"Loading";
    //labelLoading.hidden = YES;
    
    [headerView addSubview:labelLoading];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
#pragma tableview delegates
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == arrayPlacemark.count-1 || indexPath.row < arrayPlacemark.count){
        CLPlacemark * placemark = [_geocodingResults objectAtIndex:indexPath.row];
        NSString * formattedAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        [self dismissView:placemark.location :formattedAddress:NO];
        
    }else {
        EVStations *station = _geocodingResults[indexPath.row];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:[station.latitude doubleValue] longitude:[station.longitude doubleValue]];
        [self dismissView:location :station.title:YES];
    }
}
#pragma mark Geocode Methods

- (void) geocodeFromTimer:(NSString *)searchString{
    
   // NSString * searchString = [timer.userInfo objectForKey:kSearchTextKey];
    
    // Cancel any active geocoding. Note: Cancelling calls the completion handler on the geocoder
    if (_geocoder.isGeocoding)
        [_geocoder cancelGeocode];
    
    [_geocoder geocodeAddressString:searchString
                  completionHandler:^(NSArray *placemark, NSError *error) {
                      if (!error)
                      [self processForwardGeocodingResults:placemark searchString:searchString];
                  }
     ];
}
- (void) processForwardGeocodingResults:(NSArray *)placemarks searchString:(NSString*)searchString{
    [_geocodingResults removeAllObjects];
    [_geocodingResults addObjectsFromArray:placemarks];
    arrayPlacemark = placemarks;
    [self filterStations:searchString];
    
    
    
}
-(void)filterStations :(NSString *)searchString{
    
    [_arrayStations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        EVStations *evstation = _arrayStations[idx];
        NSString *title = evstation.title;
        title=title.lowercaseString;
        if([title hasPrefix:searchString])
        {
            [_geocodingResults addObject:evstation];
        }
        if(idx == _arrayStations.count-1){
            labelLoading.hidden = YES;
            [activityIndicator stopAnimating];
            headerView.backgroundColor = [UIColor whiteColor];
            [self.tableView reloadData];
        }
    }];
    
    
}

//- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
//{
//    [self performSelector:@selector(removeOverlay) withObject:nil afterDelay:.01f];
//}
//
//- (void)removeOverlay
//{
//    [[self.view.subviews lastObject] removeFromSuperview];
//}


-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    [activityIndicator startAnimating];
    labelLoading.hidden = NO;
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"name grey.png"]];
    if(text.length == 0)
    {
        isSearching=NO;
        [self.tableView reloadData];
    }
    else{
        [self geocodeFromTimer:text];
        self.searchDisplayController.searchResultsTableView.hidden = YES;
    }
    
}
//-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
////    [searchBar resignFirstResponder];
////    [searchBar setText:@""];
////    [self resetFilter];
////    isSearching = NO;
////    [self.tableView reloadData];
//}
//- (void)resetFilter
//{
//    // if(searchBar.text.length) [self removeOverlay];
//    [filteredList removeAllObjects];
//    [messageFilteredList removeAllObjects];
//    // searchBar.text=@"";
//    self.searchDisplayController.searchBar.showsCancelButton=YES;
//    
//}


@end
