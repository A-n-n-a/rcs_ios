//
//  EVModal.m
//  EVCompany
//
//  Created by Eric Fontenault on 11/28/16.
//  Copyright © 2016 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVModal.h"
#import <UIKit/UIKit.h>

@implementation EVModal:UIView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [self buildView];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self buildView];
    
    return self;
}

- (void) buildView
{
    _radius = 5;
    
    self.alpha = 0.0f;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = _radius;
    [self applyShadow];
    
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    
    _activityIndicatorHeight = 40;
    
    CGFloat activityY = self.frame.size.height - _activityIndicatorHeight;
    CGRect activityFrame = CGRectMake((self.frame.size.width - _activityIndicatorHeight) / 2, activityY, _activityIndicatorHeight, _activityIndicatorHeight);
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame: activityFrame];
    [_activityIndicator startAnimating];
    _activityIndicator.color = [UIColor darkGrayColor];
    
    [self addSubview:_messageLabel];
    [self addSubview:_activityIndicator];
}

- (void) show
{
    _activityIndicator.alpha = 1.0;
    if (!self.isVisible) {
        self.isVisible = true;
        [UIView animateWithDuration:0.1 animations:^{
            self.alpha = 1.0f;
        }];
    }
}

- (void) showWithoutSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat bottomPadding = 10;
        CGRect bounds = self.bounds;
        bounds.size.height = self.bounds.size.height - _activityIndicatorHeight + bottomPadding;
        self.bounds = bounds;
        [self applyShadow];
        _activityIndicator.alpha = 0.0;
    });
    
    [self show];
}

- (void) hide
{
    if (self.isVisible) {
        self.isVisible = false;
        [UIView animateWithDuration:0.1 animations:^{
            self.alpha = 0.0f;
        }];
    }
}

- (void) setMessage:(NSString *)message
{
    _messageLabel.text = message;
    
    CGFloat labelSidePadding = 10;
    CGFloat labelTopPadding = 10;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect messageFrame = _messageLabel.frame;
        messageFrame.size.width = self.bounds.size.width - (2 * labelSidePadding);
        messageFrame.origin = CGPointMake((self.bounds.size.width - messageFrame.size.width) / 2, labelTopPadding);
        _messageLabel.frame= messageFrame;
        
        [_messageLabel sizeToFit];
        
        messageFrame = _messageLabel.frame;
        messageFrame.size.width = self.bounds.size.width - (2 * labelSidePadding);
        _messageLabel.frame = messageFrame;
        
        CGFloat newHeight = _messageLabel.frame.size.height + _activityIndicatorHeight + labelTopPadding;
        
        CGRect bounds = self.bounds;
        bounds.size.height = newHeight;
        self.bounds = bounds;
        
        CGRect activityFrame = _activityIndicator.frame;
        activityFrame.origin.y = self.frame.size.height - _activityIndicatorHeight;
        _activityIndicator.frame = activityFrame;
        
        [self applyShadow];
    });
}

-(void)show:(NSString *)message {
    [self setMessage:message];
    [self show];
}

-(void)show:(NSString *)message for:(CGFloat)duration {
    [self setMessage:message];
    [self showWithoutSpinner];
    [NSTimer scheduledTimerWithTimeInterval: duration target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

-(void)applyShadow {
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = _radius;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowOffset = CGSizeMake(1,1);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    
    self.layer.shadowPath = path.CGPath;
}

@end
