//
//  EVSlidingViewController.m
//  EVCompany
//
//  Created by Srishti on 19/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVSlidingViewController.h"

@interface EVSlidingViewController ()
@property (nonatomic, strong) UIStoryboard *storyBoard;
@end

@implementation EVSlidingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        


    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"--------------EVSlidingViewController--------------");
    [super viewDidLoad];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    self.shouldAddPanGestureRecognizerToTopViewSnapshot = YES;
     [self setUnderLeftViewController:[storyboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.68 blue:0.27 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
