//
//  EVLoginViewController.m
//  EVCompany
//
//  Created by Srishti on 26/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVLoginViewController.h"
#import "EVSlidingViewController.h"
#import "EVUser.h"
#import "EVMapViewController.h"
#import "EVOCPPClientApi.h"
#import "config.h"
#import "EVAppDelegate.h"
#import "UserSetting.h"
#import "EVModal.h"

@interface EVLoginViewController (){
    UITextField *activeTextField;
    IBOutlet UIButton *buttonRemind;
    IBOutlet UIView *viewButtons;
    IBOutlet UIView *forgotviewButtons;
    EVAppDelegate *deleg;
    NSManagedObjectContext *managedObjectContext;
    EVModal *modal;
}
@property (nonatomic,strong)IBOutlet UITextField *textFieldEmail;
@property (nonatomic,strong)IBOutlet UITextField *textFieldPassword;


@end

@implementation EVLoginViewController

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
    NSLog(@"--------------EVLoginViewController--------------");
    [super viewDidLoad];
    self.navigationItem.title = kNAV_TITLE;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
    
    deleg = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
    _textFieldEmail.keyboardType = UIKeyboardTypeEmailAddress;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"remind"] isEqualToString:@"yes"]){
        _textFieldPassword.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        _textFieldEmail.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
        [buttonRemind setBackgroundImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)orientationChanged:(NSNotification *)notification{
    viewButtons.frame = CGRectMake(self.view.frame.size.width/2-viewButtons.frame.size.width/2, viewButtons.frame.origin.y, viewButtons.frame.size.width, viewButtons.frame.size.height);
    forgotviewButtons.frame = CGRectMake(self.view.frame.size.width/2-forgotviewButtons.frame.size.width/2, forgotviewButtons.frame.origin.y, forgotviewButtons.frame.size.width, forgotviewButtons.frame.size.height);
}

-(IBAction)loginAction:(id)sender{
    [_textFieldEmail resignFirstResponder];
    [_textFieldPassword resignFirstResponder];
    if([_textFieldEmail.text isEqualToString:@""] || [_textFieldPassword.text isEqualToString:@""]){
        [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please Enter All Fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        
    }else{
        [modal show:@"Logging in..."];
        EVUser *user = [[EVUser alloc] init];
        user.email = _textFieldEmail.text;
        user.password = _textFieldPassword.text;
        
        [EVUser loginWithEmail:_textFieldEmail.text password:_textFieldPassword.text withCompletionBlock:^(BOOL success, id result, NSError *error) {
            if(success){
                [self addUserToOcpp];
                NSMutableDictionary *userDir = [result[@"User_details"] mutableCopy];
                [self saveReminder];
                [self sendAddUserRequestwithCompletionBlock:^(BOOL success, id result, NSError *error) {
                    if (success) {
                        if (![result[@"tagId"] isEqualToString:@""]) {
                            
                            [userDir setValue:deleg.tagId forKey:@"tagId"];
                            [EVUser userWithDetails:userDir];
                            [modal show:@"Success!" for:1.5];
                            EVMapViewController *evMapViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
                            [self.navigationController pushViewController:evMapViewcontroller animated:YES];
                        }
                        else{
                            
                        }
                    }else{
                        [modal show:@"Failed" for:1.5];
                    }
                }];
            }else {
                [modal show:@"Failed" for:1.5];
            }
        }];
    }
}

- (IBAction)sendAddUserRequestwithCompletionBlock:(void (^)(BOOL,id, NSError *))completionBlock {
    NSDictionary *customerId_dictionary = [NSDictionary dictionaryWithObjects:@[kCutomerId] forKeys:@[@"id"]];
    NSDictionary *roleId_dictionary = [NSDictionary dictionaryWithObjects:@[@"4"] forKeys:@[@"id"]];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSDictionary *tagDict = [NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%d",[self generateTagId]],@"11111",@"Accepted",@"true"] forKeys:@[@"tagId",@"externalTagId",@"ocppAuthorizationStatus",@"is_active"]];
    
    NSArray *tagArray = [NSArray arrayWithObjects:tagDict, nil];
    [dict setValue:@"" forKey:@"firstName"];
    [dict setValue:@"" forKey:@"lastName"];
    [dict setValue:_textFieldEmail.text forKey:@"userId"];
    [dict setValue:_textFieldPassword.text forKey:@"password"];
    [dict setValue:@"" forKey:@"streetAddress1"];
    [dict setValue:@"" forKey:@"streetAddress2"];
    [dict setValue:@"" forKey:@"city"];
    [dict setValue:@"" forKey:@"state"];
    [dict setValue:@"" forKey:@"country"];
    [dict setValue:customerId_dictionary forKey:@"customerId"];
    [dict setValue:roleId_dictionary forKey:@"roleId"];
    [dict setValue:tagArray forKey:@"tagList"];
    NSLog(@"Adduser Service parameter Data : %@",dict);
    
    [[EVOCPPClientApi sharedOcppClient] addUserToOcppServerWithParameters:dict Success:^(id result) {
        NSLog(@"Adduser Service Responce Data : %@",result);
        deleg.tagId = result[@"tagId"];
        completionBlock(YES,result,nil);
    } Failure:^(NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        completionBlock(NO,@"",error);
    }];
}

-(IBAction)setDefaultUserSetting:(id)sender{
    [modal show:@"Loading..."];
    UserSetting *userSetting;
    managedObjectContext = ((EVAppDelegate*)[[UIApplication sharedApplication]delegate ]).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserSetting" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if(results.count)
    {
        userSetting=results[0];
    }
    else
    {
        userSetting = [NSEntityDescription insertNewObjectForEntityForName:@"UserSetting"
                                                    inManagedObjectContext:managedObjectContext];
    }
    
    userSetting.notifyBeforeDistance = @"5";
    userSetting.notifyBeforeTime = @"5";
    userSetting.searchNearbyDistance = @"10";
    
    if (![managedObjectContext save:&error]) {
    }
    [modal show:@"Success1" for:1.5];
    deleg.delegNotifyDistStr = @"5";
}

-(int)generateTagId{
    int rangeLow = 1000;
    int rangeHigh = 100000000;
    int randomNumber = arc4random() % (rangeHigh-rangeLow+1) + rangeLow;
    return randomNumber;
}

//my method
-(void)addUserToOcpp
{
    NSLog(@"userId = %@",[EVUser currentUser].userId);
    NSLog(@"first Name = %@",[EVUser currentUser].firstname);
    NSLog(@"last Name = %@",[EVUser currentUser].lastName);
    NSLog(@"image Name = %@",[EVUser currentUser].imageName);
    NSLog(@"email = %@",[EVUser currentUser].email);
    NSLog(@"phone no = %@",[EVUser currentUser].phoneNumber);
    NSLog(@"member since date = %@",[EVUser currentUser].memberSincedate);
    NSLog(@"about me = %@",[EVUser currentUser].aboutMe);
    NSLog(@"profile pic = %@",[EVUser currentUser].profilePic);
    NSLog(@"car model = %@",[EVUser currentUser].carModel);
    NSLog(@"car type = %@",[EVUser currentUser].carType);
    NSLog(@"car year = %@",[EVUser currentUser].carYear);
}

-(void)saveReminder{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"remind"] isEqualToString:@"yes"]){
        [[NSUserDefaults standardUserDefaults] setObject:_textFieldEmail.text forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setObject:_textFieldPassword.text forKey:@"password"];
    }
}

-(IBAction)remember:(id)sender{
    UIButton *button = sender;
    if([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"untick"]]){
        [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"remind"];
        [button setBackgroundImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"remind"];
        [button setBackgroundImage:[UIImage imageNamed:@"untick"] forState:UIControlStateNormal];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    

}

-(IBAction)forgotPassword:(id)sender{
    if(![_textFieldEmail.text isEqualToString:@""]){
    [modal show:@"Loading..."];
    EVUser *user = [[EVUser alloc]init];
    user.email = _textFieldEmail.text;
    [user forgotPasswordwithCompletionBlock:^(BOOL success, id result, NSError *error) {
        
        if(success){
            [modal show:@"Password reset requested!" for:1.5];
            [[[UIAlertView alloc]initWithTitle:@"Message" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }else
            [modal show:@"Failed" for:1.5];
    }];
    }else{
        [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please Enter Email ID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
}

- (IBAction)revealMenu:(id)sender{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(IBAction)resignResponder:(id)sender{
    UITextField *textfield = sender;
    [textfield resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    activeTextField = textField;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(NSString *)getRandomPINString:(NSInteger)length{
    NSMutableString *returnString = [NSMutableString stringWithCapacity:length];
    NSString *numbers = @"0123456789";
    // First number cannot be 0
    [returnString appendFormat:@"%C", [numbers characterAtIndex:(arc4random() % ([numbers length]-1))+1]];
    for (int i = 1; i < length; i++){
        [returnString appendFormat:@"%C", [numbers characterAtIndex:arc4random() % [numbers length]]];
    }
    return returnString;
}

@end
