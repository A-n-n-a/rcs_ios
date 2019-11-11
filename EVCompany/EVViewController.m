//
//  EVViewController.m
//  EVCompany
//
//  Created by Anna on 10/12/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVViewController.h"
#import "ConstantStrings.h"
#import "ECSlidingViewController.h"

@interface EVViewController () {
    
}

@end

@implementation EVViewController : UIViewController


- (void)viewDidLoad{
    NSLog(@"--------------EVViewController--------------");
    [super viewDidLoad];
    
    
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)openMenu {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)setNavigationBar:(NSString*)leftIconName title:(NSString*)title rightIconName:(NSString*)rightIconName selector:(SEL*)selector rightButtonTitle:(NSString*)rightButtonTitle {
    // set left button
    SEL leftSelector;
    UIImage *backButtonImage = [UIImage imageNamed: leftIconName];
    if (leftIconName == backArrow) {
        leftSelector = @selector(back);
    } else {
        leftSelector = @selector(openMenu);
    }
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage: backButtonImage style:UIBarButtonItemStylePlain target:self action: leftSelector];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
    // set title
    if (title != NULL) {
        self.navigationItem.title = title;
    }
    if (rightButtonTitle != NULL) {
        SEL rightSelector;
        rightSelector = ([rightButtonTitle  isEqual: @"Settings"]) ? @selector(openSettings) : nil;
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style: UIBarButtonItemStylePlain target:self action:rightSelector];

        [self.navigationItem setRightBarButtonItem: rightButton];
    }
}

-(void)openSettings {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: settingsViewController];
    [self.navigationController pushViewController:vc animated:YES ];
}

-(void)goTo:(NSString*)viewControllerName {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: viewControllerName];
        [self.navigationController pushViewController:vc animated:YES];
}

-(void)goToStoryboard:(NSString*)identifier {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:identifier bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier: identifier];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)createButton:(UIView*)view y:(CGFloat)y buttonNumber:(NSInteger)buttonNumber selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = buttonNumber;
    
    // button interface
    button.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    button.clipsToBounds = YES;
    [button layer].cornerRadius = 10;
    NSString *number = buttonNumber < 10 ? [NSString stringWithFormat:@"0%ld", (long)buttonNumber ] : [NSString stringWithFormat:@"%ld", (long)buttonNumber];
    [button setTitle:[NSString stringWithFormat:@"Charger name %@", number] forState:UIControlStateNormal];
    
    //button action
    [button addTarget:self action: selector forControlEvents:UIControlEventTouchUpInside];
    //button size
    CGFloat buttonWidth = view.frame.size.width - 20;
    button.frame = CGRectMake(10.0, y, buttonWidth, 70.0);
    
    [view addSubview:button];
}

-(void)showAlertWithTextField: (UIViewController*)vc  whithCompletionHandler:(void (^)(BOOL match))handler {
    UIAlertController * alert = [UIAlertController  alertControllerWithTitle: @"Charger ID"
                                                    message: @"Enter Charger ID Number"
                                                    preferredStyle:UIAlertControllerStyleAlert];
    self.activeAlert = alert;
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter Charger Serial Number";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
        UIAlertAction* ok = [UIAlertAction      actionWithTitle:@"OK"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    NSArray * textfields = alert.textFields;
                                                UITextField * textfield = textfields[0];
                                                    if ([textfield.text  isEqual: @"0001"]) {
                                                        handler(YES);
                                                    } else {
                                                        handler(NO);
                                                    }
        
    }];
    UIAlertAction* cancel = [UIAlertAction  actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                            //Handle cancel action
    }];
    [alert addAction:ok];
    [alert addAction:cancel];

    [vc presentViewController:alert animated:YES completion:nil];
}

-(void)showCancelAlert: (UIViewController*)vc message:(NSString*)message {
    UIAlertController * alert = [UIAlertController  alertControllerWithTitle: message
                                                    message: @""
                                                    preferredStyle:UIAlertControllerStyleAlert];
    self.activeAlert = alert;
    UIAlertAction* cancel = [UIAlertAction  actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action) {
                                                        //Handle cancel action
                                                        if (message == connectUserMessage) {
                                                            //[self showTwoActionAlert: vc :acceptUser]; //just for build purpose
                                                        } else {
                                                            //[self showAlertWithTextField:self];
                                                        }
                                                    }];
    [alert addAction:cancel];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

-(void)showOkAlert: (UIViewController*)vc message:(NSString*)message {
    UIAlertController * alert = [UIAlertController  alertControllerWithTitle: message
                                                    message: @""
                                                    preferredStyle:UIAlertControllerStyleAlert];
    self.activeAlert = alert;
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        if ([message isEqualToString:chargerAddedMessage]) {
                                                            [self goTo:myChargersListViewController];
                                                        }
                                                    }];
    [alert addAction:ok];
    
    [vc presentViewController:alert animated:YES completion:nil];
}
    
-(void)showTwoActionAlert: (UIViewController*)vc message:(NSString*)message {
    UIAlertController * alert = [UIAlertController  alertControllerWithTitle: message
                                                                     message: @""
                                                              preferredStyle:UIAlertControllerStyleAlert];
    self.activeAlert = alert;
    UIAlertAction* ok = [UIAlertAction      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        //TODO: Handle ak action
                                                        if (message == acceptUser) {
                                                            [self showOkAlert:vc message:userAddedMessage]; //just for build purpose
                                                        }
                                                    }];
    UIAlertAction* cancel = [UIAlertAction  actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action) {
                                                        //Handle cancel action
                                                    }];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

-(void)hideAlert: (UIAlertController*)alert {
    [alert dismissViewControllerAnimated:YES completion:nil];
}

@end



