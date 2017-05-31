//
//  LoginViewController.h
//  CheckedIn
//
//  Created by iPatel on 7/20/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLDb.h"

@interface LoginViewController : UIViewController <WebServiceDelegate>
{
    
    SQLDb *_sql;
    
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIButton *btnSignUp;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    
    IBOutlet UIButton *btnSignIN;
    IBOutlet UIButton *btnFaceBook;
    NSMutableDictionary *dictForSocialLoginUser;
    UITextField *activeTextField;
    BOOL isFBLogin;
    IBOutlet UIButton *btnEyes;
    
    NSString *strUserImageData;
    
    NSString *strXMPPJid;
    
}

@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property (nonatomic ,retain) NSString *strForLoginThrough;
- (void)requestCompleted:(FBRequestConnection *)connection
                 forFbID:(NSString *)fbID
                  result:(id)result
                   error:(NSError *)error;

@end
