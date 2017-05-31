//
//  AppDelegate.m
//  DynamicPopUp
//
//  Created by iPatel on 5/27/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


@synthesize viewMainForSlide, slideView, tblView, swipeLeft, swipeRight, arrMainData, arrMainImages, scroll, selectedMenuIndex, arrAddressData, arrOrderData;


/*
 import Foundation
 import EVReflection
 
 let kUserInfo = "SavedUserInfo"
 let kUserSecurity = "SavedUserSecurity"
 
 //MARK: XMPP Chat
 open class ChatModel: EVObject {
 var type = ""
 var value = ""
 var duration = ""
 var thumb = ""
 public convenience init(type: String = "", value: String = "", duration: String = "", thumb: String = "") {
 self.init()
 self.type = type
 self.value = value
 self.duration = duration
 self.thumb = thumb
 }
 }
 
 class UserData : EVObject {
 var message  = ""
 var status  = ""
 var dev_message = ""
 var data : UserInfo?
 }
 
 class UserInfo : EVObject {
 var user_id = ""
 var email = ""
 var fullname = ""
 var username = ""
 var profilecountry: ProfileCountry?
 var profilestate: ProfileState?
 var profilecity: ProfileCity?
 var phone = ""
 var image = ""
 var address = ""
 var postcode = ""
 var user_subscribe = ""
 var token = ""
 
 func save() {
 let defaults: UserDefaults = UserDefaults.standard
 let data: NSData = NSKeyedArchiver.archivedData(withRootObject: self) as NSData
 defaults.set(data, forKey: kUserInfo)
 defaults.synchronize()
 }
 
 class func savedUser() -> UserInfo? {
 let defaults: UserDefaults = UserDefaults.standard
 let data = defaults.object(forKey: kUserInfo) as? NSData
 if data != nil {
 if let userinfo = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as? UserInfo {
 return userinfo
 }
 else {
 return nil
 }
 }
 return nil
 }
 
 class func clearUser() {
 let defaults: UserDefaults = UserDefaults.standard
 defaults.removeObject(forKey: kUserInfo)
 defaults.synchronize()
 }
 }
 
 class CountyModel: EVObject {
 var status =  ""
 var message = ""
 var data = [CountryList]()
 var dev_message = ""
 }

 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ///IQKeyboardManager.sharedManager().enable = true
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    NSString *strXIBName = @"HomeViewController_iPad";
    if(IS_IPHONE)
        strXIBName = @"HomeViewController";
    
    HomeViewController *homeVC = [[HomeViewController alloc]initWithNibName:strXIBName bundle:nil];
    UINavigationController *mainNavCon = [[UINavigationController alloc] initWithRootViewController:homeVC];
    self.window.rootViewController = mainNavCon;
    
    [self.window makeKeyAndVisible];
    [self setupPushNoificationMY];
    [self setupHUD];

    
    //// NO INTERNET CONNECTION /////
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable)
    {
        [self setupViewforNoInternet];
    }
    else
    {
        //[self performSelector:@selector(checkAppVersion) withObject:nil afterDelay:60];
    }
    //// NO INTERNET CONNECTION /////
    
    //[self createSlideView];
    
    return YES;
}

#pragma mark - MBProgressHUD Methods -

- (void) setupHUD
{
    /// To Change Ring color use setStrokeColor from SVIndefiniteAnimatedView controller
    /// I changed to center in "moveToPoint" method of "SVProgressHUD.h"
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
}


#pragma mark - Manage Push Notification Methods -

- (void) setupPushNoification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    self.strDeviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    self.strDeviceToken = [self.strDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    self.strDeviceToken = [self.strDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    self.strDeviceToken = [self.strDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"strToken- %@", self.strDeviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get device token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    ///////////// Beep Sound //////////
    SystemSoundID soundID;
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef ref = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"iPhonePushNotification.wav", NULL, NULL);
    AudioServicesCreateSystemSoundID(ref, &soundID);
    AudioServicesPlaySystemSound(soundID);
    ///////////// Beep Sound //////////
}


#pragma mark - CLLocationManagerDelegate -

-(void)getCurrentLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [locationManager requestAlwaysAuthorization];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9)
        locationManager.allowsBackgroundLocationUpdates = YES;
    
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    
    ///====Device lattitude longitude====//////
    
    _strForCurrentLat =[NSString stringWithFormat:@"%f",locationManager.location.coordinate.latitude];
    _strForCurrentLon =[NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude];
    
    ///====simulater lattitude longitude====//////
    //        strForCurrentLat = [NSString stringWithFormat:@"%f",23.0300];
    //        strForCurrentLon = [NSString stringWithFormat:@"%f",72.5800];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"Lat = %@ & Lon = %@",_strForCurrentLat,_strForCurrentLon);
    if([_strForCurrentLat  doubleValue]  ==  0 && [_strForCurrentLon doubleValue]  ==  0)
    {
        _strForCurrentLat = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        _strForCurrentLon = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
        
    }
    _strForCurrentLat = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    _strForCurrentLon = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    
    //NSString *str = [NSString stringWithFormat:@"Lat = %@ & Lon = %@",strForCurrentLat, strForCurrentLon];
    //showAlert(AlertTitle, str);
}

#pragma mark - Application New Version Check Methods -

-(void)checkAppVersion
{
    NSString *myAppID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSLog(@"My AppID -> %@", myAppID);
    
    myAppID = @"com.comanyname.appName";
    NSString *striTunesURL = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@",myAppID];
    striTunesURL = [striTunesURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *urlOfApp = [[NSURL alloc] initWithString:striTunesURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlOfApp];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   
                                   NSError* parseError;
                                   NSDictionary *appMetadataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                                   NSArray *resultsArray = (appMetadataDictionary)?[appMetadataDictionary objectForKey:@"results"]:nil;
                                   NSDictionary *resultsDic = [resultsArray firstObject];
                                   if (resultsDic)
                                   {
                                       NSLog(@"===>>> %@", resultsDic);
                                       
                                       // compare version with your apps local version
                                       NSString *iTunesVersion = [resultsDic objectForKey:@"version"];
                                       NSLog(@"===>>>iTunesVersion - %@", iTunesVersion);
                                       
                                       NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)@"CFBundleShortVersionString"];
                                       NSLog(@"===>>>AppVersion - %@", appVersion);
                                       /////
                                       
                                       if (iTunesVersion && [appVersion compare:iTunesVersion] != NSOrderedSame)
                                       {
                                           // new version exists
                                           // inform user new version exists, give option that links to the app store to update your app - see AliSoftware's answer for the app update link
                                           
                                           NSString *strMessage = [NSString stringWithFormat:@"New version %@ is released. \n %@", iTunesVersion, [resultsDic objectForKey:@"releaseNotes"]];
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Update Available" message:strMessage delegate:self cancelButtonTitle:@"Update" otherButtonTitles:@"Dismiss", nil];
                                           alert.tag = 721;
                                           [alert show];
                                       }
                                   }
                               } else
                               {
                                   // error occurred with http(s) request
                                   NSLog(@"error occurred communicating with iTunes");
                                   [SVProgressHUD dismiss];
                               }
                           }];
}


#pragma mark - UIAlertView Delegate Methods -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 721)
    {
        if (buttonIndex == 0)
        {
            NSString *strAPPlink = [NSString stringWithFormat:@"---"]; // iTunes App link
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strAPPlink]];
        }
    }
}

#pragma mark - Manage Push Notification Methods -

- (void) setupPushNoificationMY
{
    UIMutableUserNotificationAction *readAction = [[UIMutableUserNotificationAction alloc] init];
    readAction.identifier = @"READ_IDENTIFIER";
    readAction.title = @"Read";
    readAction.activationMode = UIUserNotificationActivationModeForeground;
    readAction.destructive = NO;
    readAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *ignoreAction = [[UIMutableUserNotificationAction alloc] init];
    ignoreAction.identifier = @"IGNORE_IDENTIFIER";
    ignoreAction.title = @"Ignore";
    ignoreAction.activationMode = UIUserNotificationActivationModeBackground;
    ignoreAction.destructive = NO;
    ignoreAction.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *deleteAction = [[UIMutableUserNotificationAction alloc] init];
    deleteAction.identifier = @"DELETE_IDENTIFIER";
    deleteAction.title = @"Delete";
    deleteAction.activationMode = UIUserNotificationActivationModeForeground;
    deleteAction.destructive = YES;
    deleteAction.authenticationRequired = YES;
    
    UIMutableUserNotificationCategory *messageCategory = [[UIMutableUserNotificationCategory alloc] init];
    messageCategory.identifier = @"MESSAGE_CATEGORY";
    [messageCategory setActions:@[readAction, ignoreAction, deleteAction] forContext:UIUserNotificationActionContextDefault];
    [messageCategory setActions:@[readAction, deleteAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObject:messageCategory];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if(notificationSettings.types != UIUserNotificationTypeNone)
        [application registerForRemoteNotifications];
}

#pragma mark - Reachability NSNotification Methods -

- (void) handleNetworkChange:(NSNotification *)notice
{
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable)
    {
        [self setupViewforNoInternet];
    }
    else
    {
//        UIViewController *topController = ((UINavigationController*)_window.rootViewController).visibleViewController;
//        if([topController isKindOfClass:[ReportVC class]] && !_isCompleteTopicOrReport)
//        {
//            if(reportViewCon.isBtnSmartSafetyClick)
//                [reportViewCon sendRequestForGetTopicList];
//            else
//                [reportViewCon sendRequestForGetReportList];
//        }
//        else if([topController isKindOfClass:[NotificationViewController class]] && !_isCompleteNotification)
//            [notificationVC sendRequestForGetListOfNotification];
//        else if([topController isKindOfClass:[ProfileViewController class]] && !_isCompleteLoadCompany)
//            [profileVC sendRequestForGetCompany];
//        else if([topController isKindOfClass:[CMSViewController class]] && !_isCompleteCMS)
//        {
//            if([cmsVC.strCMSFor isEqualToString:@"About Us"])
//                [cmsVC sendRequestForGetCMSContantWhereCMSId:@"1"];
//            else if([cmsVC.strCMSFor isEqualToString:@"Help & FAQ's"])
//            {
//                if(cmsVC.isHelpOpen)
//                    [cmsVC sendRequestForGetCMSContantWhereCMSId:@"2"];
//                else
//                    [cmsVC sendRequestForGetFAQContant];
//            }
//            else if([cmsVC.strCMSFor isEqualToString:@"Privacy Terms"])
//                [cmsVC sendRequestForGetCMSContantWhereCMSId:@"3"];
//        }
        
        [self hideViewforNoInternet];
    }
}

#pragma mark - No Internet Connection -

-(void) setupViewforNoInternet
{
    if(_viewForNoInternet)
    {
        [_viewForNoInternet removeFromSuperview];
        _viewForNoInternet = nil;
    }
    
    _viewForNoInternet = [[UIView alloc] init];
    _viewForNoInternet.frame = [UIScreen mainScreen].bounds;
    _viewForNoInternet.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgHeaderBG = [[UIImageView alloc] init];
    imgHeaderBG.frame = CGRectMake(-1, 0, _viewForNoInternet.frame.size.width +2, 64);
    imgHeaderBG.image = [UIImage imageNamed:@"toHeaderBG.jpg"];
    [_viewForNoInternet addSubview:imgHeaderBG];
    
    UILabel *lblHeader = [[UILabel alloc] init];
    lblHeader.frame = CGRectMake(0, 16, _viewForNoInternet.frame.size.width, 48);
    lblHeader.font = [UIFont fontWithName:@"Ubuntu" size:19];
    lblHeader.text = @"Network Error";
    lblHeader.textColor = [UIColor blackColor];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [_viewForNoInternet addSubview:lblHeader];
    
    UIImageView *imgSignalImg = [[UIImageView alloc] init];
    imgSignalImg.frame = CGRectMake((_viewForNoInternet.frame.size.width - 80)/2, (_viewForNoInternet.frame.size.height - 180)/2, 80, 80);
    imgSignalImg.image = [UIImage imageNamed:@"signalLost.png"]; //no-connection.png
    [_viewForNoInternet addSubview:imgSignalImg];
    
    UILabel *lblNetMsg1 = [[UILabel alloc] init];
    lblNetMsg1.frame = CGRectMake(10, imgSignalImg.frame.size.height + imgSignalImg.frame.origin.y + 6, _viewForNoInternet.frame.size.width - 20, 25);
    lblNetMsg1.font = [UIFont fontWithName:@"Ubuntu" size:18];
    lblNetMsg1.text = @"No Internet Connection";
    lblNetMsg1.textAlignment = NSTextAlignmentCenter;
    [_viewForNoInternet addSubview:lblNetMsg1];
    
    UILabel *lblNetMsg2 = [[UILabel alloc] init];
    lblNetMsg2.frame = CGRectMake(10, lblNetMsg1.frame.size.height + lblNetMsg1.frame.origin.y + 3, _viewForNoInternet.frame.size.width - 20, 55);
    lblNetMsg2.font = [UIFont fontWithName:@"Ubuntu" size:14];
    lblNetMsg2.numberOfLines = 2;
    lblNetMsg2.text = [NSString stringWithFormat:@"You must connect to a Wi-Fi or cellular data network to use %@", AlertTitle];
    lblNetMsg2.textAlignment = NSTextAlignmentCenter;
    [_viewForNoInternet addSubview:lblNetMsg2];
    
    UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRefresh.frame = CGRectMake((_viewForNoInternet.frame.size.width - 170)/2, _viewForNoInternet.frame.size.height - 100, 170, 40);
    [btnRefresh setBackgroundImage:[UIImage imageNamed:@"button-blank.png"] forState:UIControlStateNormal];
    btnRefresh.titleLabel.font = [UIFont fontWithName:@"Ubuntu" size:15];
    [btnRefresh setTitleColor:[UIColor colorWithRed:247.0/255.0 green:232.0/255.0 blue:74.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [btnRefresh setTitle:@"Tap to Retry" forState:UIControlStateNormal];
    btnRefresh.backgroundColor = [UIColor clearColor];
    [btnRefresh addTarget:self action:@selector(clickOnBtnReFresh:) forControlEvents:UIControlEventTouchUpInside];
    [_viewForNoInternet addSubview:btnRefresh];
    
    _spinnerForNoInternet = [[UIActivityIndicatorView alloc] init];
    _spinnerForNoInternet.frame = CGRectMake(30, 9, 22, 22);
    [_spinnerForNoInternet setColor:[UIColor yellowColor]];
    [btnRefresh addSubview:_spinnerForNoInternet];
    
    [self.window addSubview:_viewForNoInternet];
    [self.window bringSubviewToFront:_viewForNoInternet];
    _viewForNoInternet.layer.zPosition = 1111;
}

-(void) clickOnBtnReFresh:(UIButton *) sender
{
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus != NotReachable)
    {
        [self hideViewforNoInternet];
    }
    
    [_spinnerForNoInternet startAnimating];
    [sender setTitle:@"Wait..." forState:UIControlStateNormal];
    [self performSelector:@selector(waitIsOverForRefreshBtn:) withObject:sender afterDelay:4];
}

-(void) waitIsOverForRefreshBtn:(UIButton *) sender
{
    [sender setTitle:@"Tap to Retry" forState:UIControlStateNormal];
    [_spinnerForNoInternet stopAnimating];
}

-(void) hideViewforNoInternet
{
    [UIView beginAnimations:@"hideViewForNoInternet" context:nil];
    [UIView setAnimationDuration:1.2f];
    _viewForNoInternet.alpha = 0.0;
    self.imvSplash.alpha = 0.0;
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(removeViewforNoInternet) userInfo:nil repeats:NO];
}

-(void) showViewforNoInternet
{
    [UIView beginAnimations:@"showViewforNoInternet" context:nil];
    [UIView setAnimationDuration:1.2f];
    _viewForNoInternet.alpha = 1.0;
    self.imvSplash.alpha = 0.0;
    [UIView commitAnimations];
}

-(void) removeViewforNoInternet
{
    if(_viewForNoInternet)
    {
        [_viewForNoInternet removeFromSuperview];
        _viewForNoInternet = nil;
    }
}

#pragma mark - Create/Manage Slider Menu -

-(void)createSlideView
{
    arrMainData = [[NSMutableArray alloc]initWithObjects:@"Smart Safety", @"Notification", @"Profile", @"About Us", @"Help & FAQ's", @"Privacy Terms", @"Contact Us", nil];
    
    for(UIView *subView in viewMainForSlide.subviews)
        [subView removeFromSuperview];
    [viewMainForSlide removeFromSuperview];
    viewMainForSlide = nil;
    
    for(UIView *subView in slideView.subviews)
        [subView removeFromSuperview];
    [slideView removeFromSuperview];
    slideView = nil;
    
    viewMainForSlide = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewMainForSlide.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.80];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(transperentViewClick)];
    [viewMainForSlide addGestureRecognizer:tap];
    [self.window addSubview:viewMainForSlide];
    viewMainForSlide.alpha = 0;
    
    NSInteger xCordinate = -SCREEN_WIDTH;
    slideView = [[UIView alloc] initWithFrame:CGRectMake(xCordinate, 0, [UIScreen mainScreen].bounds.size.width - ([UIScreen mainScreen].bounds.size.width/3), SCREEN_HEIGHT)];
    slideView.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:232.0/255.0 blue:49.0/255.0 alpha:1.0];
    
    scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT )];
    [slideView addSubview:scroll];
    [self.window addSubview:slideView];
    
    UIImageView *imgLogo = [[UIImageView alloc] init];
    imgLogo.frame = CGRectMake((slideView.frame.size.width - 130)/2, 37, 130, 58);
    imgLogo.image = [UIImage imageNamed:@"memu-logo.png"];
    [slideView addSubview:imgLogo];
    
    tblView = [[UITableView alloc] init];
    tblView.frame = CGRectMake(0, 130, slideView.frame.size.width, ([arrMainData count]*35)+2);
    tblView.backgroundColor = [UIColor clearColor];
    tblView.scrollEnabled = NO;
    [tblView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tblView.dataSource = self;
    tblView.delegate = self;
    [scroll addSubview:tblView];
    
    UIButton *btnLogout = [UIButton buttonWithType: UIButtonTypeCustom];
    if(IS_IPHONE_4_OR_LESS)
        btnLogout.frame = CGRectMake((slideView.frame.size.width - 80)/2, SCREEN_HEIGHT - 100, 80, 80);
    else
        btnLogout.frame = CGRectMake((slideView.frame.size.width - 80)/2, SCREEN_HEIGHT - 150, 80, 80);
    [btnLogout setImage:[UIImage imageNamed:@"logout.png"] forState:UIControlStateNormal];
    [btnLogout addTarget:self action:@selector(clickOnLogOutButton:) forControlEvents:UIControlEventTouchUpInside];
    [slideView addSubview:btnLogout];
    
    
    
    UILabel *lblHeader = [[UILabel alloc] init];
    lblHeader.frame = CGRectMake((slideView.frame.size.width - 100)/2, btnLogout.frame.origin.y + 54, 100, 30);
    lblHeader.font = [UIFont fontWithName:@"Ubuntu" size:14];
    lblHeader.text = @"Logout";
    lblHeader.textColor = [UIColor blackColor];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [slideView addSubview:lblHeader];
    
    [self sideMenuEnabled:YES];
    
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    scroll.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [self handleRightSwipe];
}

-(void)clickOnLogOutButton:(UIButton *) sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:AlertTitle message:@"Are you sure want to logout ?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 1;
    [alert show];
}

-(void) transperentViewClick
{
    [self handleLeftSwipe];
}

-(void)handleLeftSwipe
{
    [self.window endEditing:YES];
    
    float xCordinateOpen, xCordinateClose;
    
    xCordinateOpen = 0;
    xCordinateClose = -SCREEN_WIDTH;
    
    
    [UIView animateWithDuration:0.12 animations:^{
        slideView.frame = CGRectMake(xCordinateOpen, 0, [UIScreen mainScreen].bounds.size.width - 50, SCREEN_HEIGHT);
        tblView.frame = CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, slideView.frame.size.width, tblView.frame.size.height);
    }completion:^(BOOL finished){
        
        [UIView animateWithDuration:0.40 animations:^{
            slideView.frame = CGRectMake(xCordinateClose, 0, [UIScreen mainScreen].bounds.size.width - 50, SCREEN_HEIGHT);
            tblView.frame = CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, slideView.frame.size.width, tblView.frame.size.height);
            viewMainForSlide.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                    withAnimation:UIStatusBarAnimationFade];
        }];
    }];
    
    [self.window bringSubviewToFront:slideView];
    swipeLeft.enabled = false;
    swipeRight.enabled = true;
    [tblView reloadData];
}

-(void)handleRightSwipe
{
    if(!_isEnableSlideMenu)
        return;
    
    [self.window endEditing:YES];
    
    float xCordinateOpen, xCordinateClose;
    
    xCordinateOpen = 0;
    xCordinateClose = -SCREEN_WIDTH;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.12 animations:^{
        slideView.frame = CGRectMake(xCordinateClose, 0, [UIScreen mainScreen].bounds.size.width - 50, SCREEN_HEIGHT);
        tblView.frame = CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, slideView.frame.size.width, tblView.frame.size.height);
        
        
    }completion:^(BOOL finished){
        
        [UIView animateWithDuration:0.40 animations:^{
            slideView.frame = CGRectMake(xCordinateOpen, 0, [UIScreen mainScreen].bounds.size.width - ([UIScreen mainScreen].bounds.size.width/3), SCREEN_HEIGHT);
            tblView.frame = CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, slideView.frame.size.width, tblView.frame.size.height);
            
            viewMainForSlide.alpha = 1;
        }];
    }
     ];
    
    swipeLeft.enabled = true;
    swipeRight.enabled = false;
    [tblView reloadData];
    
    [self.window bringSubviewToFront:viewMainForSlide];
    [self.window bringSubviewToFront:slideView];
}

-(void) hideShowMenu
{
    [self.window endEditing:YES];
    if (swipeRight.enabled)
        [self handleRightSwipe];
    else
        [self handleLeftSwipe];
}

-(void)sideMenuEnabled : (BOOL)enabled
{
    if (enabled)
    {
        swipeLeft.enabled = NO;
        swipeRight.enabled = YES;
    }
    else
    {
        swipeLeft.enabled = NO;
        swipeRight.enabled = NO;
    }
}

#pragma mark - UIApplication Delegate Methods -

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
