//
//  EVModal.h
//  EVCompany
//
//  Created by Eric Fontenault on 11/28/16.
//  Copyright © 2016 Srishti. All rights reserved.
//

@interface EVModal : UIView

@property UIActivityIndicatorView* activityIndicator;
@property Boolean isVisible;
@property NSString* message;
@property UILabel* messageLabel;
@property CGFloat activityIndicatorHeight;
@property CGFloat radius;

-(void) show;
-(void) showWithoutSpinner;
-(void) hide;
-(void) show:(NSString *)message;
-(void) show:(NSString *)message for:(CGFloat)duration;
@end
