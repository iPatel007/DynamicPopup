//
//  SignUpVC.h
//  CheckedIn
//
//  Created by iPatel on 21/07/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate,WebServiceDelegate>
{
    IBOutlet UIScrollView *scrlView;
    
    IBOutlet UIImageView *imgProfile;
    IBOutlet UIButton *btnProfile;
    IBOutlet UIButton *btnSignUp;
    
    IBOutlet UITextField *txtFullname;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtGender;
    IBOutlet UITextField *txtDOB;
    
    UITextField *activeTextField;
    UIPickerView *viewPicker;
    UIDatePicker *datePicker;
    NSInteger selectedGender;
    NSString *strSelectedDate, *strUserImageData;
    NSMutableArray *arrForGender;
    
    
    NSString *strXMPPJid;
    
    NSString *regiUserJID;
}

@property (strong, nonatomic) NSMutableData *responseData;

@end
