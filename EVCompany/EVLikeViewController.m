//
//  EVEditViewController.m
//  EVCompany
//
//  Created by Srishti on 28/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVLikeViewController.h"
#import "EVSlidingViewController.h"

@interface EVLikeViewController ()
@property(nonatomic,strong)IBOutlet UIWebView *webView;

@end

@implementation EVLikeViewController

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
    NSLog(@"--------------EVLikeViewController--------------");
    [super viewDidLoad];
     [_webView  loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
	// Do any additional setup after loading the view.
}
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
