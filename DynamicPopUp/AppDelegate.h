//
//  AppDelegate.h
//  DynamicPopUp
//
//  Created by iPatel on 5/27/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "WebService.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

#import "SQLDb.h"

#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, WebServiceDelegate, UITableViewDelegate, UITableViewDataSource>
{
    Reachability* reachability;
    
    CLLocationManager *locationManager;
}


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *strDeviceToken;

@property (strong, nonatomic) WebService *webServiceObject;
@property (strong, nonatomic) UIImageView *imvSplash;

@property (strong, nonatomic) NSString *strForCurrentLat, *strForCurrentLon;

@property (strong, nonatomic) NSMutableDictionary *dictForLabels;

///// NO INTERNET CONNECTION ////
@property (strong, nonatomic) UIView *viewForNoInternet;
@property (strong, nonatomic) UIActivityIndicatorView *spinnerForNoInternet;


///// MENU ////
@property BOOL isEnableSlideMenu;
@property (strong, nonatomic) NSMutableArray *arrMainData;
@property (strong, nonatomic) NSMutableArray *arrMainImages;
@property (strong, nonatomic) UIView *viewMainForSlide;
@property (strong, nonatomic) UIView *slideView;
@property (strong, nonatomic) UIScrollView *scroll;
@property (strong, nonatomic) UITableView *tblView;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRight, *swipeLeft;
@property (nonatomic) NSInteger selectedMenuIndex;
@property (strong, nonatomic) NSMutableArray *arrAddressData;
@property (strong, nonatomic) NSMutableArray *arrOrderData;
@property (strong, nonatomic) NSString *strOrderCounts;

-(void)setupPushNoification;
-(void)getCurrentLocation;

@end

