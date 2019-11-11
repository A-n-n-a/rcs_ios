//
//  EVMyChargerStatusTableViewCell.m
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVMyChargerStatusTableViewCell.h"

@interface EVMyChargerStatusTableViewCell() 

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIStackView *kWhStackView;
@property (weak, nonatomic) IBOutlet UIStackView *amperageStackView;
@property (weak, nonatomic) IBOutlet UIStackView *durationStackView;
@property (weak, nonatomic) IBOutlet UIStackView *costStackView;
@property (weak, nonatomic) IBOutlet UILabel *kWhValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *amperageValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *costValueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBottomConstraint;

@end

@implementation EVMyChargerStatusTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargerUpdated:) name:@"ChargerStatusDidUpdated" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupCell:(NSString *)status {
    self.statusLabel.text = status;
    [self showAdditionalInfo:NO];
    [self.statusBottomConstraint setActive:NO];
    [self.statusBottomConstraint setPriority:1000];
     [self.statusBottomConstraint setActive:YES];
}

- (void)setupCell:(NSString *)status kWh:(NSString *)kWh amperage:(NSString *)amperage duration:(NSString *)duration cost:(NSString *)cost {
    self.statusLabel.text = status;
    self.kWhValueLabel.text = kWh;
    self.amperageValueLabel.text = amperage;
    self.durationValueLabel.text = duration;
    self.costValueLabel.text = cost;
    [self showAdditionalInfo:YES];
    [self.statusBottomConstraint setActive:NO];
    [self.statusBottomConstraint setPriority:1];
    [self.statusBottomConstraint setActive:YES];
}

- (void)showAdditionalInfo:(BOOL)value {
    [self.kWhStackView setHidden:!value];
    [self.amperageStackView setHidden:!value];
    [self.durationStackView setHidden:!value];
    [self.costStackView setHidden:!value];
}

- (void)chargerUpdated:(NSNotification *)notif {
    EVCharger *charger = [notif object];
    if ([self.currentCharger.periferalId isEqualToString:charger.periferalId] &&
        [self.currentCharger.portId isEqualToString:charger.portId]) {

        if (charger.isCharging) {
            self.statusLabel.text = @"Ready";
            [self.statusBottomConstraint setActive:NO];
            [self.statusBottomConstraint setPriority:1000];
            [self.statusBottomConstraint setActive:YES];
            [self showAdditionalInfo:NO];
            [self setNeedsDisplay];
        } else {
            self.statusLabel.text = @"Charging";
            self.kWhValueLabel.text = [NSString stringWithFormat:@"%2.2f",charger.kWH];
            self.amperageValueLabel.text = [NSString stringWithFormat:@"%2.2fA",charger.amperage];
            self.durationValueLabel.text = [NSString stringWithFormat:@"%@",[self fromIntToTimeStr:charger.duration]];
            self.costValueLabel.text = [NSString stringWithFormat:@"$ %2.2f",charger.cost];
            [self.statusBottomConstraint setActive:NO];
            [self.statusBottomConstraint setPriority:1];
            [self.statusBottomConstraint setActive:YES];
            [self showAdditionalInfo:YES];
            [self setNeedsDisplay];
        }
    }
}

- (NSString *)fromIntToTimeStr:(uint32_t)elapsedSeconds {
    NSUInteger h = elapsedSeconds / 3600;
    NSUInteger m = (elapsedSeconds / 60) % 60;
    NSUInteger s = elapsedSeconds % 60;
    
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu", h, m, s];
}

@end
