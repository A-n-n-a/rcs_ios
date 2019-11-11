//
//  EVAddVehicleViewController.m
//  EVCompany
//
//  Created by Srishti on 02/04/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVAddVehicleViewController.h"
#import "EVSelectCarModelViewController.h"
#import "EVUser.h"
#import "EVSlidingViewController.h"
#import "TMDropDown.h"
#import "EVStations.h"
#import "EVAppDelegate.h"
#import "EVModal.h"

@interface EVAddVehicleViewController ()<didFinishSelectingCar,UIPickerViewDelegate, UIPickerViewDataSource,sendBtnTitleDelegate>{
    
    IBOutlet UITextField *textfieldCarModel;
    IBOutlet UITextField *textfieldCarType;
    IBOutlet UITextField *textfieldCarYear;
    IBOutlet UITextField *textfieldRangeOfCar;

    UITextField *activeTextField;
    UIPickerView *pickerView;
    NSMutableArray *dataArray;
    NSArray *manufacturesName;
    NSArray *vehicleModel;
    NSArray *vehicleRange;
    NSMutableArray *arrayVehicleDetails;
    NSArray *arraySelected ;
    TMDropDown *dropDown;
    UIButton *buttonSelected;
    NSUInteger index;
    NSUInteger rangeIndex;
    EVAppDelegate *deleg;
    EVModal *modal;
}


@end

@implementation EVAddVehicleViewController

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
    NSLog(@"--------------EVAddVehicleVeiwController--------------");
    [super viewDidLoad];
    self.navigationItem.title = kNAV_TITLE;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
    
    
    deleg = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
    rangeIndex = 0;
    index = 100;
    textfieldCarModel.text = [[EVUser currentUser]carModel];
    textfieldCarType.text = [[EVUser currentUser]carType];
    textfieldCarYear.text = [[EVUser currentUser]carYear];
    textfieldRangeOfCar.text = [EVUser currentUser].milesWhenFull;
    [self fetchVehicleDetails];
    dataArray = [NSMutableArray new];
    manufacturesName= @[@"Audi",@"BMW",@"Chevrolet",@"Coda",@"Fiat",@"Fisker",@"Ford",@"Honda",@"Mini",@"Mitsubishi",@"Nissan",@"Smart",@"Tesla",@"Think",@"Toyota"];
    vehicleModel = @[@[],@[@"Active E"],@[@"Spark EV",@"Volt"],@[@"Coda Sedan"],@[@"500e"],@[@"Karma"],@[@"C-MAX Energi"],@[@"Accord Plugin"],@[@"Mini-E Cooper"],@[@"Outlander PHEV",@"i-MiEV"],@[@"Leaf"],@[@"Fortwo Electric"],@[@"Model S",@"Roadster"],@[@"City"],@[@"Prius Plug-in Hybrid"]];
    vehicleRange = @[@[],@[@"Active E"],@[@"Spark EV",@"Volt"],@[@"Coda Sedan"],@[@"500e"],@[@"Karma"],@[@"C-MAX Energi"],@[@"Accord Plugin"],@[@"Mini-E Cooper"],@[@"Outlander PHEV",@"i-MiEV"],@[@"Leaf"],@[@"Fortwo Electric"],@[@"Model S",@"Roadster"],@[@"City"],@[@"Prius Plug-in Hybrid"]];
    //Get Current Year into i2
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int i2  = [[formatter stringFromDate:[NSDate date]] intValue];
    NSLog(@"i2 : %d",(i2+1));//Create Years Array from 1960 to This year
    for (int i=2000; i<=i2; i++) {
        [dataArray addObject:[NSString stringWithFormat:@"%d",(i+1)]];
    }
    
    UIButton *refreshBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [refreshBarButton addTarget:self action:@selector(fetchVehicleDetails) forControlEvents:UIControlEventTouchUpInside];
    [refreshBarButton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithCustomView:refreshBarButton];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveDetails:)];
    
    self.navigationItem.rightBarButtonItems = @[refresh,save];
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

-(void)fetchVehicleDetails{
    [self showModalWithMessage:@"Loading..."];
    EVStations *stations = [EVStations new];
    [stations fetchVehiclesWithCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            arrayVehicleDetails = result;
            NSLog(@"RCS Response Result : %@",result);
        }
        [modal hide];
    }];
}

#pragma dropdown methods
- (IBAction)dropdownAction:(id)sender{
    buttonSelected = sender;
    if ([sender isSelected]) {
        [sender setSelected:NO];
        [dropDown hideDropDownForButton:sender];
    }
    else {
        [sender setSelected:YES];
        if(buttonSelected.tag == 0) {
           arraySelected = [arrayVehicleDetails valueForKey:@"Model"];
            [self showDropDown:buttonSelected];
        }
        else if(buttonSelected.tag == 1) {
            if(index == 100){
                if(textfieldCarModel.text.length > 0){
                    [self settypeDynamically];
                }else{
                [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Select Manufacture Name First" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                }
            }else if(arraySelected.count >0){
                rangeIndex = index;
                arraySelected = arrayVehicleDetails[index][@"Type"];
                [self showDropDown:buttonSelected];
            }
        }
        else{
            arraySelected = dataArray;
            [self showDropDown:buttonSelected];
        }
    }
}

-(void)settypeDynamically{
    NSArray *array = [arrayVehicleDetails valueForKey:@"Model"];
    if([array containsObject:textfieldCarModel.text]){
        NSLog(@"selected array cartype index = %d",[array indexOfObject:textfieldCarModel.text ]);
        rangeIndex = [array indexOfObject:textfieldCarModel.text ];
        arraySelected = arrayVehicleDetails[[array indexOfObject:textfieldCarModel.text ]][@"Type"];
        [self showDropDown:buttonSelected];
    }else{
        [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Select Existing Manufacture Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
}

-(void)showDropDown:(UIButton*)sender{
    CGFloat height = 250;
    dropDown = [[TMDropDown alloc] initWithDropDownForButton:sender withHeight:&height withArray:arraySelected];
    dropDown.btnTitleDelegate=self;
    NSLog(@"showDropDown End");
    NSLog(@"index = %d",index);

}

-(void)sendTitle:(NSString *)stringButtonTitle withIndex:(NSUInteger)indexSelected{
    if(buttonSelected.tag == 0) {
        [textfieldCarModel setText:stringButtonTitle];
        [textfieldCarType setText:@""];
        [textfieldCarYear setText:@""];
        [textfieldRangeOfCar setText:@""];
        index = indexSelected;
    }
    else if(buttonSelected.tag == 1) {
        [textfieldCarType setText:stringButtonTitle];
        //[textfieldRangeOfCar setText:[arrayVehicleDetails[index][@"MilesWhenFull"] objectAtIndex:indexSelected]];
        [textfieldRangeOfCar setText:[arrayVehicleDetails[rangeIndex][@"MilesWhenFull"] objectAtIndex:indexSelected]];
    }
    else if(buttonSelected.tag == 2){
        [textfieldCarYear setText:stringButtonTitle];
    }
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma pickerView Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [dataArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [dataArray objectAtIndex: row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    textfieldCarYear.text = dataArray[row];
}


#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row == 0){
//        EVSelectCarModelViewController *selectCar = [[EVSelectCarModelViewController alloc]initWithStyle:UITableViewStylePlain];
//        selectCar.delegate = self;
//        [self.navigationController pushViewController:selectCar animated:YES];
//    }
}

- (IBAction)revealMenu:(id)sender{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)didFinishSelecting:(NSString *)carModel{
    [[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"You Have Selected %@",carModel] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    textfieldCarModel.text = carModel;
}

-(IBAction)resignResponder:(id)sender{
    UITextField *textfield = sender;
    [textfield resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    activeTextField = textField;
}

-(IBAction)saveDetails:(id)sender{
    NSLog(@"saveDetails");
    [self showModalWithMessage:@"Saving..."];
    [activeTextField resignFirstResponder];
    EVUser *user = [[EVUser alloc]init];
    user.userId = [[EVUser currentUser]userId];
    user.carModel = textfieldCarModel.text;
    user.carType = textfieldCarType.text;
    user.carYear = textfieldCarYear.text;
    user.milesWhenFull = textfieldRangeOfCar.text;
    [user changeCarDetailsWithCompletionBlock:^(BOOL success, id result,NSError *error) {
        if(success){
            NSMutableDictionary *userDir = [result[@"user_det"] mutableCopy];
            [userDir setValue:[[EVUser currentUser]tagId]  forKey:@"tagId"];
            EVUser *currentUser = [EVUser userWithDetails:userDir];
            [self showModalWithMessage:@"Saved!" forDuration:1.5];
        }
        else{
            [self showModalWithMessage:@"Failed" forDuration:1.5];
        }
    }];
}


#pragma mark protocol methods.
//--------------------------------------------------------------------------------------------------
// TextField start Editing
//--------------------------------------------------------------------------------------------------



#pragma mark protocol methods.
//--------------------------------------------------------------------------------------------------
// Return key Pressed
//--------------------------------------------------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 1){
        [textfieldRangeOfCar resignFirstResponder];
    }else{
        [textfieldRangeOfCar resignFirstResponder];
    }
    return TRUE;
}


@end
