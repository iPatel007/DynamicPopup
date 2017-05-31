//
//  HomeViewController.m
//  DynamicPopUp
//
//  Created by iPatel on 5/27/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

#pragma mark - viewDidLoad Method - 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Custom Popup";
    
    customPopup = [[iDynamicPopup alloc] init];
    customPopup.frame = [UIScreen mainScreen].bounds;
    customPopup.delegate = self;
    customPopup.backgroundColor = [UIColor clearColor];
    customPopup.isHeaderBGColor = YES;
    customPopup.strLanguageID = @"1";
    [self.view addSubview:customPopup];
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for(int i = 0; i < 10; i ++)
    {
        [list addObject:[NSString stringWithFormat:@"Item %d", i]];
    }
}

#pragma mark - iDynamicPopup Delegate Methods -

-(void)getSelectedItemsIndex:(NSString *) strItemsIndex
{
    NSLog(@"%@", strItemsIndex);
}

#pragma mark - viewWillAppear Method -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - UIButton Action Method -

-(IBAction)clickOnDisplay:(UIButton *)sender
{
    NSLog(@"Isdsdsa");
    [customPopup openDynamicPopupView];
    
}

#pragma mark - Device Orientation Method -

- (BOOL)shouldAutorotate
{
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - didReceiveMemoryWarning Method -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
 //   [customPopup setupFrameBasedOnDeviceOrientation];
   
}

@end
