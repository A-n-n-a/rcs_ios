//
//  EVMyChargerProgressView.m
//  EVCompany
//
//  Created by Zins on 10/24/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVMyChargerProgressView.h"

@interface EVMyChargerProgressView(){
    CGFloat _innerProgress;
}

@property (nonatomic, assign, setter=newProgress:, getter=getProgress) CGFloat progress;

@end

@implementation EVMyChargerProgressView


- (void) drawProgressBar:(CGRect)frame progress:(CGFloat)progress {
    UIColor *greenColor = [UIColor colorWithRed:64.f/255.f green:177.f/255.f blue:79.f/255.f alpha:1.0];
    
    UIBezierPath *progressOutlinePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height) cornerRadius:6];
    [greenColor setStroke];
    [progressOutlinePath setLineWidth:1];
    [progressOutlinePath addClip];
    
    UIBezierPath *progressActivePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1.f, 1.f, progress, frame.size.height) cornerRadius:0.f];
    [greenColor setFill];
    [progressActivePath fill];
}

- (void)setProgress:(CGFloat)progress {
    if (progress > 1.f) {
        _innerProgress = 1.f;
    } else if (progress < 0.f) {
        _innerProgress = 0.f;
    } else {
        _innerProgress = progress;
    }
    [self setNeedsDisplay];
}

- (CGFloat)getProgress {
    return _innerProgress*self.bounds.size.width;
}

- (void)drawRect:(CGRect)rect {
    [self drawProgressBar:rect progress:[self getProgress]];
}


@end
