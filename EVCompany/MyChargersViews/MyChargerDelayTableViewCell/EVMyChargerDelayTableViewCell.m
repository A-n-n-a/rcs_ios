//
//  EVMyChargerDelayTableViewCell.m
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVMyChargerDelayTableViewCell.h"

@interface EVMyChargerDelayTableViewCell() {
    BOOL _isHour1Selected;
    BOOL _isHour2Selected;
    BOOL _isHour3Selected;
    BOOL _isHour4Selected;
}

@property (weak, nonatomic) IBOutlet UIView *mainViewBackground;
@property (weak, nonatomic) IBOutlet UILabel *delayTimerValueLabel;
@property (weak, nonatomic) IBOutlet UIStackView *delayTimerValueStackView;
@property (weak, nonatomic) IBOutlet UIView *hour1View;
@property (weak, nonatomic) IBOutlet UIView *hour2View;
@property (weak, nonatomic) IBOutlet UIView *hour3View;
@property (weak, nonatomic) IBOutlet UIView *hour4View;


@end

@implementation EVMyChargerDelayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI {
    self.mainViewBackground.layer.cornerRadius = 6.f;
    
    self.hour1View.layer.cornerRadius = 6.f;
    self.hour2View.layer.cornerRadius = 6.f;
    self.hour3View.layer.cornerRadius = 6.f;
    self.hour4View.layer.cornerRadius = 6.f;
    
    UITapGestureRecognizer *recoginzerHour1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hour1Tapped:)];
    UITapGestureRecognizer *recoginzerHour2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hour2Tapped:)];
    UITapGestureRecognizer *recoginzerHour3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hour3Tapped:)];
    UITapGestureRecognizer *recoginzerHour4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hour4Tapped:)];
    
    [self.hour1View addGestureRecognizer:recoginzerHour1];
    [self.hour2View addGestureRecognizer:recoginzerHour2];
    [self.hour3View addGestureRecognizer:recoginzerHour3];
    [self.hour4View addGestureRecognizer:recoginzerHour4];
}

- (void)setupCell {
    [self.delayTimerValueLabel setHidden:YES];
    [self.delayTimerValueStackView setHidden:NO];
}

- (void)setupCell:(NSString *)value {
    self.delayTimerValueLabel.text = value;
    [self.delayTimerValueLabel setHidden:NO];
    [self.delayTimerValueStackView setHidden:YES];
}

#pragma mark - Recognizer Actions

- (void)hour1Tapped:(id)sender {
    _isHour1Selected = !_isHour1Selected;
    [self updateHourView:_hour1View selected:_isHour1Selected];
}

- (void)hour2Tapped:(id)sender {
    _isHour2Selected = !_isHour2Selected;
    [self updateHourView:_hour2View selected:_isHour2Selected];
}

- (void)hour3Tapped:(id)sender {
    _isHour3Selected = !_isHour3Selected;
    [self updateHourView:_hour3View selected:_isHour3Selected];
}

- (void)hour4Tapped:(id)sender {
    _isHour4Selected = !_isHour4Selected;
    [self updateHourView:_hour4View selected:_isHour4Selected];
}


- (void)updateHourView:(UIView *)view selected:(BOOL)selected {
    if (!selected) {
        [view setBackgroundColor:[UIColor colorWithRed:209.f/255.f green:210.f/255.f blue:212.f/255.f alpha:1.f]];
    } else {
        [view setBackgroundColor:[UIColor colorWithRed:64.f/255.f green:177.f/255.f blue:79.f/255.f alpha:1.f]];
    }
}

@end
