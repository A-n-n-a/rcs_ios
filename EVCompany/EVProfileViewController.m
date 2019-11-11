//
//  EVProfileViewController.m
//  EVCompany
//
//  Created by Srishti on 26/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVProfileViewController.h"
#import "EVSlidingViewController.h"
#import "EVUser.h"
#import "UIImageView+WebCache.h"
#import "KGModal.h"
#import "EVAppDelegate.h"
#import "EVModal.h"

@interface EVProfileViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    EVAppDelegate *deleg;
    EVModal *modal;
}
@property (nonatomic, strong)IBOutlet UIImageView *imageProfile;
@property (nonatomic, strong)IBOutlet UITextView *textViewBio;
@property (nonatomic, strong)IBOutlet UITextField *textFieldFirstName;
@property (nonatomic, strong)IBOutlet UITextField *textFieldLastName;
@property (nonatomic, strong)IBOutlet UITextField *textFieldPhoneNumber;
@property (nonatomic, strong)IBOutlet UITextField *textFieldEmail;
@property (nonatomic, strong)IBOutlet UILabel *labeldate;
@property (nonatomic, strong)IBOutlet UIButton *changePasswordButton;


@end

@implementation EVProfileViewController

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
    NSLog(@"--------------EVProfileViewController--------------");
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
   
    deleg = (EVAppDelegate *)[[UIApplication sharedApplication]delegate];
    self.navigationItem.title = kNAV_TITLE;

    [self fetchProfile];
    [_textFieldPhoneNumber setKeyboardType:UIKeyboardTypeNumberPad];
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    _textFieldPhoneNumber.inputAccessoryView = numberToolbar;
    
    _imageProfile.layer.cornerRadius = 40;
    _imageProfile.layer.borderColor = [UIColor colorWithRed:41.0/255.0 green:175.0/255.0 blue:62.0/255.0 alpha:1.0].CGColor;
    _imageProfile.layer.borderWidth = 1.0;
    _imageProfile.layer.masksToBounds = YES;
}

-(void)doneWithNumberPad{
    [_textFieldPhoneNumber resignFirstResponder];
}

-(void)fetchProfile{
    [modal show:@"Loading..."];
    EVUser *user = [[EVUser alloc]init];
    user.userId = [[EVUser currentUser]userId];
    [user fetchProfilewithCompletionBlock:^(BOOL success, id result, NSError *error) {
        if(success){
            NSMutableDictionary *userDir = [result[@"User_details"] mutableCopy];
        //a    [userDir setValue:deleg.tagId forKey:@"tagId"];
            [userDir setValue:[[EVUser currentUser]tagId]  forKey:@"tagId"];
            EVUser *currentUser = [EVUser userWithDetails:userDir];
            [modal hide];
            [self showProfile];
            
        }else
            [modal show:@"Failed" for:1.5];
    }];
}

-(void)showProfile{
    _textFieldEmail.text = [[EVUser currentUser]email];
    _textFieldFirstName.text = [[EVUser currentUser]firstname];
    _textFieldLastName.text = [[EVUser currentUser]lastName];
    _textFieldPhoneNumber.text = [[EVUser currentUser]phoneNumber];
    NSString *imageName = [[EVUser currentUser]imageName];
    _textViewBio.text = [[EVUser currentUser] aboutMe];
    _labeldate.text = [NSString stringWithFormat:@"Member Since %@",[[EVUser currentUser]memberSincedate]];
    NSString *image = [NSString stringWithFormat: @"https://revitalizechargingsolutions.com/rcsappdatabase/user_images/%@",imageName];
    NSURL *url = [NSURL URLWithString:image];
    
    if(imageName.length > 0)
        [_imageProfile setImageWithURL:url];
}

- (void)doneButtonDidPressed:(id)sender {
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [_textFieldPhoneNumber resignFirstResponder];
}

- (IBAction)revealMenu:(id)sender{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(IBAction)saveAction:(id)sender{
    [modal show:@"Saving..."];
    EVUser *user = [[EVUser alloc]init];
    user.firstname = _textFieldFirstName.text;
    user.lastName = _textFieldLastName.text;
    user.email = _textFieldEmail.text;
    user.phoneNumber = _textFieldPhoneNumber.text;
    user.profilePic = _imageProfile.image;
    user.aboutMe = _textViewBio.text;
    user.imageName = _textFieldEmail.text;
    user.userId = [[EVUser currentUser]userId];
    [user editProfilewithCompletionBlock:^(BOOL success,id result, NSError *error) {
        if(success){
            NSString *resultstring = result[@"result"];
            NSMutableDictionary *userDir = [result[@"User_details"] mutableCopy];
            [userDir setValue:[[EVUser currentUser]tagId]  forKey:@"tagId"];
            (resultstring.length >0)?[modal show:resultstring for:1.5]:[modal show:@"Profile Saved!" for:1.5];
        }else
            [modal show:@"Failed" for:1.5];
    }];
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
    [[UINavigationBar appearance] setTintColor:[UIColor clearColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    UIImage *backButton = [[UIImage imageNamed:@"whiteBack"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, -8)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
}

-(IBAction)resetPassword:(id)sender{
    [modal show:@"Loading..."];
    EVUser *user = [[EVUser alloc]init];
    user.email = [[EVUser currentUser] email];
    [user changePassworwithCompletionBlock:^(BOOL success, id result, NSError *error) {
        
        if(success){
            [modal show:@"Success!" for:1.5];
            [[[UIAlertView alloc]initWithTitle:@"Message" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }else
            [modal show:@"Failed" for:1.5];
    }];
}

#pragma UIImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self setBarButton];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_imageProfile setImage:selectedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        [self imageButtonAction];
    }
   /* else if(indexPath.row == 6){
        EVUser *user = [[EVUser alloc]init];
        user.email = [[EVUser currentUser] email];
        [user changePassworwithCompletionBlock:^(BOOL success, id result, NSError *error) {
        
            if(success){
                [[[UIAlertView alloc]initWithTitle:@"Message" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }else {}
        }];
    }*/
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    textView.text=@"";
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(IBAction)resignResponder:(id)sender{
    UITextField *textfield = sender;
    [textfield resignFirstResponder];
}

@end
