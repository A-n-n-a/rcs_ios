//
//  EVLogViewController.m
//  EVCompany
//
//  Created by GridScape on 4/26/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import "EVLogViewController.h"

@interface EVLogViewController ()

@end

@implementation EVLogViewController

- (void)viewDidLoad {
    NSLog(@"--------------EVLogViewController--------------");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self displayLog];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)displayLog{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.txt"];
    
    NSError *err = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:logPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&err];
    if (fileContents == nil) {
        NSLog(@"Error reading %@: %@", logPath, err);
    } else {
        _textview.text = fileContents;
    }
    
}

@end
