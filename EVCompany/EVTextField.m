//
//  GWTextField.m
//  GWager
//
//  Created by Bilal Saifudeen on 22/01/13.
//  Copyright (c) 2013 SICS. All rights reserved.
//

#import "EVTextField.h"

@implementation EVTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectInset( bounds , 10 , 0 );
}
// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 0 );
}

@end
