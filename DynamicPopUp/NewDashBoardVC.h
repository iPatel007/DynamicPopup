//
//  NewDashBoardVC.h
//  Ticket Alert
//
//  Created by iPatel on 29/06/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "calloutView.h"

//#import "ConfirmedPOAView.h"
#import "AnnotationView.h"
#import "CountDownView.h"

@interface NewDashBoardVC : UIViewController <MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, WebServiceDelegate, UIGestureRecognizerDelegate>
{
    MKMapView *mapView;
//    UIView *calloutView;
    
    TPKeyboardAvoidingScrollView *scrollPopUp;
    
    UIView *viewPopUp;
    UIView *viewPopUpInner;
    UIView *viewPopUpContainer;
    UITextField *txtIncidenceOrCategory;
    UITextView *txtView;
    UIImageView *imgBottomTextViewLine;
    UIButton *btnAlert;
    UITextField *activeTextField;
    UIPickerView *viewPicker;
    NSInteger selectedIncidenceOrCategory;
    NSMutableArray *arrForIncidenceOrCategory;
    //NSString *strSelectedTime;
    UILabel *lblServerTime;
    
    //BOOL isDragdrop;
    calloutView *objCallOutView;
    NSMutableArray *arrForPin;
    UILabel *lblHeader;
    
    BOOL isAPIRunning;
    BOOL isDisplayHUD;
    //ConfirmedPOAView *confrimPOAview;
    
    BOOL isConfirmedOrNot;
    int indexOfCallOut;
    
    //CLLocationCoordinate2D referanceCordinate;
    AnnotationView *myAnnotationView;
    
    NSTimer *countDownTimer;
    UILabel *lblOnDatePicker;
    
}

@property (nonatomic, strong) UIView *customPikerView;
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) CountDownView *countDownView;

-(void) callWebserviceForAlertListingwithHudStatus:(NSInteger)hudStatus;
-(void) reloadDashBoardScreenForSetLabels;
-(void) setRegionWhenDisplayAdMob;

@end
