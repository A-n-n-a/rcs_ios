//
//  EVMyChargerFooterView.m
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVMyChargerFooterView.h"

@interface EVMyChargerFooterView()

@property (weak, nonatomic) IBOutlet UIView *footerBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@end

@implementation EVMyChargerFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI {
    self.footerBackgroundView.layer.cornerRadius = 12.f;
    self.startButton.layer.cornerRadius = 6.f;
    self.startButton.layer.masksToBounds = YES;
    self.stopButton.layer.cornerRadius = 6.f;
    self.stopButton.layer.masksToBounds = YES;
}

- (IBAction)startButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(startButtonClicked:)]) {
        [self.delegate startButtonClicked:self];
    }
}

- (IBAction)stopButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(stopButtonClicked:)]) {
        [self.delegate stopButtonClicked:self];
    }
}


@end
