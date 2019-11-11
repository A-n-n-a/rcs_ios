//
//  EVReservationListViewController.m
//  EVCompany
//
//  Created by GridScape on 2/25/16.
//  Copyright (c) 2016 Srishti. All rights reserved.
//

#import "EVReservationListViewController.h"
#import "EVAllReservationTableViewController.h"
#import "EVOwnReservationTableViewController.h"
#import "EVModal.h"

@interface EVReservationListViewController (){
    NSArray *viewControllersArray;
    UIViewController *currentController;
    EVAllReservationTableViewController *allReservation;
    EVOwnReservationTableViewController *ownReservation;
    EVModal *modal;
}

@end

@implementation EVReservationListViewController

@synthesize segment_outlet,parentView_outlet;
@synthesize currentconnectorid;

- (void)viewDidLoad {
    NSLog(@"--------------EVRservationListViewController--------------");

    self.navigationItem.title = kNAV_TITLE;
    [super viewDidLoad];
    allReservation = [self.storyboard instantiateViewControllerWithIdentifier:@"evAllReservation"];
    allReservation.delegate = self;
    [allReservation setCurrentconnectorid:currentconnectorid];
    [allReservation setCurrentstation:_currentstation];
    [allReservation setCurrentconnctIndex:[NSString stringWithFormat:@"%@",_currentconnctIndex]];
    [allReservation setCurrentStartTime:[NSString stringWithFormat:@"%1@", _currentStartTime]];
    [allReservation setCurrentEndTime:[NSString stringWithFormat:@"%1@", _currentEndTime]];
    
    ownReservation = [self.storyboard instantiateViewControllerWithIdentifier:@"evOwnReservation"];
    ownReservation.delegate = self;
    [ownReservation setCurrentconnectorid:currentconnectorid];
    [ownReservation setCurrentstation:_currentstation];
    [ownReservation setCurrentconnctIndex:[NSString stringWithFormat:@"%@",_currentconnctIndex]];
    [ownReservation setCurrentStartTime:[NSString stringWithFormat:@"%1@", _currentStartTime]];
    [ownReservation setCurrentEndTime:[NSString stringWithFormat:@"%1@", _currentEndTime]];
    
    viewControllersArray =[NSArray arrayWithObjects: allReservation, ownReservation,nil];// Add viewController in Array viewControllers which is declared in .h file as this is used across the scope of this function.
    
    currentController = allReservation;// make view 1 to be the current view. In this there is no view added on ContainerView by default like we did in above example. We add View1 directly on containerView
    allReservation.view.frame = self.view.frame;
    [parentView_outlet addSubview:currentController.view]; // Adding this view as subview on containerView. But remember View and
    
    //[self setBackBarButton];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat modalWidth = 150;
    CGFloat modalHeight = 100;
    modal = [[EVModal alloc] initWithFrame:CGRectMake((screenBounds.size.width - modalWidth)/2, (screenBounds.size.height - modalHeight)/2, modalWidth, modalHeight)];
    [[self view] addSubview:modal];
}

-(void)setBackBarButton{
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(BackButtonClick:)];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
}

- (IBAction)BackButtonClick:(id)sender{
    NSLog(@"back click");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)segmentValueChanged:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    UIViewController *selectedView=nil;
    switch ([segment selectedSegmentIndex])
    {
        case 0: 
            selectedView= [viewControllersArray objectAtIndex:0];
            break;
            
        case 1:
            selectedView= [viewControllersArray objectAtIndex:1];
            break;
            
        default:
            break;
    }
    [currentController.view removeFromSuperview]; // remove Current displaying view from superView
    
    currentController=selectedView; // make selected View to be the current View
    selectedView.view.frame = self.view.frame;
    [parentView_outlet addSubview:selectedView.view];
    
}

-(void)showModalWithMessage:(NSString*)message {
    [modal setMessage: message];
    [modal show];
}

-(void)showModalWithMessage:(NSString*)message forDuration:(CGFloat)duration {
    [modal setMessage: message];
    [modal showWithoutSpinner];
    
    [NSTimer scheduledTimerWithTimeInterval: duration target:modal selector:@selector(hide) userInfo:nil repeats:NO];
}

-(void)hideModal {
    [modal hide];
}


@end
