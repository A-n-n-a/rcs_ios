//
//  EVViewController.h
//  EVCompany
//
//  Created by Anna on 10/12/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVViewController : UIViewController

@property (nonatomic, strong) UIAlertController*     activeAlert;

-(void)back;
-(void)setNavigationBar:(NSString*)leftIconName title:(NSString*)title rightIconName:(NSString*)rightIconName selector:(SEL*)selector rightButtonTitle:(NSString*)rightButtonTitle;
-(void)goTo:(NSString*)viewController;
-(void)goToStoryboard:(NSString*)identifier;
-(void)createButton:(UIView*)view y:(CGFloat)y buttonNumber:(NSInteger)buttonNumber selector:(SEL)selector;
-(void)showAlertWithTextField: (UIViewController*) vc  whithCompletionHandler:(void (^)(BOOL match))handler;
-(void)showCancelAlert: (UIViewController*)vc message:(NSString*)message;
-(void)showOkAlert: (UIViewController*)vc message:(NSString*)message;
-(void)showTwoActionAlert: (UIViewController*)vc message:(NSString*)message;
-(void)hideAlert: (UIAlertController*)alert;
@end

