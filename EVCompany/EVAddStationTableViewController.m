//
//  EVAddStationTableViewController.m
//  Sample
//
//  Created by Chitra  on 31/03/14.
//  Copyright (c) 2014 bala. All rights reserved.
//

#import "EVAddStationTableViewController.h"
#import "TextFieldCell.h"
#import "ButtonCell.h"
#import "GeoCoder.h"
#import "EVStations.h"
#import "EVUser.h"
#import "EVImageCell.h"
#import "EVMapViewController.h"
#import "EVModal.h"

@interface EVAddStationTableViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    EVImageCell *imageCell;
    TextFieldCell *phoneCell;
    TextFieldCell *operatorInfo;
    TextFieldCell *descriptionCell;
    TextFieldCell *titleCell;
    TextFieldCell *addressCell;
    TextFieldCell *cellA;
    TextFieldCell *cellB;
    TextFieldCell *CellC;
    TextFieldCell *expandcellA1,*expandcellA2,*expandcellA3;
    TextFieldCell *expandcellB1,*expandcellB2,*expandcellB3;
    TextFieldCell *expandcellC1,*expandcellC2,*expandcellC3,*expandcellC4;
    EVModal *modal;

    TextFieldCell *selectedLevelCell,*selectedUsageCell,*selectedStatusCell;
    ButtonCell *expandCellA,*expandCellB,*expandCellC,*submitCell;
    NSArray *tableviewCells;
    NSArray *arrayConnectorType;
    NSMutableArray *cells,*arraySelectedCells,*arraySelectedLevel,*arraySelectedUsage,
    *arraySelectedStatus,*arraySelectedChargingLevels,*arrayLevelTypes;
    NSArray  *arrayLevels,*arrayUsagetypes,*arrayStatus;
    NSDictionary *locationDetails;
    NSMutableString *connector;
    UITextField *activeTextField;
    NSUInteger index;
    int startIndex;
    BOOL isExpand;
    
    BOOL isExpandableAbuttonClicked;
    BOOL isExpandableBbuttonClicked;
    BOOL isExpandableCbuttonClicked;
}
@end

@implementation EVAddStationTableViewController

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
    NSLog(@"--------------EVAddStationTableViewController--------------");
    [super viewDidLoad];
    self.navigationItem.title = kNAV_TITLE;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

    [self showModalWithMessage:@"Loading..."];

    arraySelectedCells = [NSMutableArray new];
    arraySelectedUsage = [NSMutableArray new];
    arraySelectedLevel = [NSMutableArray new];
    arraySelectedStatus = [NSMutableArray new];
    arraySelectedChargingLevels = [NSMutableArray new];
    arrayLevelTypes = [NSMutableArray new];
    GeoCoder *geocoder = [[GeoCoder alloc]init];
    [geocoder reverseGeoCode:_location inBlock:^(NSDictionary *locations) {
        NSString *address = locations[@"address"];
        if(address.length > 0){
            locationDetails = locations;
            [self createTableviewCells];
        }else{
            [self showModalWithMessage:@"Failed" forDuration:1.0];
            [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please Select Another Location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
    }];

    isExpandableAbuttonClicked = NO;
    isExpandableBbuttonClicked = NO;
    isExpandableCbuttonClicked = NO;
    arrayConnectorType = @[@"NEMA515",@"J1772",@"NEMA520",@"CHADEMO"];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)showModalWithMessage:(NSString*)message {
    [modal setMessage: message];
    [modal show];
}

-(void)showModalWithMessage:(NSString*)message forDuration:(CGFloat)duration {
    [modal setMessage: message];
    [modal showWithoutSpinner];
    
    [NSTimer scheduledTimerWithTimeInterval: duration target:modal selector:@selector(hide) userInfo:nil repeats:NO];
}

-(void)createTableviewCells
{
     cells = [[NSMutableArray alloc]init];
    imageCell = [[EVImageCell alloc]init];
    imageCell.labelTitle.text = @"Add Photo";
    [cells addObject:imageCell];

    titleCell = [[TextFieldCell alloc]initWithLabel:@"Title" withFontSizeOfLabel:15];
    [titleCell.textField setDelegate:self];
    [titleCell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [titleCell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
    [titleCell.textField addTarget:self action:@selector(resignResponder:) forControlEvents:UIControlEventEditingDidEnd];
    [cells addObject:titleCell];
    
    phoneCell = [[TextFieldCell alloc]initWithLabel:@"Phone Number" withFontSizeOfLabel:15];
    [phoneCell.textField setDelegate:self];
    [phoneCell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [phoneCell.textField setKeyboardType:UIKeyboardTypeNumberPad];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidPressed:)];
    [doneItem setTintColor:[UIColor blueColor]];
    UIBarButtonItem *flexableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:flexableItem,doneItem, nil]];
    phoneCell.textField.inputAccessoryView = toolbar;
    
    [phoneCell.textField addTarget:self action:@selector(resignResponder:) forControlEvents:UIControlEventEditingDidEnd];
    [cells addObject:phoneCell];
    
    
    
    descriptionCell = [[TextFieldCell alloc]initWithLabel:@"Notes/Access Information" withFontSizeOfLabel:15];
    [descriptionCell.textField setDelegate:self];
    [descriptionCell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [descriptionCell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
    [descriptionCell.textField addTarget:self action:@selector(resignResponder:) forControlEvents:UIControlEventEditingDidEnd];
    [cells addObject:descriptionCell];
    
    operatorInfo = [[TextFieldCell alloc]initWithLabel:@"Operator" withFontSizeOfLabel:15];
    [operatorInfo.textField setDelegate:self];
    [operatorInfo.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [operatorInfo.textField setKeyboardType:UIKeyboardTypeEmailAddress];
    [operatorInfo.textField addTarget:self action:@selector(resignResponder:) forControlEvents:UIControlEventEditingDidEnd];
    [cells addObject:operatorInfo];

    
    addressCell = [[TextFieldCell alloc]initWithstring:locationDetails[@"address"] withFontSizeOfLabel:15 withHeight:60];
    [cells addObject:addressCell];
    
    [arrayConnectorType enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TextFieldCell * cell = [[TextFieldCell alloc]initWithstring:arrayConnectorType[idx] withFontSizeOfLabel:15 withHeight:43];
        [cell.leftButton addTarget:self action:@selector(onCellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cells addObject:cell];
    }];
    
    
    
    expandCellA = [[ButtonCell alloc]initWithTitles:@[@"CHARGING LEVEL"]];
    [expandCellA.leftButton addTarget:self action:@selector(onExpandAButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [cells addObject: expandCellA];
    
    expandCellB = [[ButtonCell alloc]initWithTitles:@[@"USAGE TYPE"]];
    [expandCellB.leftButton addTarget:self action:@selector(onExpandBButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [cells addObject: expandCellB];
    
    expandCellC = [[ButtonCell alloc]initWithTitles:@[@"OPERATIONAL STATUS"]];
    [expandCellC.leftButton addTarget:self action:@selector(onExpandCButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [cells addObject: expandCellC];

    
    submitCell = [[ButtonCell alloc]initWithsubmitButton:@"Submit"];
    [submitCell.leftButton addTarget:self action:@selector(onSubmitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cells addObject:submitCell];

    tableviewCells = cells.mutableCopy ;
    [self.tableView reloadData];

}
- (void)doneButtonDidPressed:(id)sender {
    [phoneCell.textField resignFirstResponder];
}
-(void)onExpandAButtonClicked
{
    startIndex = 11;
    arrayLevels = @[@"Level 1 : Low (Under 2kW)",@"Level 2 : Medium (Over 2kW)",@"Level 3:  High (Over 40kW)"];
    if (isExpandableAbuttonClicked == NO) {
        [arraySelectedLevel removeAllObjects];
        [arrayLevels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TextFieldCell *textFieldCell = [[TextFieldCell alloc]initWithstring:arrayLevels[idx] withFontSizeOfLabel:15 withHeight:43];
            [textFieldCell.leftButton addTarget:self action:@selector(onCellSelected:) forControlEvents:UIControlEventTouchUpInside];
            [arraySelectedLevel  addObject:textFieldCell];
            [cells insertObject:textFieldCell atIndex:startIndex];
            startIndex +=1;
        }];
        isExpandableAbuttonClicked = YES;
        isExpand = YES;
        index = 15;
        
    }else
    {
        startIndex = 13;
        [arrayLevels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [cells removeObjectAtIndex:startIndex];
            startIndex -= 1;
        }];
        isExpandableAbuttonClicked = NO;
        isExpand = NO;
    }
    tableviewCells = cells.mutableCopy;
    [self.tableView reloadData];
}
-(void)onExpandBButtonClicked
{
    startIndex = 12;
    arrayUsagetypes = @[@"Unknown",@"Private - For Staff and Visitors",@"Private - Restricted Access",@"Privately Owned - Notice Required",@"Public",@"Public - Membership Required",@"Public - Notice Required",@"Public - Pay At Location"];
    [arraySelectedUsage removeAllObjects];
    if (isExpandableBbuttonClicked == NO) {
        [arrayUsagetypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TextFieldCell *textfieldCell = [[TextFieldCell alloc]initWithstring:arrayUsagetypes[idx] withFontSizeOfLabel:15 withHeight:43];
            [textfieldCell.leftButton addTarget:self action:@selector(onCellSelected:) forControlEvents:UIControlEventTouchUpInside];
            [arraySelectedUsage addObject:textfieldCell];
            [cells insertObject:textfieldCell atIndex:isExpandableAbuttonClicked?startIndex+arrayLevels.count:startIndex];
        }];
        index = isExpandableAbuttonClicked?19+arrayLevels.count:19;
        isExpand = YES;
        isExpandableBbuttonClicked = YES;
    }else
    {
        startIndex = 19;
        [arrayUsagetypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [cells removeObjectAtIndex:isExpandableAbuttonClicked?startIndex+arrayLevels.count:startIndex];
            startIndex -= 1;

        }];
        isExpandableBbuttonClicked = NO;
        isExpand = NO;
    }
    tableviewCells = cells.mutableCopy;
    [self.tableView reloadData];
}
-(void)onExpandCButtonClicked
{
    
    arrayStatus = @[@"Unknown",@"Currently Available (Automated Status)",@"Temporarily Unavailable",@"Operational",@"Partly Operational (Mixed)",@"Not Operational",@"Removed (Decomissioned)"];
    [arraySelectedStatus removeAllObjects];
    if (isExpandableCbuttonClicked == NO) {
        startIndex = 13 ;
        [arrayStatus enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TextFieldCell *textFieldCell = [[TextFieldCell alloc]initWithstring:arrayStatus[idx] withFontSizeOfLabel:15 withHeight:43];
            [textFieldCell.leftButton addTarget:self action:@selector(onCellSelected:) forControlEvents:UIControlEventTouchUpInside];
            [arraySelectedStatus addObject:textFieldCell];
            if(isExpandableAbuttonClicked){
                [cells insertObject:textFieldCell atIndex:isExpandableBbuttonClicked?startIndex+arrayLevels.count+arrayUsagetypes.count:startIndex+arrayLevels.count];
                index= isExpandableBbuttonClicked?19+arrayLevels.count+arrayUsagetypes.count:19;
            }else{
                [cells insertObject:textFieldCell atIndex:isExpandableBbuttonClicked?startIndex+arrayUsagetypes.count:startIndex];
                index = isExpandableBbuttonClicked?19+arrayUsagetypes.count:19;
            }
            startIndex += 1;
        }];
        isExpand = YES;
        isExpandableCbuttonClicked = YES;
    }else
    {
        startIndex = 19;
        if(isExpandableAbuttonClicked){
            [arrayStatus enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [cells removeObjectAtIndex:isExpandableBbuttonClicked?startIndex+arrayLevels.count+arrayUsagetypes.count:startIndex+arrayLevels.count];
                startIndex -= 1;
            }];
            
        }else if(isExpandableBbuttonClicked) {
            [arrayStatus enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [cells removeObjectAtIndex:startIndex+arrayUsagetypes.count];
                startIndex -= 1;
            }];
            
        }else{
            
            [arrayStatus enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [cells removeObjectAtIndex:isExpandableBbuttonClicked?startIndex+arrayLevels.count+arrayStatus.count:startIndex];
                startIndex -=1;
            }];
        }

        isExpandableCbuttonClicked = NO;
        isExpand = NO;
    }
    tableviewCells = cells.mutableCopy;
    [self.tableView reloadData];
}

-(void)onSubmitButtonPressed
{
    [activeTextField resignFirstResponder];
    connector = [[NSMutableString alloc]init];

    if([titleCell.textField.text isEqualToString:@"" ])
        [[[UIAlertView alloc]initWithTitle:@"You Must Enter the Title" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    else if(arraySelectedCells.count == 0)
        [[[UIAlertView alloc]initWithTitle:@"You Must Select an Outlet Type" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    else{
        [self showModalWithMessage:@"Loading..."];
        EVStations *station = [[EVStations alloc]init];
        station.adderssline1 = locationDetails[@"address"];
        station.stateOrProvince = locationDetails[@"state"];
        station.postCode = locationDetails [@"postcode"];
        station.userId = [[EVUser currentUser]userId];
        station.title = titleCell.textField.text;
        station.usageType = [self findUsageTypes:selectedUsageCell.labelFieldName.text];
        if(arraySelectedChargingLevels.count > 0){
            [arraySelectedChargingLevels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                TextFieldCell *cell = arraySelectedChargingLevels[idx];
                if([cell.labelFieldName.text isEqualToString:@"Level 1 : Low (Under 2kW)"])
                    [arrayLevelTypes addObject:@"1"];
                else if([cell.labelFieldName.text isEqualToString:@"Level 2 : Medium (Over 2kW)"])
                    [arrayLevelTypes addObject:@"2"];
                else
                    [arrayLevelTypes addObject:@"3"];
                if(idx == arraySelectedChargingLevels.count-1){
                    station.powerLevel = [arrayLevelTypes componentsJoinedByString:@","];
                }
            }];
        }else{
            station.powerLevel = @"";
        }
        station.status = (selectedStatusCell.labelFieldName.text.length > 0)? selectedStatusCell.labelFieldName.text : @"";
        station.imageName = @"image";
        station.image = imageCell.addedImage.image;
        station.hoursOfOperation = operatorInfo.textField.text;
        station.latitude = [NSString stringWithFormat:@"%f",_location.coordinate.latitude];
        station.longitude = [NSString stringWithFormat:@"%f",_location.coordinate.longitude];
//      TextFieldCell *cell = arraySelectedCells[0];
//      station.connectorType = cell.textField.text ;
        NSMutableArray *arrayConnector = [NSMutableArray new];
        [arraySelectedCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TextFieldCell *cell = arraySelectedCells[idx];
            [arrayConnector addObject:cell.labelFieldName.text];
            station.connectorType = [arrayConnector componentsJoinedByString:@","];
        }];
        
        station.descriptions = descriptionCell.textField.text.length > 0 ?descriptionCell.textField.text:@"";
        station.contactTelephone1 = phoneCell.textField.text.length > 0 ?phoneCell.textField.text:@"";
        station.operatorInfo = operatorInfo.textField.text.length > 0 ?operatorInfo.textField.text:@"";
        [station addStationsWithCompletionBlock:^(BOOL success, id result, NSError *error) {
            NSLog(@"Get add station responce data : %@",result);
            if(success){
                [self showModalWithMessage:@"Success!" forDuration:1.5];
                EVMapViewController *evMapViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
                [self.navigationController pushViewController:evMapViewcontroller animated:YES ];
            }
            else{
                [self showModalWithMessage:@"Station already exists" forDuration:1.5];
            }
    
        }];
    }
}
-(NSString *)findUsageTypes:(NSString *)selectedUsageCellText{
    NSString *usageType;
    if([selectedUsageCellText isEqualToString:@"Unknown"])
        usageType = @"0";
    else if([selectedUsageCellText isEqualToString:@"Public"])
        usageType = @"1";
    else if([selectedUsageCellText isEqualToString:@"Private - Restricted Access"])
        usageType = @"2";
    else if([selectedUsageCellText isEqualToString:@"Privately Owned - Notice Required"])
        usageType = @"3";
    else if([selectedUsageCellText isEqualToString:@"Public - Membership Required"])
        usageType = @"4";
    else if([selectedUsageCellText isEqualToString:@"Public - Pay At Location"])
        usageType = @"5";
    else if([selectedUsageCellText isEqualToString:@"Private - For Staff and Visitors"])
        usageType = @"6";
    else
        usageType = @"7";
                            
    
    
    return usageType;
}
-(IBAction)resignResponder:(id)sender{
    UITextField *textfield = sender;
    [textfield resignFirstResponder];
}
- (void)imageButtonAction {
    
    [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor blueColor]];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    UIActionSheet *popUpShare = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery",nil];
    popUpShare.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popUpShare showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController setDelegate:self];
    
    switch (buttonIndex) {
        case 0:
            
            imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
            
            break;
        case 1:
            
            imagePickerController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            [self setBarButton];
            return;
            break;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

-(void)setBarButton{
//    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
//    UIImage *backButton = [[UIImage imageNamed:@"whiteBack"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, -8)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsDefault];

}

#pragma UIImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self setBarButton];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [imageCell.addedImage setImage:selectedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    activeTextField = textField;
}

-(void)onCellSelected :(UIButton *)sender
{
    TextFieldCell *cell;
    NSIndexPath *indexPath;
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[vComp objectAtIndex:0] intValue] == 7)
    {
        
        cell  = (TextFieldCell *)[[sender.superview superview] superview] ;
        indexPath = [self.tableView indexPathForCell:cell];
        
    } else {
        cell  = (TextFieldCell *)[sender.superview superview];
        indexPath= [self.tableView indexPathForCell:cell];
        
    }
    cell = tableviewCells[indexPath.row];
    startIndex= isExpandableAbuttonClicked?14:12;
    
    if(indexPath.row > startIndex){
        if([arraySelectedUsage containsObject:cell])
            selectedUsageCell.accessoryType = UITableViewCellAccessoryNone;
        else if([arraySelectedStatus containsObject:cell])
            selectedStatusCell.accessoryType = UITableViewCellAccessoryNone;
        
        if( [selectedUsageCell isEqual: cell] || [selectedStatusCell isEqual:cell]){
            [selectedStatusCell isEqual: cell]?selectedStatusCell = nil : nil;
            [selectedUsageCell isEqual: cell]?selectedUsageCell = nil : nil;
             cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            if([arraySelectedUsage containsObject:cell])
                selectedUsageCell = cell;
            else if([arraySelectedStatus containsObject:cell])
                selectedStatusCell = cell;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else if(indexPath.row > 10 && indexPath.row < 15){
        
        if ([arraySelectedChargingLevels containsObject:cell])
        {
            [arraySelectedChargingLevels removeObject:cell];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else
        {
            [arraySelectedChargingLevels addObject:cell];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else{
            if ([arraySelectedCells containsObject:cell])
            {
                [arraySelectedCells removeObject:cell];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }else
            {
                [arraySelectedCells addObject:cell];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
}
-(void)scrollTableViewToSelectedLocationWithRow:(NSUInteger)row{
    isExpand = NO;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
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
    return tableviewCells.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5) {
        return 70;
    }
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if(index > indexPath.row && isExpand)
           [self scrollTableViewToSelectedLocationWithRow:index];
    [tableviewCells[indexPath.row] setSelectionStyle:UITableViewCellSelectionStyleNone];
        return tableviewCells[indexPath.row];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        [self imageButtonAction];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
