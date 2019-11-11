//
//  EVStationListingViewController.m
//  EVCompany
//
//  Created by Srishti on 09/04/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVStationListingViewController.h"
#import "EVClientApi.h"
#import "EVAppDelegate.h"
#import "EVStations.h"
#import "EVMapTableViewCell.h"
#import "EVMapViewController.h"
#import "ECSlidingViewController.h"
#import "GeoCoder.h"
#import "Filter.h"
#import "EVAppDelegate.h"
#import "UserSetting.h"
#import <iAd/iAd.h>
#import "EVModal.h"

@interface EVStationListingViewController ()<ADBannerViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>{
    UIView *viewbanner;
    IBOutlet ADBannerView *bannerView;
    UIView *viewSearch;
    UISearchBar *searchBar;
    UILabel *labelSearch;
    
    NSManagedObjectContext *managedObjectContext;
    NSArray *array;
    NSMutableArray *arrayStations;
    NSMutableArray *arrayResultFetchFromServer;
    NSMutableArray *arrayResultFetchFromOCPPServer;
    NSDictionary *locationDict;
    NSMutableArray *arrayFiltred;
    UISegmentedControl *control;
    BOOL isALL;
    BOOL isFetch,isSearch;
    Filter *filter;
    EVAppDelegate *appdelegate;
    EVModal *modal;
}
@property(nonatomic,strong)IBOutlet UITableView *tableView;
@end

@implementation EVStationListingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    NSLog(@"--------------EVStationListingViewController--------------");
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

    self.navigationItem.title = kNAV_TITLE;
    appdelegate = (EVAppDelegate*)[[UIApplication sharedApplication] delegate];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    isALL = NO;
    isFetch = NO;
    isSearch = NO;
    [modal show:@"Retrieving stations near you!"];
    
    arrayFiltred = [[NSMutableArray alloc]init];
    arrayStations = [[NSMutableArray alloc]init];
    arrayResultFetchFromServer = [[NSMutableArray alloc]init];
    arrayResultFetchFromOCPPServer = [[NSMutableArray alloc] init];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    NSArray *itemArray = [NSArray arrayWithObjects: @"Nearby", @"All", nil];
    control = [[UISegmentedControl alloc] initWithItems:itemArray];
    [control setTintColor:[UIColor colorWithRed:41.0/255.0 green:175.0/255.0 blue:62.0/255.0 alpha:1.0]];
    [control setSelectedSegmentIndex:0];
    [control setFrame:CGRectMake(10.0, 10, self.view.frame.size.width-20, 30.0)];
    [control setEnabled:YES];
    [control addTarget:self action:@selector(segmentSwitch:) forControlEvents:UIControlEventValueChanged];
    
    [self fetchStateName];
    [self setRightButton];
    [self setBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    //[modal show:@"Retrieving stations near you!"];
}

-(void)setBarButton{
    UIButton *sliderBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [sliderBarButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [sliderBarButton setBackgroundImage:[UIImage imageNamed:@"lines.png"] forState:UIControlStateNormal];
    UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithCustomView:sliderBarButton];
    [self.navigationItem setLeftBarButtonItem:barButtonLeft];
}

-(void)setRightButton{
    UIButton *searchBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [searchBarButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [searchBarButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithCustomView:searchBarButton];
    [self.navigationItem setRightBarButtonItem:search];
}

-(IBAction)search:(id)sender{
    isSearch = YES;
    
    if(viewSearch == nil || viewSearch.frame.origin.y == -100){
        
        if(viewSearch == nil){
            viewSearch = [[UIView alloc]initWithFrame:CGRectMake(0, -100, self.view.frame.size.width, 70)];
            viewSearch.backgroundColor = [UIColor darkGrayColor];
            labelSearch = [[UILabel alloc]initWithFrame:CGRectMake(2, 5, self.view.frame.size.width, 30)];
            labelSearch.text = @"Search By Address, Zip code or Location Name";
            labelSearch.textColor = [UIColor whiteColor];
            labelSearch.font = [UIFont systemFontOfSize:12];
            searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 44)];
            searchBar.delegate = self;
            searchBar.showsCancelButton = YES;
            
            [viewSearch addSubview:labelSearch];
            [viewSearch addSubview:searchBar];
            [self.view addSubview:viewSearch];
        }

        searchBar.text = @"";
        [UIView animateWithDuration:0.5 animations:^{
            viewSearch.frame = CGRectMake(0, 0, self.view.frame.size.width, 70);
            [searchBar becomeFirstResponder];
        } completion:^(BOOL finished) {
            
        }];
    }
    else{
        [self searchBarCancelButtonClicked:searchBar];
    }
}

- (void)orientationChanged:(NSNotification *)notification{
    if(isSearch){
        viewSearch.frame = CGRectMake(0, 0, self.view.frame.size.width, 70);
        labelSearch.frame = CGRectMake(2, 5, self.view.frame.size.width, 30);
        searchBar.frame = CGRectMake(0, 30, self.view.frame.size.width, 44);
    }
    [control setFrame:CGRectMake(10.0, 10, self.view.frame.size.width-20, 30.0)];
    [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (IBAction)revealMenu:(id)sender{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)fetchDataFromCoreData{
    isFetch = YES;
    managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Filter" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        filter=results[0];
    }
    [self fetchStationsFromServer];
}

-(void)fetchStationsFromServer {
    __weak typeof(self) weakSelf = self;
    [arrayResultFetchFromServer removeAllObjects];
    EVStations *station = [[EVStations alloc]init];
    station.latitude = [NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.latitude];
    station.longitude = [NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.longitude];
    if(filter){
        NSArray *arrayLevel = [filter.chargingLevel componentsSeparatedByString:@","];
        station.powerLevel = arrayLevel.count >0?filter.chargingLevel:@"1,2,3";
        NSArray *arrayUsage = [filter.usageType componentsSeparatedByString:@","];
        station.usageType = arrayUsage.count >0?filter.usageType:@"0,1,2,3,4,5,6,7";
    }else{
        station.powerLevel = @"1,2,3";
        station.usageType = @"0,1,2,3,4,5,6,7";
    }
    [station fetchStationsUsingLatitudeAndLongitudeWithCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            NSArray *arrayResult = result;
            NSLog(@"Stations from RCS server count= %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromServer = [arrayResult mutableCopy];
            }
        }
        [weakSelf fetchOCPPStationsFromServer];
    }];
    
}

-(void)fetchOCPPStationsFromServer {
    __weak typeof(self) weakSelf = self;
    [arrayResultFetchFromOCPPServer removeAllObjects];
    EVStations *station = [[EVStations alloc]init];
    station.latitude = [NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.latitude];
    station.longitude = [NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.longitude];
    if(filter){
        NSArray *arrayLevel = [filter.chargingLevel componentsSeparatedByString:@","];
        station.powerLevel = arrayLevel.count >0?filter.chargingLevel:@"1,2,3";
        NSArray *arrayUsage = [filter.usageType componentsSeparatedByString:@","];
        station.usageType = arrayUsage.count >0?filter.usageType:@"0,1,2,3,4,5,6,7";
    }else{
        station.powerLevel = @"1,2,3";
        station.usageType = @"0,1,2,3,4,5,6,7";
    }[station fetchOCPPStationsUsingLatitudeAndLongitudeWithCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            NSArray *arrayResult = result;
            NSLog(@"Stations from OCPP server count= %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromOCPPServer = [arrayResult mutableCopy];
            }
        }
        [weakSelf fetchStationsNearest];
    }];
}

-(void)fetchALLStationsFromServer{
    isFetch = YES;
    __weak typeof(self) weakSelf = self;
    [arrayResultFetchFromServer removeAllObjects];
    EVStations *station = [[EVStations alloc]init];
    station.keyType = @"state";
    station.keyValue = locationDict[@"state"];
    if(filter){
        NSArray *arrayLevel = [filter.chargingLevel componentsSeparatedByString:@","];
        station.powerLevel = arrayLevel.count >0?filter.chargingLevel:@"1,2,3";
        NSArray *arrayUsage = [filter.usageType componentsSeparatedByString:@","];
        station.usageType = arrayUsage.count >0?filter.usageType:@"0,1,2,3,4,5,6,7";
    }else{
        station.powerLevel = @"1,2,3";
        station.usageType = @"0,1,2,3,4,5,6,7";
    }
    
    [modal show:@"Retrieving stations..."];
    [station fetchStationsWithCompletionBlock:^(BOOL success, id result, NSError *error) {
        [modal hide];
        if(success){
            NSArray *arrayResult = result;
            NSLog(@"RCS All data count= %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromServer = [arrayResult mutableCopy];
            }
        }
        [weakSelf fetchALLOCPPStationsFromServer];
    }];
}

-(void)fetchALLOCPPStationsFromServer{
    isFetch = YES;
    __weak typeof(self) weakSelf = self;
    [arrayResultFetchFromOCPPServer removeAllObjects];
    EVStations *station = [[EVStations alloc]init];
    
    station.latitude = [NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.latitude];
    station.longitude = [NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.longitude];
    
    station.keyType = @"state";
    station.keyValue = locationDict[@"state"];
    if(filter){
        NSArray *arrayLevel = [filter.chargingLevel componentsSeparatedByString:@","];
        station.powerLevel = arrayLevel.count >0?filter.chargingLevel:@"1,2,3";
        NSArray *arrayUsage = [filter.usageType componentsSeparatedByString:@","];
        station.usageType = arrayUsage.count >0?filter.usageType:@"0,1,2,3,4,5,6,7";
    }else{
        station.powerLevel = @"1,2,3";
        station.usageType = @"0,1,2,3,4,5,6,7";
    }
    [station fetchOCPPStationsWithCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            NSLog(@"final result 2= %@",result);
            NSArray *arrayResult = result;
            NSLog(@"OCPP All data count= %lu",(unsigned long)arrayResult.count);
            if(arrayResult.count > 0){
                arrayResultFetchFromOCPPServer = [arrayResult mutableCopy];
            }
        }
        [weakSelf fetchStationsWithState];
    }];
}

-(NSString *)setPowerLevel:(NSArray *)arrayPowerLevel{
    NSMutableArray *arrayLevel =[NSMutableArray new];
    [arrayPowerLevel enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([arrayPowerLevel[idx] isEqualToString:@"1"])
            [arrayLevel addObject:@"Level 1 EVSE"];
        else if([arrayPowerLevel[idx] isEqualToString:@"2"])
            [arrayLevel addObject:@"Level 2 EVSE"];
        else
            [arrayLevel addObject:@"DC Fast Charging"];
    }];
    return [arrayLevel componentsJoinedByString:@","];
}

-(void)fetchStationsWithState{
    NSLog(@"fetchStationsWithState");
    __weak typeof(self) weakSelf = self;
    NSDictionary *dict = [weakSelf setParameterwithCountryCode:locationDict[@"countryCode"] latitude:[NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.latitude] longitude:[NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.longitude]];
    
    [[EVClientApi sharedClient] fetchStationWithParameters:dict Success:^(id result) {
        NSArray *arrayFetchFromApi = result ;
        NSLog(@"API all data count= %lu",(unsigned long)arrayFetchFromApi.count);
        [self combineDataFromServerAndApiWithArray:arrayFetchFromApi];
    } Failure:^(NSError *error) {
        [modal show:@"No stations found, please adjust your filter." for:1.5];
    }];
}

-(void)fetchStationsNearest{
    [arrayStations removeAllObjects];
    NSDictionary *dict = [self setParameterwithCountryCode:nil latitude:[NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.latitude] longitude:[NSString stringWithFormat:@"%f",appdelegate.currentLocation.coordinate.longitude]];
    [[EVClientApi sharedClient] fetchStationWithParameters:dict Success:^(id result) {
   // [[EVClientApi sharedClient] fetchNearestStationWithParameters:dict Success:^(id result) {
        NSArray *arrayFetchFromApi = result ;
        NSLog(@"Stations from API count= %lu",(unsigned long)arrayFetchFromApi.count);
        [self combineDataFromServerAndApiWithArray:arrayFetchFromApi];
    } Failure:^(NSError *error) {
        [modal show:@"No stations found, please adjust your filter" for:1.5];
    }];
}

-(void)combineDataFromServerAndApiWithArray:(NSArray *)arrayFetchFromApi{
    [arrayStations removeAllObjects];
    NSArray *arrayResult = (arrayFetchFromApi.count > 0)? [arrayFetchFromApi arrayByAddingObjectsFromArray:[arrayResultFetchFromServer copy]]:arrayResultFetchFromServer ;
    arrayResult = (arrayResultFetchFromOCPPServer.count > 0)?
    [arrayResult arrayByAddingObjectsFromArray:[arrayResultFetchFromOCPPServer copy]] :
    arrayResult;
    NSLog(@"Array Result = %lu",(unsigned long)arrayResult.count);
    NSLog(@"arrayStations count = %lu",(unsigned long)[arrayStations count]);
    if(arrayResult.count == 0){
        [arrayStations removeAllObjects];
        [self.tableView reloadData];
        [modal show:@"No results found" for:1.5];
    }
    [arrayResult enumerateObjectsUsingBlock:^(NSDictionary *dataDic, NSUInteger idx, BOOL *stop) {
        if(arrayResultFetchFromServer.count != 0 && ((arrayFetchFromApi.count == 0 && !(idx > (arrayFetchFromApi.count+arrayResultFetchFromServer.count-1)))|| (idx > arrayFetchFromApi.count - 1 && !(idx > (arrayFetchFromApi.count+arrayResultFetchFromServer.count-1))))){
            NSLog(@"1");
            [arrayStations addObject:[[EVStations alloc] initWithDataFromServerWithDictionary:dataDic]];
        }else if(arrayFetchFromApi.count == 0 || idx > (arrayFetchFromApi.count+arrayResultFetchFromServer.count -1)){
            NSLog(@"2");
            [arrayStations addObject:[[EVStations alloc] initWithDataFromOCPPServerWithDictionary:dataDic]];
        }
        else{
            NSLog(@"3");
            [arrayStations addObject:[[EVStations alloc] initWithDataFromDictionary:dataDic]];
        }
        if(idx == arrayResult.count-1){
            [self sortArray];
            NSLog(@"arrayResult.count-1");
        }
    }];
    NSLog(@"arrayStations count------ = %lu",(unsigned long)[arrayStations count]);
}


-(NSDictionary*)setParameterwithCountryCode:(NSString*)countryCode latitude:(NSString *)selectedLatitude longitude:(NSString *)selectedLongitude{
    NSLog(@"setParameter method called");
    /*-----------------------*/
    UserSetting *userSetting;
    NSManagedObjectContext *managedObj = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserSetting" inManagedObjectContext:managedObj]];
    NSError *error = nil;
    NSArray *results = [managedObj executeFetchRequest:request error:&error];
    if(results.count)
    {
        userSetting=results[0];
    }
    /*-----------------------*/
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:selectedLongitude forKey:@"longitude"];
    [dict setValue:selectedLatitude forKey:@"latitude"];
    if (countryCode.length > 0){
        [dict setValue:@"250" forKey:@"maxresults"];
        [dict setValue:@"2000" forKey:@"distance"];
    }else{
        
        if (userSetting.searchNearbyDistance == nil) {
            [dict setValue:@"10" forKey:@"distance"];
        }else{
            [dict setValue:userSetting.searchNearbyDistance forKey:@"distance"];
        }
        //[dict setValue:@"2000" forKey:@"distance"];
        [dict setValue:@"1000" forKey:@"maxresults"];
    }
    
    if(filter){
        if(filter.chargingLevel.length>0){
            ([[filter.chargingLevel componentsSeparatedByString:@","] count] != 3)?
            [dict setValue:filter.chargingLevel forKey:@"levelid"]:nil;
        }
        else
            [dict setValue:@"4" forKey:@"levelid"];
        
        if(filter.usageType.length>0){
            ([[filter.usageType componentsSeparatedByString:@","] count] != 8)?
            [dict setValue:filter.usageType forKey:@"usagetypeid"]:nil;
        }
        else
            [dict setValue:@"8" forKey:@"usagetypeid"];
        
    }
    [dict setValue:@"json" forKey:@"output"];
    
    return dict;
}

-(void)sortArray{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distanceInMiles" ascending:YES];
    [arrayStations sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSLog(@"arrayStations count = %lu",(unsigned long)[arrayStations count]);
    [self.tableView reloadData];
    [modal hide];
}

-(void)fetchStateName{
    EVAppDelegate *appDelegete = (EVAppDelegate *)[[UIApplication sharedApplication] delegate];
    GeoCoder *reverseGeocoder = [GeoCoder new];
    [reverseGeocoder reverseGeoCode:appDelegete.currentLocation inBlock:^(NSDictionary *statename) {
        locationDict = statename;NSLog(@"State Name = %@",statename);
        if(!isFetch)
            [self fetchDataFromCoreData];
    }];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayStations.count;
    NSLog(@"arrayStations count in EVStationListingViewController = %lu",(unsigned long)[arrayStations count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"CellMessege";
    
    EVMapTableViewCell *cell = (EVMapTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[EVMapTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    EVStations *station = arrayStations[indexPath.row];
    if(station.title.length > 0){
        NSString *addressString;NSLog(@"isRCS------->%@",station.isRCS);
        if([station.isRCS isEqualToString:@"YES"]){
            addressString = [NSString stringWithFormat:@"%@",station.adderssline1];
        }else{
            addressString = [NSString stringWithFormat:@"%@,%@,%@,%@",station.adderssline1,station.town,station.stateOrProvince,station.postCode];
        }
        cell.labelAddress.text = addressString;
        cell.labelTitle.text = station.title;
        float distace = [station.distance floatValue];
        cell.labelDistance.text = [NSString stringWithFormat:@"%.2f Mi",distace];
    }
    else{
        cell.labelTitle.text = @"";
        cell.labelAddress.text = @"";
        cell.labelDistance.text = @"";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:control];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

#pragma mark _ table view Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EVMapViewController *evMapViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
    NSLog(@"array stations = %@",arrayStations[indexPath.row]);
    [evMapViewcontroller setStation:arrayStations[indexPath.row]];
    [evMapViewcontroller setNeedBack:YES];
    [self.navigationController pushViewController:evMapViewcontroller animated:YES];
}

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if(selectedSegment == 0){
        isALL = NO;
        //[self fetchOCPPStationsFromServer];
        [self fetchStationsFromServer];
        [modal show:@"Retrieving stations near you!"];
    }else{
        isALL = YES;
        [self fetchALLStationsFromServer];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    bannerView.backgroundColor=[UIColor clearColor];
    bannerView.delegate = self;
}

- (void)filterListForSearchText:(NSString *)searchText{
    searchText = searchText.lowercaseString;
    [arrayFiltred removeAllObjects];
    [arrayStations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        EVStations *stations = arrayStations[idx];
        NSString *title = stations.title;
        title = title.lowercaseString;
        if([title hasPrefix:searchText]){
            [arrayFiltred addObject:arrayStations[idx]];
        }
        if(idx == arrayStations.count-1 && ![arrayStations isKindOfClass:[NSNull class]]){
           [self.tableView reloadData];
        }
    }];
}

#pragma mark searchbar delegates
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1{
    [searchBar resignFirstResponder];
    EVMapViewController *evMapViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
    [evMapViewcontroller setSearchStringfromEvstation:searchBar1.text];
    [self.navigationController pushViewController:evMapViewcontroller animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBars{
    isSearch = NO;
    [searchBars resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        viewSearch.frame = CGRectMake(0, -100, self.view.frame.size.width, 70);
    } completion:^(BOOL finished) {
    }];
    isSearch = NO;
    [self.tableView reloadData];
}

#pragma mark adbanner delegates
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"bannerview did not receive any banner due to %@", error);}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{NSLog(@"bannerview was selected");}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{return willLeave;}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {NSLog(@"banner was loaded");}
@end
