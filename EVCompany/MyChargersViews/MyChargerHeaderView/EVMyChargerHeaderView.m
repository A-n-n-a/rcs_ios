//
//  EVMyChargerHeaderView.m
//  EVCompany
//
//  Created by Zins on 10/23/17.
//  Copyright © 2017 Srishti. All rights reserved.
//

#import "EVMyChargerHeaderView.h"
#import "EVMyChargerProgressView.h"

@interface EVMyChargerHeaderView()
@property (weak, nonatomic) IBOutlet EVMyChargerProgressView *chargerProgressView;
@property (weak, nonatomic) IBOutlet UILabel *chargerNameLabel;
@property (weak, nonatomic) IBOutlet UIView *chargerBackGroundView;

@end

@implementation EVMyChargerHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chargerUpdated:) name:@"ChargerProgressDidUpdated" object:nil];
    [self setupUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.chargerProgressView.layer.cornerRadius = 12.f;
    self.chargerProgressView.layer.masksToBounds = YES;
    self.chargerBackGroundView.layer.cornerRadius = 6.f;
    self.chargerBackGroundView.layer.masksToBounds = YES;
}

- (void)setupHeaderView:(NSString *)name progress:(float)progress {
    self.chargerNameLabel.text = name;
    [_chargerProgressView setProgress:progress];
}

- (void)chargerUpdated:(NSNotification *)notif {
    EVCharger *charger = [notif object];
    
    if ([self.currentCharger.periferalId isEqualToString:charger.periferalId] &&
        [self.currentCharger.portId isEqualToString:charger.portId]) {
        self.chargerNameLabel.text = charger.name;
        [_chargerProgressView setProgress:charger.status/100.f];
    }
}

@end
