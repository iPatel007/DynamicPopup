//
//  SignUpVC.m
//  CheckedIn
//
//  Created by iPatel on 21/07/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import "SignUpVC.h"

#import "AFHTTPRequestOperationManager.h"

@interface SignUpVC ()

@end

@implementation SignUpVC

#pragma mark - viewDidLoad -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrForGender = [[NSMutableArray alloc]initWithObjects:@"Male", @"Female", nil];
}

#pragma mark - viewWillAppear -

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    btnSignUp.layer.borderColor = [UIColor whiteColor].CGColor;
    btnSignUp.layer.borderWidth = 1;
    btnSignUp.layer.cornerRadius = 4;
    [GeneralClass setTextFieldPlaceHolderColor:txtFullname];
    [GeneralClass setTextFieldPlaceHolderColor:txtEmail];
    [GeneralClass setTextFieldPlaceHolderColor:txtPassword];
    [GeneralClass setTextFieldPlaceHolderColor:txtGender];
    [GeneralClass setTextFieldPlaceHolderColor:txtDOB];
    scrlView.contentSize = CGSizeMake(SCREEN_WIDTH, btnSignUp.frame.origin.y + btnSignUp.frame.size.height + 8);
    [txtGender addTarget:self action:@selector(txtOpenPicker:) forControlEvents:UIControlEventEditingDidBegin];
    [txtGender endEditing:NO];
    [txtDOB addTarget:self action:@selector(txtDateTouch:) forControlEvents:UIControlEventEditingDidBegin];
    [txtDOB endEditing:NO];
}

#pragma mark - UIImagePickerController Delegate methods -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *imagePicked = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *finalImage = [GeneralClass scaleImage:imagePicked toSize:CGSizeMake(350, 350)];
    strUserImageData = [GeneralClass encodeImageToBase64String:finalImage];
    [btnProfile setImage:finalImage forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    btnProfile.layer.cornerRadius = btnProfile.frame.size.height / 2;
    btnProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    btnProfile.layer.borderWidth = 1;
    btnProfile.layer.masksToBounds = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet Delegate Method -

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        UIImagePickerController *imgeCamera = [[UIImagePickerController alloc]init];
        imgeCamera.delegate = self;
        imgeCamera.allowsEditing = YES;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            imgeCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imgeCamera animated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        UIImagePickerController *imgeCamera = [[UIImagePickerController alloc]init];
        imgeCamera.delegate = self;
        imgeCamera.allowsEditing = YES;
        imgeCamera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imgeCamera animated:YES completion:nil];
    }
}

#pragma mark - TextField Delegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    if (textField  == txtDOB || textField == txtGender)
        [self addToolBatOnTopOfTextField:activeTextField];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtFullname)
    {
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        if (isBackSpace == -8)
            return YES;

        NSCharacterSet *invalidCharSet = [[[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "] invertedSet] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        return ![string isEqualToString:filtered];
    }
    else
        return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtFullname)
        [txtEmail becomeFirstResponder];
    else if (textField == txtEmail)
        [txtPassword becomeFirstResponder];
    else if (textField == txtPassword)
        [txtGender becomeFirstResponder];
    else if (textField == txtGender)
        [txtDOB becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return YES;
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
    return arrForGender.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return arrForGender[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    selectedGender = row;
}

#pragma mark - custom methods -

-(void) openImagePicker
{
    [activeTextField resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Camera Option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Take Picture", @"Choose From Gallery", nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)txtOpenPicker:(UITextField *)textField
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
    [viewPicker selectRow:selectedGender inComponent:0 animated:YES];
    textField.inputView = viewPicker;
    textField.inputView.backgroundColor = [UIColor whiteColor];
}

- (void) txtDateTouch : (UITextField *) textField
{
    activeTextField = textField;
    if(viewPicker)
    {
        [viewPicker removeFromSuperview];
        viewPicker = nil;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-YYYY"];
    datePicker = [[UIDatePicker alloc] init];
    //    [datePicker setMaximumDate:now];
    datePicker.backgroundColor = [UIColor whiteColor];
    
    viewPicker.showsSelectionIndicator = YES;
    textField.inputView.backgroundColor = [UIColor whiteColor];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.date = [activeTextField.text length] > 0 ? [dateFormat dateFromString:activeTextField.text] : [NSDate date];
    datePicker.maximumDate = [NSDate date];
    
    strSelectedDate = [dateFormat stringFromDate:[datePicker date]];
    [datePicker addTarget:self action:@selector(updateTextFieldFromDate:)
         forControlEvents:UIControlEventValueChanged];
    [textField setInputView:datePicker];
    
}

-(void)updateTextFieldFromDate:(UIDatePicker *)sender
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-YYYY"];
    
    strSelectedDate = [dateFormat stringFromDate:[sender date]];
}

-(void) addToolBatOnTopOfTextField:(UITextField *) textField
{
    activeTextField = textField;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    UIImageView *img = [[UIImageView alloc]initWithFrame:toolbar.frame];
    //img.image = [UIImage imageNamed:@"LoginBG.png"];
    img.backgroundColor = [UIColor colorWithRed:159/255.0 green:111/255.0 blue:159/255.0 alpha:1.0];
    [toolbar addSubview:img];
    
    [toolbar sizeToFit];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelBtnTappedForResignKeyboard)];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
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
    if (activeTextField == txtGender)
        txtGender.text = [arrForGender objectAtIndex:selectedGender];
    else if (activeTextField == txtDOB)
        txtDOB.text = strSelectedDate;
    
    activeTextField = nil;
    [self.view endEditing:YES];
}

-(void) cancelBtnTappedForResignKeyboard
{
    activeTextField = nil;
    [self.view endEditing:YES];
}

#pragma mark - Action Buttons -

- (IBAction)btnBackClick:(id)sender
{
    backAction()
}

- (IBAction)btnProPicClick:(id)sender
{
    [self openImagePicker];
}

- (IBAction)btnSignUpClick:(id)sender
{
    if ([txtFullname.text length] <= 0)
    {
        callAlert(self, txtFullname, @"Please enter fullname");
    }
    else if ([txtEmail.text length] <= 0)
    {
        callAlert(self, txtEmail, @"Please enter email");
    }
    else if (![GeneralClass validateEmailAddress:txtEmail.text])
    {
        callAlert(self, txtEmail, @"Please enter valid email address");
    }
    else if ([txtPassword.text length] <= 0)
    {
        callAlert(self, txtPassword, @"Please enter password");
    }
//    else if ([txtGender.text length] <= 0)
//    {
//        callAlert(self, txtGender, @"Please select gender");
//    }
    else if ([txtDOB.text length] <= 0)
    {
        callAlert(self, txtDOB, @"Please select date of birth");
    }
    else
    {
        
        NSArray *arr = [txtFullname.text componentsSeparatedByString:@" "];
        
        if (arr.count>0)
        {
         
            strXMPPJid = [arr objectAtIndex:0];
        }
        else
        {
            strXMPPJid = @"";
        }
        
        
        
        
        
        [self callWebserviceForSignUp];
    }
}

-(void)XMPPRegisteration :(NSString *)strUserId
{
    NSLog(@"%@",[NSString stringWithFormat:@"%@_%@",strXMPPJid,strUserId]);
    
    [self callWebserviceForUpdateXMPPid:[NSString stringWithFormat:@"%@_%@",strXMPPJid,strUserId] WithUserID:strUserId];
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
    if ([@"" isEqualToString:@"SignUp"])
    {
        if ([strcode isEqualToString:@"1"])
        {
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setValue:[[[returnArry objectAtIndex:0] valueForKey:@"result"] objectAtIndex:0] forKey:@"USERINFO"];
//            
//          
//            APP_DELEGATE.isCalled = TRUE;
//            
//            regiUserJID = [NSString stringWithFormat:@"%@_%@",strXMPPJid,[[defaults valueForKey:@"USERINFO"] objectForKey:@"user_id"]];
//            
//            [defaults setValue:[NSString stringWithFormat:@"%@@52.45.76.95",regiUserJID] forKey:@"kXMPPmyJID"];
//            [defaults setValue:@"123" forKey:@"kXMPPmyPassword"];
//            [defaults setValue:txtFullname.text forKey:@"UserName"];
//            [defaults setValue:APP_DELEGATE.dataImage forKey:@"UserImage"];
//            [defaults setValue:@"YES" forKey:@"isSignUp"];
//            [defaults synchronize];
//            
//            APP_DELEGATE.strForUserID = [NSString stringWithFormat:@"%@",[[defaults valueForKey:@"USERINFO"] objectForKey:@"user_id"]];
//            APP_DELEGATE.strForToken = [NSString stringWithFormat:@"%@",[[defaults valueForKey:@"USERINFO"] objectForKey:@"token"]];
//            
//            
//            
//            
//            [self callWebserviceForDeviceRegister];
//            
//            NSLog(@"%@",[defaults objectForKey:@"USERINFO"]);
//            NSLog(@"Login user ID == %@", APP_DELEGATE.strForUserID);
//            NSLog(@"Token == %@", APP_DELEGATE.strForToken);
            
            
            UIAlertController *alertCont = [UIAlertController alertControllerWithTitle:@"Almost done!" message:@"Let's confirm your email. Just click on the link in the email we sent you." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                backAction()
            }];
            [alertCont addAction:ok];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertCont animated:YES completion:nil];
            });
        }
        else if ([strcode isEqualToString:@"0"])
        {
            callAlert(self, txtEmail, @"Email is already exists.");
        }
        else if ([strcode isEqualToString:@"-1"])
        {
            showAlert(AlertTitle, @"Please try again to submit data to our system");
        }
        else
        {
            showAlert(AlertTitle, AlertServerError);
        }
    }
    
}

-(void)JoinGroup
{
   
}

-(void)webServiceFailure
{
    [SVProgressHUD dismiss];
}

-(void) callWebserviceForSignUp
{
    NSString *genderID;
    if ([txtGender.text length] <= 0)
        genderID = @"";
    else if ([txtGender.text isEqualToString:[arrForGender objectAtIndex:0]])
        genderID = @"1";
    else
        genderID = @"2";
    
    
    NSDictionary *dict  = [[NSDictionary alloc]init];
    dict = @{
             @"full_name" : txtFullname.text,
             @"email" : txtEmail.text,
             @"gender" : genderID,
             @"password" : txtPassword.text,
             @"dob": txtDOB.text,
             @"user_image" : ([strUserImageData length] == 0 ? @"":strUserImageData),
             @"xmppId" : @"",
             @"date": [GeneralClass getCurrentDateAndTime]
             };
    
    [SVProgressHUD show];
    NSString *SignUp = [NSString stringWithFormat:@"%@register.php",MAINURL];
    SignUp = [SignUp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"SignUp webservice ------->> %@ ",SignUp);
    APP_DELEGATE.webServiceObject._delegate = self;
    [APP_DELEGATE.webServiceObject callWebService:SignUp dictionaryWithData:dict withType:@"POST"];
}

-(void) callWebserviceForDeviceRegister
{
  
}

-(void) callWebserviceForUpdateXMPPid:(NSString *) strXMPPid WithUserID:(NSString *) strUserID
{
    NSString *updateLocation = [NSString stringWithFormat:@"%@updateJabberId.php?user_id=%@&xmppId=%@&date=%@", MAINURL, strUserID, strXMPPid, [GeneralClass getCurrentDateAndTime]];
    updateLocation = [updateLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"XMPPP webservice ------->> %@ ",updateLocation);
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *params = nil;
    [requestManager GET:updateLocation parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSString *returnString=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSString *returnString1=[returnString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
         returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
         returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
         returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#034;" withString:@"\""];
         
     }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
}


-(void) callWebserviceForExploreScreen
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *post = [NSString stringWithFormat:@"user_id=%@&city=%@&zipcode=%@&date=%@", @"", @"", @"", [GeneralClass getCurrentDateAndTime]];
    NSLog(@"@====>>> %@", post);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://companyname/servername/admin/api/explore.php"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection)
    {
        self.responseData = [NSMutableData data];
    }
    else
        NSLog(@"Connection Failed!");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [SVProgressHUD dismiss];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSMutableArray *responseArr = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:nil];
    
    NSString *strcode=[NSString stringWithFormat:@"%@",[[responseArr valueForKey:@"code"]objectAtIndex:0]];
    //NSLog(@"jsonDictionary => %@", responseArr);
    
    if ([strcode isEqualToString:@"1"])
    {
    }
    else if ([strcode isEqualToString:@"-2"] || [strcode isEqualToString:@"-1"])
    {
        [GeneralClass displayAlertForInvalidUserOrTokenWhereMessage:AlertInValidToken onViewcon:self];
    }
    else
    {
        //  showAlert(AlertTitle, AlertServerError);
    }
    
    
}

#pragma mark - didReceiveMemoryWarning -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
