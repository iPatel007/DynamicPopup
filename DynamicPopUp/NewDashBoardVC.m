//
//  NewDashBoardVC.m
//  Ticket Alert
//
//  Created by iPatel on 29/06/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import "NewDashBoardVC.h"
#import "myAnnotation.h"
#import "GeneralClass.h"

#import "AFHTTPRequestOperationManager.h"


@interface NewDashBoardVC ()

@end

@implementation NewDashBoardVC

#pragma mark - viewDidLoad -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImageView *header = [[UIImageView alloc]initWithFrame:CGRectMake(-10, -10, SCREEN_WIDTH + 20 , 84)];
    header.image = [UIImage imageNamed:@"header.png"];
    [self.view addSubview:header];
    
    lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, SCREEN_WIDTH, 30)];
    lblHeader.textColor = [UIColor whiteColor];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    lblHeader.text = @"App Name";
    lblHeader.font = [UIFont fontWithName:@"SFUIText-Regular" size:18.0];
    [self.view addSubview:lblHeader];
    
    UIButton *btnLanguage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLanguage.frame = CGRectMake(0, 0, 64, 64);
    [btnLanguage setImage:[UIImage imageNamed:@"language.png"] forState:UIControlStateNormal];
    [btnLanguage setImageEdgeInsets:UIEdgeInsetsMake(18.0, 0, 0, 20.0)];
    [btnLanguage addTarget:self action:@selector(languageClick:) forControlEvents:UIControlEventTouchUpInside];
   // [self.view addSubview:btnLanguage];
    
    UIButton *btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMenu.frame = CGRectMake(SCREEN_WIDTH - 64, 0, 64, 64);
    [btnMenu setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [btnMenu setImageEdgeInsets:UIEdgeInsetsMake(18.0, 20.0, 0, 0)];
    [btnMenu addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnMenu];
    
    mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 113)];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    [mapView setClipsToBounds:YES];
    
    UIButton *btnPlus = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPlus.frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 74 - 35 , 35 , 35);
    [btnPlus setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [btnPlus addTarget:self action:@selector(plusClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPlus];
    
    viewPopUpContainer.layer.cornerRadius = 5.0;
    viewPopUpContainer.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupConfirmedAndDecinePOAPopUp];
    [self setupPickerView];
    
    _countDownView = [[[NSBundle mainBundle] loadNibNamed:@"CountDownView" owner:nil options:nil] objectAtIndex:0];
    _countDownView.frame = CGRectMake(0, 70, [UIScreen mainScreen].bounds.size.width, _countDownView.frame.size.height);
    [self.view addSubview:_countDownView];
    [_countDownView.btnChangeTimer addTarget:self action:@selector(clickOnButtonForChangeTime:) forControlEvents:UIControlEventTouchUpInside];
    _countDownView.hidden = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CLLocationCoordinate2D centerCoord;
    if([[defaults objectForKey:@"refLatitude"] doubleValue] > 0 || [defaults objectForKey:@"timerDate"] != nil)
    {
        centerCoord.latitude = [[defaults objectForKey:@"refLatitude"] doubleValue];
        centerCoord.longitude = [[defaults objectForKey:@"refLongitude"] doubleValue];
    }
    else
    {
        centerCoord.latitude = [APP_DELEGATE.strForCurrentLat doubleValue];
        centerCoord.longitude = [APP_DELEGATE.strForCurrentLon doubleValue];
    }
    
    myAnnotation *myCustomAnn = [[myAnnotation alloc] initWithCoordinate:centerCoord];
    myCustomAnn.strTitle = @"-1";
    NSMutableDictionary *temDic = [[NSMutableDictionary alloc] init];
    [temDic setObject:@"-1" forKey:@"poa_id"];
    myCustomAnn.pinDic = (NSMutableDictionary *)temDic;
    [mapView addAnnotation:myCustomAnn];
}

#pragma mark - viewWillAppear -

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if(![CLLocationManager locationServicesEnabled])
    {
        NSString *strLocationAlert = [NSString stringWithFormat:@"Turn On Location Services to Allow \"%@\" to Determine Your Location", AlertTitle];
        UIAlertView   *alert = [[UIAlertView alloc] initWithTitle:strLocationAlert message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        alert.tag = 101;
        [alert show];
        
        return;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView   *alert = [[UIAlertView alloc] initWithTitle:AlertTitle message:@"Must Need to Change Allow Location Access \"Never\" to \"Always\"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 102;
        [alert show];
        
        return;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [APP_DELEGATE getCurrentLocation];
        
        return;
    }

    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"timerDate"] != nil)
    {
        _countDownView.hidden = NO;
        
        [self countDownTimerStart];
        if (!countDownTimer)
            countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownTimerStart) userInfo:nil repeats:YES];
    }
    else {
        _countDownView.hidden = YES;
        if ([countDownTimer isValid])
            [countDownTimer invalidate];
        countDownTimer = nil;
    }
    
    [_datePicker addTarget:self action:@selector(dateChangedEvent)
     forControlEvents:UIControlEventValueChanged];
}

-(void)clickOnButtonForChangeTime:(UIButton *) sender
{
    [self performSelector:@selector(openPickerView) withObject:nil afterDelay:.10];
}

-(void)dateChangedEvent
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSLog(@"%@", [dateFormat stringFromDate:self.datePicker.date]);
//    if([[dateFormat stringFromDate:self.datePicker.date] isEqualToString:@"00:00"])
//    {
//        NSDate *now = self.datePicker.date;
//        int daysToAdd = 1;
//        NSDate *minimumDate = [now dateByAddingTimeInterval:60*daysToAdd];
//        [self.datePicker setTimeZone:[NSTimeZone localTimeZone]];
//        self.datePicker.minimumDate = minimumDate;
//        [self.datePicker setDate:now];
//        
//        [self.datePicker reloadInputViews];
//        
//        lblOnDatePicker.text = @"00:01";
//    }
//    else
        lblOnDatePicker.text = [dateFormat stringFromDate:self.datePicker.date];
    
//    NSDateComponents *components;
//    NSInteger hours;
//    NSInteger minutes;
//    
//    components = [[NSCalendar currentCalendar] components: NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date] toDate:_datePicker.date options: 0];
//    
//    hours = [components hour];
//    minutes = [components minute];
//    
//    if(hours <= 0)hours=0; if(minutes <= 0)minutes=0;
//
//    lblOnDatePicker.text =[NSString stringWithFormat:@"%@:%@", (hours < 10)?[NSString stringWithFormat:@"0%ld", (long)hours]:[NSString stringWithFormat:@"%ld", (long)hours], (minutes < 10)?[NSString stringWithFormat:@"0%ld", (long)minutes]:[NSString stringWithFormat:@"%ld", (long)minutes]];
}


-(void) countDownTimerStart
{
    NSDate *endDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"timerDate"];
    NSDate *sDate = [NSDate date];
    [self remaningTime:sDate endDate:endDate];
}

-(void)remaningTime:(NSDate*)sDate endDate:(NSDate*)endDate
{
    NSDateComponents *components;
    NSInteger hours;
    NSInteger minutes;
    NSInteger secounds;
    
    components = [[NSCalendar currentCalendar] components: NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:sDate toDate:endDate options: 0];
    
    hours = [components hour];
    minutes = [components minute];
    secounds = [components second];
    
    if(hours < 10)
        _countDownView.lblHours.text = [NSString stringWithFormat:@"0%ld", (long)hours];
    else
        _countDownView.lblHours.text = [NSString stringWithFormat:@"%ld", (long)hours];
    
    if(minutes < 10)
        _countDownView.lblMinutes.text = [NSString stringWithFormat:@"0%ld", (long)minutes];
    else
        _countDownView.lblMinutes.text = [NSString stringWithFormat:@"%ld", (long)minutes];
    
    if(secounds < 10)
        _countDownView.lblSecounds.text = [NSString stringWithFormat:@"0%ld", (long)secounds];
    else
        _countDownView.lblSecounds.text = [NSString stringWithFormat:@"%ld", (long)secounds];
    
    
    _countDownView.hidden = NO;
    
    if(hours <= 0 && minutes <= 0 && secounds <= 0)
    {
        _countDownView.hidden = YES;
        if ([countDownTimer isValid])
            [countDownTimer invalidate];
        countDownTimer = nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"timerDate"];
        [defaults synchronize];
    }
}

#pragma mark - viewDidAppear -

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    [self ceratePopUpView];
    [SVProgressHUD dismiss];
    
    [self performSelector:@selector(zoomToFitMapAnnotations:) withObject:mapView afterDelay:1];
}

-(void) setRegionWhenDisplayAdMob
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([mapView.userLocation coordinate], 1500000, 1500000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:NO];
    
    [self performSelector:@selector(zoomToFitMapAnnotations:) withObject:mapView afterDelay:2];
}

#pragma mark - TextField Delegate -

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    NSLog(@"%@", arrForIncidenceOrCategory);
    
    if (textField == txtIncidenceOrCategory && arrForIncidenceOrCategory.count > 0)
        [self addToolBatOnTopOfTextField:textField];
    else
        [txtIncidenceOrCategory resignFirstResponder];
}

#pragma mark - TextView Delegate -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    activeTextField = (UITextField *) textView;
    [self addToolBatOnTopOfTextField:activeTextField];
    if ([txtView.text isEqualToString:@"messgae"])
        txtView.text = @"";
    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedString length] <= 0)
        txtView.text = @"messgae";
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([txtView.text length] == 0)
        txtView.text = @"messgae";
    
    return YES;
}

- (void)textViewDidChange:(UITextView *) textView
{
    [self setFramOfTextViewBaseOnContent:textView];
    if(textView.frame.size.height > 80)
        [self setFrameBaseOnMessageContent];
}

#pragma mark - Custom Methods -

-(void)reloadDashBoardScreenForSetLabels
{
    NSLog(@"Labels are set for screen");
    
    txtView.text = [APP_DELEGATE.dictForLabels objectForKey:@"message"];
    txtIncidenceOrCategory.placeholder = [APP_DELEGATE.dictForLabels objectForKey:@"incidence"];
    [btnAlert setTitle:[APP_DELEGATE.dictForLabels objectForKey:@"alert"] forState:UIControlStateNormal];

    
//    if(APP_DELEGATE.strForCurrentLat == nil || [APP_DELEGATE.strForCurrentLat length] == 0)
//    {
//        CLLocationCoordinate2D centerCoord;
//        centerCoord.latitude = [APP_DELEGATE.strForCurrentLat doubleValue];
//        centerCoord.longitude = [APP_DELEGATE.strForCurrentLon doubleValue];
//        
//        myAnnotation *myCustomAnn = [[myAnnotation alloc] initWithCoordinate:centerCoord];
//        myCustomAnn.strTitle = @"-1";
//        NSMutableDictionary *temDic = [[NSMutableDictionary alloc] init];
//        [temDic setObject:@"-1" forKey:@"poa_id"];
//        myCustomAnn.pinDic = (NSMutableDictionary *)temDic;
//        [mapView addAnnotation:myCustomAnn];
//    }
    
    if(!isAPIRunning)
        [self callWebserviceForAlertListingwithHudStatus:1];
}

-(void) openAlertForsetNotification
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"appname"]
                                                                   message:[APP_DELEGATE.dictForLabels objectForKey:@"setTimer"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"no"]
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           NSLog(@"You pressed button No");
                                                       }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"yes"]
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                                                            
                                                            //isDragdrop = TRUE;
                                                            [self performSelector:@selector(openPickerView) withObject:nil afterDelay:.10];
                                                        }];
    [alert addAction:noAction];
    [alert addAction:yesAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    });
}

-(void) setupPickerView
{
    self.customPikerView = [[UIView alloc] init];
    if(IS_HEIGHT_GTE_568)
        self.customPikerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 88, [UIScreen mainScreen].bounds.size.width, 216);
    else
        self.customPikerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 216);
    self.customPikerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.customPikerView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    UIImageView *img = [[UIImageView alloc]initWithFrame:toolbar.frame];
    img.backgroundColor = [UIColor colorWithRed:9.0/255.0 green:57.0/255.0 blue:83.0/255.0 alpha:1.0];
    [toolbar addSubview:img];
    [toolbar sizeToFit];
    
    lblOnDatePicker = [[UILabel alloc] initWithFrame:toolbar.frame];
    lblOnDatePicker.textAlignment = NSTextAlignmentCenter;
    lblOnDatePicker.font = [UIFont systemFontOfSize:17.0];
    lblOnDatePicker.textColor = [UIColor whiteColor];
    [toolbar addSubview:lblOnDatePicker];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(closePickerView)];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"done"] style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneBtnTapped)];
    
    [doneButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]
                                         } forState:UIControlStateNormal];
    
    [cancelButton setTitleTextAttributes:@{
                                           NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                           NSForegroundColorAttributeName: [UIColor whiteColor]
                                           } forState:UIControlStateNormal];
    NSArray *itemsArray = [NSArray arrayWithObjects: cancelButton, flexButton, doneButton, nil];
    [toolbar setItems:itemsArray];
    
    [self.customPikerView addSubview:toolbar];
    
    
    self.datePicker= [[UIDatePicker alloc]init];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.frame = CGRectMake(0.0, 44.0, [UIScreen mainScreen].bounds.size.width, 216);
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    [self.datePicker setLocale:locale];
    [self.customPikerView addSubview:self.datePicker];
    
    NSString *strTime = @"00:01";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSLog(@"%@", [dateFormat dateFromString:strTime]);
    [self.datePicker setDate:[dateFormat dateFromString:strTime]];
    
    [self.view bringSubviewToFront:self.customPikerView];
}

- (void) openPickerView
{
    if(activeTextField.isFirstResponder)
        [activeTextField resignFirstResponder];
    if(txtView.isFirstResponder)
        [txtView resignFirstResponder];
    
//    NSDate *now = [NSDate date];
//    int daysToAdd = 1;
//    NSDate *minimumDate = [now dateByAddingTimeInterval:60*daysToAdd];
//    [self.datePicker setTimeZone:[NSTimeZone localTimeZone]];
    //self.datePicker.minimumDate = minimumDate;
    //[self.datePicker setDate:now];
    
  //  [self.datePicker reloadInputViews];

    [UIView animateWithDuration:0.40 animations:^{
        self.customPikerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 260, [UIScreen mainScreen].bounds.size.width, 216);
    }];
    
    [self dateChangedEvent];
}

-(void) pickerDoneBtnTapped
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications]; // Canceling all local notification.
    
    NSArray *temArr = [lblOnDatePicker.text componentsSeparatedByString:@":"];
    int hourSec = (60 * 60)*[[temArr objectAtIndex:0] intValue];
    int minSec = 60*[[temArr objectAtIndex:1] intValue];
    NSDate *date = [NSDate date];
    NSDate *finalFireDate = [date dateByAddingTimeInterval:hourSec+minSec+1];
    
    [self closePickerView];
    if(hourSec <= 0 && minSec <= 0)
    {
        _countDownView.hidden = YES;
        if ([countDownTimer isValid])
            [countDownTimer invalidate];
        countDownTimer = nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"timerDate"];
        [defaults synchronize];
        return;
    }
    NSLog(@"%d X %d = %d",hourSec,minSec, hourSec+minSec+1);
    
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = finalFireDate;
    notification.alertBody = [APP_DELEGATE.dictForLabels objectForKey:@"finishTimer"];
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:finalFireDate forKey:@"timerDate"];
    [defaults synchronize];
    
    [self countDownTimerStart];
    
    if (!countDownTimer)
        countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownTimerStart) userInfo:nil repeats:YES];
}

- (void) closePickerView
{
    [UIView animateWithDuration:0.35 animations:^{
        self.customPikerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 216);
    }];
}

- (void) ceratePopUpView
{
    if (viewPopUp)
    {
        for (UIView *subView in viewPopUp.subviews)
            [subView removeFromSuperview];
        [viewPopUp removeFromSuperview];
        viewPopUp = nil;
    }
    if(arrForIncidenceOrCategory.count)
        [arrForIncidenceOrCategory removeAllObjects];
    
    viewPopUp = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [viewPopUp setHidden:YES];
    viewPopUp.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.75];
    
    scrollPopUp = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:viewPopUp.bounds];
    
    viewPopUpInner = [[UIView alloc]initWithFrame:scrollPopUp.frame];
    viewPopUpContainer = [[UIView alloc]initWithFrame:CGRectMake(26, (viewPopUpInner.frame.size.height / 2) - 160, viewPopUpInner.frame.size.width - 52, 320)];
    viewPopUpContainer.backgroundColor = [UIColor whiteColor];
    scrollPopUp.contentSize = CGSizeMake(SCREEN_WIDTH, viewPopUpContainer.frame.origin.y  + viewPopUpContainer.frame.size.height + 1);
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = CGRectMake(viewPopUpInner.frame.size.width - 46, (viewPopUpContainer.frame.origin.y - 23), 46, 46);
    [btnClose setImage:[UIImage imageNamed:@"popup-close.png"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnForHeaderTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    btnForHeaderTitle.frame = CGRectMake(-1, -1, viewPopUpContainer.frame.size.width + 2, 36);
    [btnForHeaderTitle setBackgroundImage:[UIImage imageNamed:@"header.png"] forState:UIControlStateNormal];
    [btnForHeaderTitle setTitle:[APP_DELEGATE.dictForLabels objectForKey:@"add_new_alert"] forState:UIControlStateNormal];
    [btnForHeaderTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnForHeaderTitle.titleLabel setFont:[UIFont fontWithName:@"SFUIText-Regular" size:12.0]];
    
    UIImageView *imgView1 = [[UIImageView alloc]initWithFrame:CGRectMake(31, 70, 14, 12)];
    imgView1.image = [UIImage imageNamed:@"incidence-cat.png"];
    UIImageView *imgLine1 = [[UIImageView alloc]initWithFrame:CGRectMake(24, 93, viewPopUpContainer.frame.size.width - 24, 1)];
    imgLine1.image = [UIImage imageNamed:@"popup-separater.png"];
    UIImageView *imgDown1 = [[UIImageView alloc]initWithFrame:CGRectMake(viewPopUpContainer.frame.size.width - 14 - 9, 73, 9, 5)];
    imgDown1.image = [UIImage imageNamed:@"drop-down.png"];
    
    txtIncidenceOrCategory = [[UITextField alloc]initWithFrame:CGRectMake(imgView1.frame.origin.x + imgView1.frame.size.width + 15, 58, imgDown1.frame.origin.x - 8 - (imgView1.frame.origin.x + imgView1.frame.size.width + 15), 35)];
    txtIncidenceOrCategory.placeholder = [APP_DELEGATE.dictForLabels objectForKey:@"incidence"];
    txtIncidenceOrCategory.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0];
    txtIncidenceOrCategory.tintColor = [UIColor clearColor];
    txtIncidenceOrCategory.delegate = self;
    [txtIncidenceOrCategory addTarget:self action:@selector(txtOpenPicker:) forControlEvents:UIControlEventEditingDidBegin];
    [txtIncidenceOrCategory endEditing:NO];

    [GeneralClass setTextFieldPlaceHolderColor:txtIncidenceOrCategory];
    
    UIImageView *imgView2 = [[UIImageView alloc]initWithFrame:CGRectMake(31, 121, 14, 14)];
    imgView2.image = [UIImage imageNamed:@"time.png"];
    
    UIImageView *imgLine2 = [[UIImageView alloc]initWithFrame:CGRectMake(24, 145, viewPopUpContainer.frame.size.width - 24, 1)];
    imgLine2.image = [UIImage imageNamed:@"popup-separater.png"];
    UIImageView *imgDown2 = [[UIImageView alloc]initWithFrame:CGRectMake(viewPopUpContainer.frame.size.width - 14 - 9, 125, 9, 5)];
    imgDown2.image = [UIImage imageNamed:@"drop-down.png"];
    
    lblServerTime = [[UILabel alloc]initWithFrame:CGRectMake(imgView2.frame.origin.x + imgView2.frame.size.width + 15, 110, 250, 35)];
    lblServerTime.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0];
    [viewPopUpContainer addSubview:lblServerTime];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //
    [dateFormat setDateFormat:@"hh:mm a"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    lblServerTime.text = [dateFormat stringFromDate:[NSDate date]];
    
    UIImageView *imgView3 = [[UIImageView alloc]initWithFrame:CGRectMake(31, 173, 14, 13)];
    imgView3.image = [UIImage imageNamed:@"message.png"];
    txtView = [[UITextView alloc]initWithFrame:CGRectMake(imgView3.frame.origin.x + imgView3.frame.size.width + 10, 162, viewPopUpContainer.frame.size.width - 17 - (imgView3.frame.origin.x + imgView3.frame.size.width + 10), 80)];
    txtView.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0];
    txtView.text = [APP_DELEGATE.dictForLabels objectForKey:@"message"];
    txtView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [txtView setSpellCheckingType:UITextSpellCheckingTypeNo];
    [txtView setAutocorrectionType:UITextAutocorrectionTypeNo];
    txtView.delegate = self;
    
    imgBottomTextViewLine = [[UIImageView alloc]initWithFrame:CGRectMake(24, txtView.frame.origin.y + txtView.frame.size.height , viewPopUpContainer.frame.size.width - 24, 1)];
    imgBottomTextViewLine.image = [UIImage imageNamed:@"popup-separater.png"];
    
    btnAlert = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAlert.frame = CGRectMake(30, imgBottomTextViewLine.frame.origin.y + imgBottomTextViewLine.frame.size.height + 20, viewPopUpContainer.frame.size.width - 60, 35);
    [btnAlert setBackgroundImage:[UIImage imageNamed:@"popup-button.png"] forState:UIControlStateNormal];
    [btnAlert setTitle:[APP_DELEGATE.dictForLabels objectForKey:@"alert"] forState:UIControlStateNormal];
    [btnAlert.titleLabel setFont:[UIFont fontWithName:@"SFUIText-Regular" size:14.0]];
    [btnAlert setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)];
    [btnAlert addTarget:self action:@selector(alertClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [APP_DELEGATE.window addSubview:viewPopUp];
    [viewPopUp addSubview:scrollPopUp];
    [scrollPopUp addSubview:viewPopUpInner];
    [viewPopUpInner addSubview:viewPopUpContainer];
    
    [viewPopUpInner addSubview:btnClose];
    [viewPopUpContainer addSubview:btnForHeaderTitle];
    [viewPopUpContainer addSubview:imgView1];
    [viewPopUpContainer addSubview:imgLine1];
    [viewPopUpContainer addSubview:imgDown1];
    [viewPopUpContainer addSubview:txtIncidenceOrCategory];
    
    [viewPopUpContainer addSubview:imgView2];
    [viewPopUpContainer addSubview:imgLine2];
    //[viewPopUpContainer addSubview:imgDown2];
    
    [viewPopUpContainer addSubview:imgView3];
    [viewPopUpContainer addSubview:txtView];
    [viewPopUpContainer addSubview:imgBottomTextViewLine];
    [viewPopUpContainer addSubview:btnAlert];
    
    [GeneralClass openPopUpViewWhereDimView:viewPopUp andInerView:viewPopUpInner];
}

-(void)txtOpenPicker:(UITextField *)textField
{
    if(arrForIncidenceOrCategory.count == 0)
        [self callWebserviceForGetCategory];
    else
    {
        if(viewPicker)
        {
            [viewPicker removeFromSuperview];
            viewPicker = nil;
        }
        
        viewPicker = [[UIPickerView alloc] init];
        [viewPicker setDataSource: self];
        [viewPicker setDelegate: self];
        viewPicker.showsSelectionIndicator = YES;
        [viewPicker selectRow:selectedIncidenceOrCategory inComponent:0 animated:YES];
        txtIncidenceOrCategory.inputView = viewPicker;
        txtIncidenceOrCategory.inputView.backgroundColor = [UIColor whiteColor];
        [txtIncidenceOrCategory becomeFirstResponder];
    }
    [viewPicker performSelector:@selector(reloadAllComponents) withObject:nil afterDelay:.1];
}

-(void) addToolBatOnTopOfTextField:(UITextField *) textField
{
    activeTextField = textField;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    UIImageView *img = [[UIImageView alloc]initWithFrame:toolbar.frame];
    img.backgroundColor = [UIColor colorWithRed:9.0/255.0 green:57.0/255.0 blue:83.0/255.0 alpha:1.0];
    [toolbar addSubview:img];
    
    [toolbar sizeToFit];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"cancel"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelBtnTappedForResignKeyboard)];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"done"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(donBtnTappedForResignKeyboard)];
    
    [doneButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]
                                         } forState:UIControlStateNormal];
    
    [cancelButton setTitleTextAttributes:@{
                                           NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                           NSForegroundColorAttributeName: [UIColor whiteColor]
                                           } forState:UIControlStateNormal];
    NSArray *itemsArray = [NSArray arrayWithObjects: cancelButton, flexButton, doneButton, nil];
    
    [toolbar setItems:itemsArray];
    [textField setInputAccessoryView:toolbar];
}

-(void)donBtnTappedForResignKeyboard
{
    if (activeTextField == txtIncidenceOrCategory)
        txtIncidenceOrCategory.text = [[arrForIncidenceOrCategory objectAtIndex:selectedIncidenceOrCategory] valueForKey:@"category_name"];
    
    if(activeTextField.isFirstResponder)
        [activeTextField resignFirstResponder];
    if(txtView.isFirstResponder)
        [txtView resignFirstResponder];
}

-(void) cancelBtnTappedForResignKeyboard
{
    if(activeTextField.isFirstResponder)
        [activeTextField resignFirstResponder];
    if(txtView.isFirstResponder)
        [txtView resignFirstResponder];;
}

-(void) setFrameBaseOnMessageContent
{
    imgBottomTextViewLine.frame = CGRectMake(imgBottomTextViewLine.frame.origin.x, (txtView.frame.origin.y + txtView.frame.size.height) , imgBottomTextViewLine.frame.size.width, imgBottomTextViewLine.frame.size.height);
    btnAlert.frame = CGRectMake(btnAlert.frame.origin.x, imgBottomTextViewLine.frame.origin.y + imgBottomTextViewLine.frame.size.height + 20, btnAlert.frame.size.width, btnAlert.frame.size.height);
    
    viewPopUpContainer.frame = CGRectMake(viewPopUpContainer.frame.origin.x, viewPopUpContainer.frame.origin.y, viewPopUpContainer.frame.size.width, (btnAlert.frame.origin.y + btnAlert.frame.size.height) + 20);
    viewPopUpInner.frame = CGRectMake(viewPopUpInner.frame.origin.x, viewPopUpInner.frame.origin.y, viewPopUpInner.frame.size.width, (viewPopUpContainer.frame.origin.y + viewPopUpContainer.frame.size.height) + 20);
    scrollPopUp.contentSize = CGSizeMake(SCREEN_WIDTH, viewPopUpContainer.frame.origin.y  + viewPopUpContainer.frame.size.height + 5);
}

-(void) setFramOfTextViewBaseOnContent:(UITextView *) textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
}

-(void) setupConfirmedAndDecinePOAPopUp
{
//    if(confrimPOAview)
//    {
//        for(UIView *subView in confrimPOAview.subviews)
//            [subView removeFromSuperview];
//        [confrimPOAview removeFromSuperview];
//        confrimPOAview = nil;
//    }
//    
//    confrimPOAview = [[[NSBundle mainBundle] loadNibNamed:@"ConfirmedPOAView" owner:nil options:nil] objectAtIndex:0];
//    [APP_DELEGATE.window addSubview:confrimPOAview];
//    [APP_DELEGATE.window bringSubviewToFront:confrimPOAview];
//    
//    confrimPOAview.btnConfirm.tag = 111;
//    [confrimPOAview.btnConfirm addTarget:self action:@selector(clickOnButtonConfirmedOrNotPOA:) forControlEvents:UIControlEventTouchUpInside];
//    
//    confrimPOAview.btnDecline.tag = 222;
//    [confrimPOAview.btnDecline addTarget:self action:@selector(clickOnButtonConfirmedOrNotPOA:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - PickerView Data Source and Delegate -

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return arrForIncidenceOrCategory.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [arrForIncidenceOrCategory[row] valueForKey:@"category_name"];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    selectedIncidenceOrCategory = row;
}

#pragma mark - MKMapView Delegate Methods -

- (MKAnnotationView *) mapView: (MKMapView *) theMapView viewForAnnotation: (id<MKAnnotation>) annotation
{
    AnnotationView *pinView = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"com.companyname.pin";
        pinView = (AnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        else
            pinView.annotation = annotation;
        
        for(UIView *subView in pinView.subviews)
            [subView removeFromSuperview];
        pinView.canShowCallout = NO;
        
        myAnnotation *annoTationView = (myAnnotation *) pinView.annotation;
        if([[annoTationView.pinDic objectForKey:@"poa_id"] intValue] == -1)
        {
            
            MKPinAnnotationView *draggablePin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"myDrgblePin"];

            if (draggablePin == nil)
            {
                draggablePin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myDrgblePin"];
            }
            else
                draggablePin.annotation = annotation;
            
            draggablePin.draggable = YES;
            return draggablePin;
        }
        else
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            UIImage *image = [UIImage imageNamed:@"new-map-pin-blue.png"];
            UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();

//            if ([[[defaults valueForKey:@"USERINFO"] valueForKey:@"is_paid_user"] isEqualToString:@"0"])
//                [[GeneralClass rgbColorFromHexString:@"#035070"] setFill];
//            else
//                [[GeneralClass rgbColorFromHexString:[[defaults objectForKey:@"USERINFO"] objectForKey:@"color_hexa"]] setFill];
            
            [[GeneralClass rgbColorFromHexString:[annoTationView.pinDic objectForKey:@"color_hexa"]] setFill];
            
            CGContextTranslateCTM(context, 0, image.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
            CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
            pinView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            pinView.centerOffset = CGPointMake(0,-pinView.frame.size.height/ 2);
            
            return pinView;
        }
    }
    else
    {
        [mapView.userLocation setTitle:@"I am here"];
        return pinView;
    }
}

- (void)mapView:(MKMapView *)theMapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState  fromOldState:(MKAnnotationViewDragState)oldState
{
    if(annotationView.annotation == mapView.userLocation)
        return;
    
    myAnnotation *annoRedPin = (myAnnotation *) annotationView.annotation;
    if([[annoRedPin.pinDic objectForKey:@"poa_id"] intValue] == -1)
    {
        if (newState == MKAnnotationViewDragStateEnding)
        {
            //referanceCordinate = annotationView.annotation.coordinate;
            NSLog(@"Pin dropped at %f,%f", annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude);
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSString stringWithFormat:@"%g",annotationView.annotation.coordinate.latitude] forKey:@"refLatitude"];
            [defaults setObject:[NSString stringWithFormat:@"%g",annotationView.annotation.coordinate.longitude] forKey:@"refLongitude"];
            [defaults synchronize];

            CLLocationCoordinate2D centerCoord;
            centerCoord.latitude = annotationView.annotation.coordinate.latitude;
            centerCoord.longitude = annotationView.annotation.coordinate.longitude;
            annoRedPin.coordinate = centerCoord;
            
            [self performSelector:@selector(openAlertForsetNotification) withObject:nil afterDelay:0.80f];
            
            //[annotationView setDragState:MKAnnotationViewDragStateNone animated:YES];
        }
}}


- (void)mapView:(MKMapView *)theMapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if(view.annotation == mapView.userLocation)
        return;

    myAnnotation *selectedAnn = (myAnnotation *) view.annotation;
    NSMutableDictionary *routeDic = (NSMutableDictionary *) selectedAnn.pinDic;
    NSLog(@"%@", routeDic);
    if([[routeDic objectForKey:@"poa_id"] intValue] == -1)
    {
        //view.draggable = YES;
        return;
    }
    
    
    //APP_DELEGATE.dicOfPOADic = [routeDic mutableCopy];
    
    
    if(objCallOutView)
    {
        for(UIView *subView in objCallOutView.subviews)
            [subView removeFromSuperview];
        [objCallOutView removeFromSuperview];
        objCallOutView = nil;
    }
    
    objCallOutView = [[calloutView alloc] init];
    objCallOutView.frame = CGRectMake(-10, 0, 220, 60);
    objCallOutView.backgroundColor = [UIColor clearColor];
    [view addSubview:objCallOutView];
    
    
    //NSArray *tempArr = [[NSString stringWithFormat:@"%@",[routeDic valueForKey:@"show_date_time"]] componentsSeparatedByString:@" "];
    NSString *strTime = [NSString stringWithFormat:@"%@",[routeDic valueForKey:@"show_date_time"]];//[NSString stringWithFormat:@"%@ %@", [tempArr objectAtIndex:1], [tempArr objectAtIndex:2]];
    
    UILabel *lblCalloutTime = [[UILabel alloc] init];
    lblCalloutTime.frame = CGRectMake(objCallOutView.frame.size.width - 146, 7, 80, 15);
    lblCalloutTime.font = [UIFont fontWithName:@"SFUIText-Regular" size:10];
    //lblCalloutTime.text = [NSString stringWithFormat:@"%@",[routeDic objectForKey:@"occurred_time"]];
    lblCalloutTime.text = strTime;
    lblCalloutTime.textColor = [UIColor whiteColor];
    lblCalloutTime.textAlignment = NSTextAlignmentRight;
    [objCallOutView addSubview:lblCalloutTime];
    
    UIButton *btnCalloutKM = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCalloutKM.frame = CGRectMake(objCallOutView.frame.size.width - 65, 8, 55, 17);
    [btnCalloutKM setImage:[UIImage imageNamed:@"locationCallout.png"] forState:UIControlStateNormal];
    btnCalloutKM.backgroundColor = [UIColor lightGrayColor];
    btnCalloutKM.titleLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:10];
    [btnCalloutKM setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCalloutKM setTitle:[NSString stringWithFormat:@"%.2f %@",[[routeDic objectForKey:@"distance"] floatValue], [APP_DELEGATE.dictForLabels objectForKey:@"km"]] forState:UIControlStateNormal];
    btnCalloutKM.backgroundColor = [UIColor clearColor];
    btnCalloutKM.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btnCalloutKM.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [btnCalloutKM setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 1, 4)];
    btnCalloutKM.userInteractionEnabled = NO;
    [objCallOutView addSubview:btnCalloutKM];
    
    UILabel *lblCalloutTitle = [[UILabel alloc] init];
    lblCalloutTitle.frame = CGRectMake(10, lblCalloutTime.frame.origin.y + lblCalloutTime.frame.size.height, objCallOutView.frame.size.width - 20, 14);
    lblCalloutTitle.font = [UIFont fontWithName:@"SFUIText-Semibold" size:11];
    lblCalloutTitle.text = [routeDic objectForKey:@"message"];
    lblCalloutTitle.numberOfLines = 0;
    [GeneralClass setDynamicHeightOfLabel:lblCalloutTitle withFont:lblCalloutTitle.font andDefaultHeightOfLabel:14];
    lblCalloutTitle.textColor = [UIColor whiteColor];
    lblCalloutTitle.textAlignment = NSTextAlignmentLeft;
    [objCallOutView addSubview:lblCalloutTitle];
    
    UILabel *lblCalloutDes = [[UILabel alloc] init];
    lblCalloutDes.frame = CGRectMake(lblCalloutTitle.frame.origin.x, lblCalloutTitle.frame.origin.y + lblCalloutTitle.frame.size.height + 2, lblCalloutTitle.frame.size.width, 13);
    lblCalloutDes.font = [UIFont fontWithName:@"SFUIText-Regular" size:9];
    if ([[routeDic objectForKey:@"confirmed_status"] integerValue] == 0)
    {
        lblCalloutDes.frame = CGRectMake(lblCalloutTitle.frame.origin.x, lblCalloutTitle.frame.origin.y + 3, lblCalloutTitle.frame.size.width, 13);
        lblCalloutDes.text = [NSString stringWithFormat:@"%@", [APP_DELEGATE.dictForLabels objectForKey:@"attention_alert"]];
        lblCalloutDes.font = [UIFont fontWithName:@"SFUIText-Regular" size:11];
        lblCalloutTitle.hidden = YES;
    }
    else
    {
        if ([[routeDic objectForKey:@"confirmed_people"] integerValue] > 0)
        {
            lblCalloutDes.text = [NSString stringWithFormat:@"%@ people confirmed. (Last confirmed %@).",[routeDic objectForKey:@"confirmed_people"],[routeDic objectForKey:@"last_confirmed_time"]];
        }
        else
            lblCalloutDes.text = [NSString stringWithFormat:@"No people confirmed yet."];
    }
    
    lblCalloutDes.numberOfLines = 0;
    [GeneralClass setDynamicHeightOfLabel:lblCalloutDes withFont:lblCalloutDes.font andDefaultHeightOfLabel:13];
    lblCalloutDes.textColor = [UIColor whiteColor];
    lblCalloutDes.textAlignment = NSTextAlignmentLeft;
    [objCallOutView addSubview:lblCalloutDes];
    
    objCallOutView.frame = CGRectMake(-10, -(lblCalloutDes.frame.origin.y + lblCalloutDes.frame.size.height + 23), objCallOutView.frame.size.width, lblCalloutDes.frame.origin.y + lblCalloutDes.frame.size.height + 20);
  
//    UIButton *btnOverOnCustomView = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnOverOnCustomView.frame = objCallOutView.bounds;
//    btnOverOnCustomView.backgroundColor = [UIColor clearColor];
//    [btnOverOnCustomView addTarget:self action:@selector(clickOnCustomCallOutView) forControlEvents:UIControlEventTouchUpInside];
//    [objCallOutView addSubview:btnOverOnCustomView];
    
    [GeneralClass openPopUpViewWhereDimView:view andInerView:objCallOutView];
    
    MKMapRect r = [mapView visibleMapRect];
    MKMapPoint pt = MKMapPointForCoordinate([view.annotation coordinate]);
    r.origin.x = pt.x - r.size.width * 0.29;
    r.origin.y = pt.y - r.size.height * 0.45;
    [mapView setVisibleMapRect:r animated:YES];
}

- (void)mapView:(MKMapView *)theMapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if(view.annotation == mapView.userLocation)
        return;
    
    [UIView transitionWithView:view
                      duration:0.35
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        objCallOutView.alpha = 0;
                    }
                    completion:^(BOOL finished){
                        for(UIView *subView in view.subviews)
                            [subView removeFromSuperview];
                    }];
}

-(void)clickOnCustomCallOutView
{
    
//    if([[APP_DELEGATE.dicOfPOADic valueForKey:@"type"] intValue] == 1)
//    {
//        showAlert([APP_DELEGATE.dictForLabels objectForKey:@"appname"], [APP_DELEGATE.dictForLabels objectForKey:@"ownpoa_msg"]);
//    }
//    else if([[APP_DELEGATE.dicOfPOADic valueForKey:@"confirmed_status"] intValue] == 1)
//    {
//        showAlert([APP_DELEGATE.dictForLabels objectForKey:@"appname"], [APP_DELEGATE.dictForLabels objectForKey:@"already_confirmedpoa"]);
//    }
//    else if([[APP_DELEGATE.dicOfPOADic valueForKey:@"confirmed_status"] intValue] == 2)
//    {
//        showAlert([APP_DELEGATE.dictForLabels objectForKey:@"appname"], [APP_DELEGATE.dictForLabels objectForKey:@"already_declinedpoa"]);
//    }
//    else
//        [self openConforimedOrDeclinePOACustomView];
}


//-(void) openConforimedOrDeclinePOACustomView
//{
////    if(!confrimPOAview)
////        [self setupConfirmedAndDecinePOAPopUp];
////    [confrimPOAview openPopUpView];
//    APP_DELEGATE.isNotificationCome = NO;
//}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
//    for (UIView *view in views)
//        [self addBounceAnnimationToView:view];
}

- (void) addAllAnnotationOnMap:(NSMutableArray *) annotationArray;
{
    for (int i = 0 ; i < annotationArray.count; i ++)
    {
        CLLocationCoordinate2D centerCoord;
        centerCoord.latitude = [[[annotationArray objectAtIndex:i] objectForKey:@"latitude"] doubleValue];
        centerCoord.longitude = [[[annotationArray objectAtIndex:i] objectForKey:@"longitude"] doubleValue];
        
        myAnnotation *myCustomAnn = [[myAnnotation alloc] initWithCoordinate:centerCoord];
        myCustomAnn.strTitle = [[annotationArray objectAtIndex:i] objectForKey:@"poa_id"];
        myCustomAnn.pinDic = (NSMutableDictionary *)[annotationArray objectAtIndex:i];
        [mapView addAnnotation:myCustomAnn];
    }
    
    if(isDisplayHUD)
        [self performSelector:@selector(zoomToFitMapAnnotations:) withObject:mapView afterDelay:1];
}

- (void) removeAllAnnotationOnMap
{
    NSMutableArray *annotationsToRemove = [mapView.annotations mutableCopy];
    [annotationsToRemove removeObject:mapView.userLocation];
    for(myAnnotation *annot in [annotationsToRemove mutableCopy])
    {
        if([annot.strTitle isEqualToString:@"-1"])
            [annotationsToRemove removeObject:annot];
    }
    [mapView removeAnnotations:annotationsToRemove];
}


-(void)zoomToFitMapAnnotations:(MKMapView*)theMapView
{
    if([theMapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(myAnnotation* annotation in theMapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [theMapView regionThatFits:region];
    [theMapView setRegion:region animated:YES];
}

- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++)
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

#pragma mark - Action Buttons -

- (void)plusClick:(id)sender
{
    [self ceratePopUpView];
}

- (void)closeClick:(id)sender
{
    if(activeTextField.isFirstResponder)
        [activeTextField resignFirstResponder];
    if(txtView.isFirstResponder)
        [txtView resignFirstResponder];
    [GeneralClass closePopUpViewWhereDimView:viewPopUp andInerView:viewPopUpInner];
}

- (void)alertClick:(id)sender
{
    if(activeTextField.isFirstResponder)
        [activeTextField resignFirstResponder];
    if(txtView.isFirstResponder)
        [txtView resignFirstResponder];
    
    if ([txtIncidenceOrCategory.text length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"appname"] message:[APP_DELEGATE.dictForLabels objectForKey:@"select_Incidence"] delegate:self cancelButtonTitle:[APP_DELEGATE.dictForLabels objectForKey:@"ok"] otherButtonTitles: nil];
        alert.tag = 111;
        [alert show];
    }
    else if ([txtView.text isEqualToString:[APP_DELEGATE.dictForLabels objectForKey:@"message"]])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"appname"] message:[APP_DELEGATE.dictForLabels objectForKey:@"enter_message"] delegate:self cancelButtonTitle:[APP_DELEGATE.dictForLabels objectForKey:@"ok"] otherButtonTitles: nil];
        alert.tag = 222;
        [alert show];
    }
    else
        [self callWebserviceForAddAlert];
}

- (void)menuClick:(id)sender
{
}

- (void)languageClick:(id)sender
{
}

-(void)clickOnButtonConfirmedOrNotPOA:(UIButton *) sender
{
    if([sender tag] == 111)
        isConfirmedOrNot = YES;
    else
        isConfirmedOrNot = NO;
    
   // [self callWebserviceForConfirmOrNOtPOA];
}

#pragma mark - UIAlertView Delegate Method -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 111)
        [txtIncidenceOrCategory becomeFirstResponder];
    else if(alertView.tag == 101)
    {
        if(buttonIndex == 1)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
    }
    else if (alertView.tag == 102)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    else if (alertView.tag == 222)
        [txtView becomeFirstResponder];
}

#pragma mark - Webservice Responce -

-(void)webServiceResponce:(NSString *)strRes
{
    [SVProgressHUD dismiss];
    NSData *mydata=[strRes dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSMutableArray *returnArry=[NSJSONSerialization JSONObjectWithData:mydata options:NSJSONReadingMutableContainers error:&e];
    NSLog(@"%@",returnArry);
    NSString *strcode=[NSString stringWithFormat:@"%@",[[returnArry valueForKey:@"code"]objectAtIndex:0]];
    if ([@"" isEqualToString:@"Category"])
    {
        if ([strcode isEqualToString:@"1"])
        {
            arrForIncidenceOrCategory = [[returnArry objectAtIndex:0] valueForKey:@"result"];
            [txtIncidenceOrCategory becomeFirstResponder];
        }
        else if ([strcode isEqualToString:@"0"])
        {
            showAlert([APP_DELEGATE.dictForLabels objectForKey:@"appname"], [APP_DELEGATE.dictForLabels objectForKey:@"no_data_found"])
        }
        else
        {
            showAlert([APP_DELEGATE.dictForLabels objectForKey:@"appname"], [APP_DELEGATE.dictForLabels objectForKey:@"server_Connection_Error"]);
        }
    }
    else if ([@"" isEqualToString:@"AlertListing"])
    {
        isAPIRunning = NO;
        
        if ([strcode isEqualToString:@"1"])
        {
            if ([arrForPin count] > 0)
                [arrForPin removeAllObjects];
            
            arrForPin = [[returnArry objectAtIndex:0] valueForKey:@"result"];
            [self removeAllAnnotationOnMap];
            [self addAllAnnotationOnMap:arrForPin];
        }
        else if ([strcode isEqualToString:@"-2"] || [strcode isEqualToString:@"-1"])
        {
            [GeneralClass displayAlertForInvalidUserOrTokenWhereMessage:[APP_DELEGATE.dictForLabels objectForKey:@"invalid_Token"] onViewcon:self];
        }
        else
        {
            if ([arrForPin count] > 0)
                [arrForPin removeAllObjects];

            [self removeAllAnnotationOnMap];
            
//            CLLocationCoordinate2D centerCoord;
//            centerCoord.latitude = [APP_DELEGATE.strForCurrentLat doubleValue];
//            centerCoord.longitude = [APP_DELEGATE.strForCurrentLon doubleValue];
//            
//            MyAnnotation *myCustomAnn = [[MyAnnotation alloc] initWithCoordinate:centerCoord];
//            myCustomAnn.strTitle = @"-1";
//            NSMutableDictionary *temDic = [[NSMutableDictionary alloc] init];
//            [temDic setObject:@"-1" forKey:@"poa_id"];
//            myCustomAnn.pinDic = (NSMutableDictionary *)temDic;
//            [mapView addAnnotation:myCustomAnn];
//
//            if(isDisplayHUD)
//                [self performSelector:@selector(zoomToFitMapAnnotations:) withObject:mapView afterDelay:1];
        }
    }
    else if ([@"" isEqualToString:@"AddAlert"])
    {
        [GeneralClass closePopUpViewWhereDimView:viewPopUp andInerView:viewPopUpInner];
        if ([strcode isEqualToString:@"1"])
        {
            if(!arrForPin)
                arrForPin = [[NSMutableArray alloc] init];
            
            [arrForPin addObject:[[[returnArry objectAtIndex:0] valueForKey:@"result"] objectAtIndex:0]];
            [self addAllAnnotationOnMap:arrForPin];
        }
        else if ([strcode isEqualToString:@"-2"])
        {
            [GeneralClass displayAlertForInvalidUserOrTokenWhereMessage:[APP_DELEGATE.dictForLabels objectForKey:@"invalid_Token"] onViewcon:self];
        }
        else if ([strcode isEqualToString:@"-3"])
        {
            UIAlertController *alertCont = [UIAlertController alertControllerWithTitle:[APP_DELEGATE.dictForLabels objectForKey:@"appname"] message:[APP_DELEGATE.dictForLabels objectForKey:@"poa_exist"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                 {
                                 }];
            [alertCont addAction:ok];
            
            [self presentViewController:alertCont animated:YES completion:nil];
        }
        else
        {
            showAlert([APP_DELEGATE.dictForLabels objectForKey:@"appname"], [APP_DELEGATE.dictForLabels objectForKey:@"server_Connection_Error"]);
        }
    }
}

-(void)webServiceFailure
{
    [SVProgressHUD dismiss];
}

-(void) callWebserviceForAddAlert
{
}

-(void) callWebserviceForGetCategory
{
    [SVProgressHUD show];
    NSString *Category = [NSString stringWithFormat:@"%@category_listing.php?language_id=%@&date=%@", MAINURL, @"1",[GeneralClass getCurrentDateAndTime]];
    Category = [Category stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Category webservice ------->> %@ ",Category);
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *params = nil;
    [requestManager GET:Category parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSString *returnString=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSString *returnString1=[returnString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
         returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
         returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
         returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#034;" withString:@"\""];

         NSData *responceData = [returnString1 dataUsingEncoding:NSUTF8StringEncoding];
         NSError *responceError;
         NSMutableArray *responseArr = [NSJSONSerialization JSONObjectWithData:responceData options:NSJSONReadingMutableContainers error:&responceError];

         NSLog(@"%@", responseArr);

         NSString *strcode=[NSString stringWithFormat:@"%@",[[responseArr valueForKey:@"code"]objectAtIndex:0]];
         if ([strcode isEqualToString:@"1"])
         {
             arrForIncidenceOrCategory = [[responseArr objectAtIndex:0] valueForKey:@"result"];
             [self performSelector:@selector(txtOpenPicker:) withObject:txtIncidenceOrCategory afterDelay:0];
         }
         else if ([strcode isEqualToString:@"0"])
         {
             showAlert([APP_DELEGATE.dictForLabels objectForKey:@"appname"], [APP_DELEGATE.dictForLabels objectForKey:@"no_data_found"])
         }
         else
         {
             showAlert([APP_DELEGATE.dictForLabels objectForKey:@"appname"], [APP_DELEGATE.dictForLabels objectForKey:@"server_Connection_Error"]);
         }

         [SVProgressHUD dismiss];
     }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         
         [SVProgressHUD dismiss];
     }];

}


-(void) callWebserviceForAlertListingwithHudStatus:(NSInteger)hudStatus
{
    
    
}



-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([countDownTimer isValid])
        [countDownTimer invalidate];
    countDownTimer = nil;
    
    if(activeTextField.isFirstResponder)
        [activeTextField resignFirstResponder];
    if(txtView.isFirstResponder)
        [txtView resignFirstResponder];
    self.customPikerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 216);
}

#pragma mark - didReceiveMemoryWarning -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
