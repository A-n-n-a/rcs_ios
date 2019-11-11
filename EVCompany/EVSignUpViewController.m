//
//  EVSignUpViewController.m
//  EVCompany
//
//  Created by Srishti on 25/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVSignUpViewController.h"
#import "EVUser.h"
#import "EVSlidingViewController.h"
#import "EVMapViewController.h"
#import "EVOCPPClientApi.h"
#import "EVAppDelegate.h"
#import "EVModal.h"


@interface EVSignUpViewController ()<UITextFieldDelegate>{
    UITextField *activeTextfield;
    EVAppDelegate *deleg;
    EVModal *modal;
}
@property (nonatomic, strong)IBOutlet UITextField *textFieldFirstName;
@property (nonatomic, strong)IBOutlet UITextField *textFieldLastName;
@property (nonatomic, strong)IBOutlet UITextField *textFieldEmail;
@property (nonatomic, strong)IBOutlet UITextField *textFieldPassword;

@end

@implementation EVSignUpViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    NSLog(@"--------------EVSignUpViewController--------------");
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];

    self.navigationItem.title = kNAV_TITLE;
    _textFieldEmail.keyboardType = UIKeyboardTypeEmailAddress;
    deleg = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
}

- (IBAction)revealMenu:(id)sender{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(IBAction)signUpAction:(id)sender{
    [_textFieldFirstName resignFirstResponder];
    [_textFieldLastName resignFirstResponder];
    [_textFieldEmail resignFirstResponder];
    [_textFieldPassword resignFirstResponder];
    if([_textFieldFirstName.text isEqualToString:@""] || [_textFieldPassword.text isEqualToString:@""] || [_textFieldEmail.text  isEqualToString:@""] || [_textFieldLastName.text isEqualToString:@""]){
        [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please Enter All Fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }else{
        [modal show:@"Signing up..."];
        EVUser *user = [[EVUser alloc] init];
        user.email = _textFieldEmail.text;
        user.password = _textFieldPassword.text;
        user.firstname = _textFieldFirstName.text;
        user.lastName = _textFieldLastName.text;
        
        [user signUpwithCompletionBlock:^(BOOL success,id result, NSError *error) {
            if(success){
                [modal show:@"Success!" for:1.5];
                NSMutableDictionary *userDir = [result[@"User_details"] mutableCopy];
                [self sendAddUserRequestwithCompletionBlock:^(BOOL success, id result, NSError *error) {
                    if (![result[@"tagId"] isEqualToString:@""]) {
                        NSLog(@"tagId is not blank & tagId = %@",result[@"tagId"]);
                        [userDir setValue:deleg.tagId forKey:@"tagId"];
                        [EVUser userWithDetails:userDir];
                        //[EVUser currentUser].tagId = @"123";
                        EVMapViewController *evMapViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
                        [self.navigationController pushViewController:evMapViewcontroller animated:YES];
                    }
                    else{
                        NSLog(@"tagId is blank");
                    }
                    
                }];
            }else {
                [modal show:result for:1.5];
            }
        }];
    }
}

- (IBAction)sendAddUserRequestwithCompletionBlock:(void (^)(BOOL,id, NSError *))completionBlock {
    NSDictionary *customerId_dictionary = [NSDictionary dictionaryWithObjects:@[kCutomerId] forKeys:@[@"id"]];
    NSDictionary *roleId_dictionary = [NSDictionary dictionaryWithObjects:@[@"4"] forKeys:@[@"id"]];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSDictionary *tagDict = [NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%d",[self generateTagId]],@"11111",@"Accepted",@"true"] forKeys:@[@"tagId",@"externalTagId",@"ocppAuthorizationStatus",@"is_active"]];
   // NSLog(@"tag id =%@",[NSString stringWithFormat:@"%d",[self generateTagId]]);
    NSLog(@"password =%@",_textFieldPassword.text);
    NSArray *tagArray = [NSArray arrayWithObjects:tagDict, nil];
    [dict setValue:_textFieldFirstName.text forKey:@"firstName"];
    [dict setValue:_textFieldLastName.text forKey:@"lastName"];
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
    NSLog(@"Parameter Data = %@",dict);
    
    [[EVOCPPClientApi sharedOcppClient] addUserToOcppServerWithParameters:dict Success:^(id result) {
        NSLog(@"result = %@",result);
        NSLog(@"success");
        deleg.tagId = result[@"tagId"];
        completionBlock(YES,result,nil);
    } Failure:^(NSError *error) {
        NSLog(@"fail");
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        completionBlock(NO,@"",error);
    }];
}

-(int)generateTagId{
    int rangeLow = 1000;
    int rangeHigh = 100000000;
    int randomNumber = arc4random() % (rangeHigh-rangeLow+1) + rangeLow;
    return randomNumber;
}

-(IBAction)resignResponder:(id)sender{
    UITextField *textfield = sender;
    [textfield resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    activeTextfield = textField;
}

@end
