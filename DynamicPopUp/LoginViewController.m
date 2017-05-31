//
//  LoginViewController.m
//  CheckedIn
//
//  Created by iPatel on 7/20/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import "LoginViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - viewDidLoad Method -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sql = [SQLDb initEngine];
    
    btnSignIN.layer.borderColor = [UIColor whiteColor].CGColor;
    btnSignIN.layer.borderWidth = 1;
    btnSignIN.layer.cornerRadius = 4;

    btnFaceBook.layer.borderColor = [UIColor whiteColor].CGColor;
    btnFaceBook.layer.borderWidth = 1;
    btnFaceBook.layer.cornerRadius = 4;
    
    [txtPassword addTarget:self action:@selector(textPasswordChangedEvent:) forControlEvents:UIControlEventEditingChanged];
    
}


#pragma mark - viewWillAppear Method -

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [APP_DELEGATE setupPushNoification];
    
    btnEyes.hidden = YES;
    
    if(!_sql)
        _sql = [SQLDb initEngine];
    
    [_sql deleteAllDataFrom_user_Group_ChatList];
    [_sql deleteAllDataFrom_blockUserTable];
    
    [GeneralClass setTextFieldPlaceHolderColor:txtEmail];
    [GeneralClass setTextFieldPlaceHolderColor:txtPassword];

    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, btnFaceBook.frame.origin.y + btnFaceBook.frame.size.height + 8);
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

#pragma mark - TextField Delegate -

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail)
        [txtPassword becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

-(void)textPasswordChangedEvent:(UITextField *)textField
{
    if(txtPassword.isSecureTextEntry)
        [btnEyes setImage:[UIImage imageNamed:@"eye.png"] forState:UIControlStateNormal];
    else
        [btnEyes setImage:[UIImage imageNamed:@"eye-close.png"] forState:UIControlStateNormal];
    
    if([textField.text length] == 0)
    {
        btnEyes.hidden = YES;
    }
    else
    {
        btnEyes.hidden = NO;
    }
}

#pragma mark - custom  methods -

-(void) callAlertViewWithString:(NSString*)alertMsg
{
    UIAlertController *alertCont = [UIAlertController alertControllerWithTitle:AlertTitle message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                         {
                            // [APP_DELEGATE callTabBar];
                         }];
    [alertCont addAction:ok];dispatch_async(dispatch_get_main_queue(), ^{[self presentViewController:alertCont animated:YES completion:nil];
    });
}

-(void) saveDataWithArray:(NSMutableArray*)returnArry
{
    
}

-(void)JoinGroup
{
   
}

-(void)XMPPRegisteration :(NSString *)strUserId
{
    
}


#pragma mark - UIButton Methods -

-(IBAction)clickOnSignInButton:(UIButton *)sender
{
    [activeTextField resignFirstResponder];
    
    if ([txtEmail.text length] == 0)
    {
        callAlert(self, txtEmail, @"Please enter email");
    }
    else if (![GeneralClass validateEmailAddress:txtEmail.text])
    {
        callAlert(self, txtEmail, @"Please enter valid email address");
    }
    else if ([txtPassword.text length] == 0)
    {
        callAlert(self, txtPassword, @"Please enter password");
    }
    else
    {
        isFBLogin = NO;
        [self callWebserviceForLogin];
    }
}

-(IBAction)clickOnFacebookButton:(UIButton *)sender
{
//    NSLog(@"FB Button Click");
    [SVProgressHUD show];
    [self facebookAction];
}

-(IBAction)clickOnSignUpButton:(UIButton *)sender
{
}

-(IBAction)clickOnForgotPasswordButton:(UIButton *)sender
{
}

-(IBAction)clickOnHideShowPasswordButton:(UIButton *)sender
{
    if(txtPassword.isFirstResponder)
        [txtPassword resignFirstResponder];
    
    NSString *tmpString;
    [txtPassword setSecureTextEntry:!txtPassword.isSecureTextEntry];
    tmpString = txtPassword.text;
    txtPassword.text = @" ";
    txtPassword.text = tmpString;
    txtPassword.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    if(txtPassword.isSecureTextEntry)
        [btnEyes setImage:[UIImage imageNamed:@"eye.png"] forState:UIControlStateNormal];
    else
        [btnEyes setImage:[UIImage imageNamed:@"eye-close.png"] forState:UIControlStateNormal];
}

#pragma mark - FB Login -

-(IBAction)facebookAction
{
    [FBSession.activeSession closeAndClearTokenInformation];
    
    [APP_DELEGATE.window endEditing:YES];
    
    //        [APP_DELEGATE.tumblrHUD showAnimated:YES];
    [SVProgressHUD show];
    
    if ([[FBSession activeSession] isOpen]) {
        /*
         * if the current session has no publish permission we need to reauthorize
         */
        if ([[[FBSession activeSession] permissions]indexOfObject:@"publish_actions"] == NSNotFound) {
            
            [[FBSession activeSession] requestNewPublishPermissions:[NSArray arrayWithObject:@"email"] defaultAudience:FBSessionDefaultAudienceFriends
                                                  completionHandler:^(FBSession *session,NSError *error){
                                                      
                                                      [self sendRequests];
                                                  }];
            
        }else{
            
            [self sendRequests];
        }
    }else{
        /*
         * open a new session with publish permission
         */
        
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"email"]
                                           defaultAudience:FBSessionDefaultAudienceOnlyMe
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (!error && status == FBSessionStateOpen) {
                                                 
                                                 [self sendRequests];
                                             }else{
                                                 [SVProgressHUD dismiss];
                                                 
                                                 
                                                 NSLog(@"%@",error);
                                                 
                                                 //                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 //                                                                                                 message:error.localizedDescription delegate:nil                                               cancelButtonTitle:@"OK"
                                                 //                                                                                       otherButtonTitles:nil];
                                                 //                                                 [alert show];
                                                 
                                             }
                                         }];
    }
}

- (void)sendRequests {
    
    [SVProgressHUD show];
    
    NSArray *fbids = [NSArray arrayWithObjects:@"me", nil];
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    for (NSString *fbid in fbids)
    {
        // create a handler block to handle the results of the request for fbid's profile
        FBRequestHandler handler =
        ^(FBRequestConnection *connection, id result, NSError *error) {
            // output the results of the request
            [self requestCompleted:connection forFbID:@"me/?fields=name,picture,email,first_name,last_name,location,gender,hometown,birthday" result:result error:error];
        };
        
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                      graphPath:@"me/?fields=name,picture,email,first_name,last_name,location,gender,hometown,birthday"];
        [newConnection addRequest:request completionHandler:handler];
    }
    
    // if there's an outstanding connection, just cancel
    [self.requestConnection cancel];
    
    // keep track of our connection, and start it
    self.requestConnection = newConnection;
    [newConnection start];
    
}

// FBSample logic
// Report any results.  Invoked once for each request we make.
- (void)requestCompleted:(FBRequestConnection *)connection
                 forFbID:fbID
                  result:(id)result
                   error:(NSError *)error {
    // not the completion we were looking for...
    if (self.requestConnection &&
        connection != self.requestConnection) {
        return;
    }
    
    // clean this up, for posterity
    self.requestConnection = nil;
    
    NSString *text;
    if (error) {
        // error contains details about why the request failed
        text = error.localizedDescription;
    }
    else
    {
        // result is the json response from a successful request
        if ([dictForSocialLoginUser count] > 0)
            [dictForSocialLoginUser removeAllObjects];
        dictForSocialLoginUser = (NSMutableDictionary *)result;
        // we pull the name property out, if there is one, and display it
        text = (NSString *)[dictForSocialLoginUser objectForKey:@"name"];
        
        if ([result isKindOfClass:[NSArray class]])
        {
            result = [result objectAtIndex:0];
        }
        
        // When we ask for user infor this will happen.
        if ([result isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"%@---->",result);
            [SVProgressHUD dismiss];
            NSLog(@"Name: %@", [result objectForKey:@"name"]);
            NSMutableDictionary *dictLoc = [result objectForKey:@"location"];
            NSString *strLocation = [dictLoc objectForKey:@"name"];
            strLocation = [strLocation stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            
            NSString *strEmail=[result objectForKey:@"email"];
            if ([self stringIsEmpty:strEmail]) {
                strEmail=@"";
            }
            if ([self stringIsEmpty:strLocation]) {
                strLocation=@"";
            }
            
            NSString *strGenderCode = [result objectForKey:@"gender"];
            if([self stringIsEmpty:strGenderCode])
            {
                strGenderCode =@"0";
            }
            else
            {
                if ([strGenderCode isEqualToString:@"male"])
                    strGenderCode = @"0";
                else
                    strGenderCode = @"1";
            }
            NSLog(@"%@  -- > %@",strEmail,strLocation);
            
            strUserImageData = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
            
            isFBLogin = TRUE;
            [self callWebserviceForFBLogin:dictForSocialLoginUser];
            NSLog(@"FB Login Detail   -- > %@",dictForSocialLoginUser);
        }
    }
}

- (NSString *)urlencode:(NSString*)strText {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[strText UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (BOOL ) stringIsEmpty:(NSString *) aString {
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"received response");
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    if ([result isKindOfClass:[NSArray class]])
    {
        result = [result objectAtIndex:0];
    }
    // When we ask for user infor this will happen.
    if ([result isKindOfClass:[NSDictionary class]])
    {
        
    }
    if ([result isKindOfClass:[NSData class]])
    {
        NSLog(@"Profile Picture");
        //profilePicture = [[UIImage alloc] initWithData: result];
    }
    NSLog(@"request returns %@",result);
    //if ([result objectForKey:@"owner"]) {}
    
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@">>>>>>>>>>>>>>>>> did fail with error :%@", error);
}

#pragma mark - call webservice -

-(void) callWebserviceForDeviceRegister
{
    //mobileappws.com/mobile_checkedin/admin/api/device_register.php?user_id=1&device_type=1&device_token=d5Vkmcfdsfd
    
    [SVProgressHUD show];
    
    NSString *deviceRegister = [NSString stringWithFormat:@"%@device_register.php?user_id=%@&device_type=2&device_token=%@&date=%@",MAINURL,@"1",((APP_DELEGATE.strDeviceToken == nil) ? @"" : APP_DELEGATE.strDeviceToken),[GeneralClass getCurrentDateAndTime]];
    deviceRegister = [deviceRegister stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"deviceRegister webservice ---> %@", deviceRegister);
    
    APP_DELEGATE.webServiceObject._delegate = self;
    [APP_DELEGATE.webServiceObject callWebService:deviceRegister dictionaryWithData:nil withType:@"get"];
}

-(void) callWebserviceForLogin
{
  callAlert(self, txtEmail, @"Please enter email");
}

-(void) callWebserviceForFBLogin:(NSMutableDictionary *)FBLoginData
{
    
    [SVProgressHUD show];
    
    NSDictionary *dict  = [[NSDictionary alloc]init];
    dict = @{
             @"full_name" : [FBLoginData objectForKey:@"name"],
             @"email" : [FBLoginData objectForKey:@"email"],
             @"facebook_id" : [FBLoginData objectForKey:@"id"],
             @"user_img_url" : strUserImageData,
             @"date": [GeneralClass getCurrentDateAndTime]
             };

    NSLog(@"%@", dict);
    
    NSString *FBlogin = [NSString stringWithFormat:@"%@facebook_login.php", MAINURL];
    FBlogin = [FBlogin stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"FBlogin webservice ------->> %@ ",FBlogin);
    APP_DELEGATE.webServiceObject._delegate = self;
    [APP_DELEGATE.webServiceObject callWebService:FBlogin dictionaryWithData:dict withType:@"get"];
}

-(void) callWebserviceForUpdateXMPPid:(NSString *) strXMPPid
{
    ///mobileappws.com/mobile_checkedin/admin/api/updateJabberId.php?xmppId=1&user_id=1
    
  
}


#pragma mark - Webservice Responce -

-(void)webServiceResponce:(NSString *)strRes
{
    NSData *mydata=[strRes dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSMutableArray *returnArry=[NSJSONSerialization JSONObjectWithData:mydata options:NSJSONReadingMutableContainers error:&e];
    NSLog(@"%@",returnArry);
    NSString *strcode=[NSString stringWithFormat:@"%@",[[returnArry valueForKey:@"code"]objectAtIndex:0]];
    if ([@"" isEqualToString:@"Login"]) //if ([APP_DELEGATE.strRequestFor isEqualToString:@"Login"])
    {
        if ([strcode isEqualToString:@"1"] || [strcode isEqualToString:@"2"])
        {
            [self saveDataWithArray:returnArry];
            if (isFBLogin)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:@"YES" forKey:@"FBLOGIN"];
                [defaults synchronize];
            }
            [self performSelector:@selector(callWebserviceForDeviceRegister) withObject:nil afterDelay:.10];
        }
        else if ([strcode isEqualToString:@"0"])
        {
            [SVProgressHUD dismiss];
            if (isFBLogin)
            {
                showAlert(AlertTitle, @"Email is already exists.");
            }
            else
            {
                callAlert(self, txtEmail, @"Invalid email or password.");
            }
        }
        else if ([strcode isEqualToString:@"-1"])
        {
            
            [SVProgressHUD dismiss];
            if (isFBLogin)
            {
                showAlert(AlertTitle, AlertServerError);
            }
            else
            {
                showAlert(AlertTitle, @"Your account is inactive.");
            }
        }
        else
        {
            [SVProgressHUD dismiss];
            showAlert(AlertTitle, AlertServerError);
        }
    }
   
}

-(void)webServiceFailure
{
    [SVProgressHUD dismiss];
}

#pragma mark - didReceiveMemoryWarning Method -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
