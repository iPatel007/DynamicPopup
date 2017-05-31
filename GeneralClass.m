//
//  GeneralClass.m
//  GraffitiMap
//
//  Created by iPatel on 12/28/12.
//  Copyright (c) 2012iPatel. All rights reserved.
//

#import "GeneralClass.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"


#define APIBASEURL @"http://www.MYURL/api"

@implementation GeneralClass

+ (NSString *) getDocumentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
}

+ (NSMutableURLRequest *) generateRequestForAPI:(NSString *) api withParameters:(NSString *) strParams
{
    NSString *postString = [NSString stringWithFormat:@"%@&addAnotherParam=%@", strParams, @"AnotherParamValue"];
    postString = [NSString stringWithFormat:@"%@&signature=%@", postString, [GeneralClass hashedValue:@"private_key" andData:postString]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/", APIBASEURL, api];
    NSMutableURLRequest *requestToServer =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [requestToServer setHTTPMethod:@"POST"];
    [requestToServer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    const char *utfString = [postString UTF8String];
    NSString *utfStringLenString = [NSString stringWithFormat:@"%zu", strlen(utfString)];
    [requestToServer setHTTPBody:[NSData dataWithBytes: utfString length:strlen(utfString)]];
    
    [requestToServer setValue:utfStringLenString forHTTPHeaderField:@"Content-Length"];
    
    return requestToServer;
}

+ (NSString *) hashedValue :(NSString *) key andData: (NSString *) data
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    NSMutableString* output = [NSMutableString   stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
}

+(UIColor *)colorWithHexString:(NSString *)stringColor
{
    if ([stringColor isKindOfClass:[NSString class]] && [stringColor hasPrefix:@"#"] && [stringColor length] == 7)
    {
        unsigned long red, green, blue;
        sscanf([stringColor UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
        UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
        return color;
    }
    return [UIColor blackColor];
}

+ (UIColor*) getRGBColorFromImage:(UIImage*)image atX:(int)xx andY:(int)yy
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int byteIndex = (int)((bytesPerRow * yy) + xx * bytesPerPixel);
    CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
    CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
    CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
    byteIndex += 4;
    UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    free(rawData);
    return acolor;
}

+ (void) setDynamicHeightOfButton:(UIButton *) myButton withFont:(UIFont *) fontText andDefaultHeightOfButton:(CGFloat) defaultHeight
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:(myButton.titleLabel.text ? myButton.titleLabel.text : @"") attributes:@{ NSFontAttributeName: fontText}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){myButton.frame.size.width, 9999} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if(rect.size.height > defaultHeight)
        myButton.frame = CGRectMake(myButton.frame.origin.x, myButton.frame.origin.y+2, myButton.frame.size.width, rect.size.height+2);
    else
        myButton.frame = CGRectMake(myButton.frame.origin.x, myButton.frame.origin.y, myButton.frame.size.width, 22);
}


+ (void) setDynamicHeightOfLabel:(UILabel *) myLabel withFont:(UIFont *) fontText andDefaultHeightOfLabel:(CGFloat) defaultHeight
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:(myLabel.text ? myLabel.text : @"") attributes:@{ NSFontAttributeName: fontText}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){myLabel.frame.size.width, 9999} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if(rect.size.height > defaultHeight)
        myLabel.frame = CGRectMake(myLabel.frame.origin.x, myLabel.frame.origin.y, myLabel.frame.size.width, rect.size.height + 1);
}

+ (CGFloat) getHeightOfLabel:(UILabel *) myLabel withFont:(UIFont *) fontText
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:(myLabel.text ? myLabel.text : @"") attributes:@{ NSFontAttributeName: fontText}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){myLabel.frame.size.width, 9999} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rect.size.height;
}

+ (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize
{
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (NSString *) getProperFormationOfDate:(NSString *) startDate andTime:(NSString *) strTime
{
    BOOL isCrash = NO;
    @try
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *eventStartDate = [dateFormatter dateFromString:startDate];
        
        NSDateFormatter *formaterForDate = [[NSDateFormatter alloc] init];
        [formaterForDate setDateFormat:@"d MMM yyyy"];
        NSString *dateString = [formaterForDate stringFromDate:eventStartDate];
        NSArray*tempStringArr = [dateString componentsSeparatedByString:@" "];
        
        NSMutableString *tempDate = [[NSMutableString alloc]initWithString:[tempStringArr objectAtIndex:0]];
        int day = [[tempStringArr objectAtIndex:0] intValue];
        
        switch (day) {
            case 1:
            case 21:
            case 31:
                [tempDate appendString:@"st"];
                break;
            case 2:
            case 22:
                [tempDate appendString:@"nd"];
                break;
            case 3:
            case 23:
                [tempDate appendString:@"rd"];
                break;
            default:
                [tempDate appendString:@"th"];
                break;
        }
        
        NSString *strDay = [tempDate stringByAppendingString:@" "];
        NSString *strMonth = [strDay stringByAppendingString:[tempStringArr objectAtIndex:1]];
        NSString *strYear = [strMonth stringByAppendingString:@" "];
        NSString *finalDate = [strYear stringByAppendingString:[tempStringArr objectAtIndex:2]];
        
        NSDateFormatter *formaterForTime = [[NSDateFormatter alloc] init];
        [formaterForTime setDateFormat:@"HH : mm"];
        NSDate *dateForTime = [formaterForTime dateFromString:strTime];
        [formaterForTime setDateFormat:@"HH:mm"];
        NSString *finalTime = [formaterForTime stringFromDate:dateForTime];
        if([finalTime length] == 0)
            finalTime = strTime;
        
        NSString *finalDateAndTime = [finalDate stringByAppendingString:[NSString stringWithFormat:@" at %@", finalTime]];
        
        return finalDateAndTime;
    }
    @catch (NSException *exception) {
        
        isCrash = YES;
    }
    @finally {
        
        if(isCrash)
        {
            NSString *finalDateAndTime = [startDate stringByAppendingString:[NSString stringWithFormat:@" at %@", strTime]];
            return finalDateAndTime;
        }
    }
    isCrash = NO;
}

+ (NSString *) getProperFormationOfDate:(NSString *) eventDate
{
    BOOL isCrash = NO;
    @try
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *eventStartDate = [dateFormatter dateFromString:eventDate];
        
        NSDateFormatter *formaterForDate = [[NSDateFormatter alloc] init];
        [formaterForDate setDateFormat:@"d MMM yyyy"];
        NSString *dateString = [formaterForDate stringFromDate:eventStartDate];
        NSArray*tempStringArr = [dateString componentsSeparatedByString:@" "];
        
        NSMutableString *tempDate = [[NSMutableString alloc]initWithString:[tempStringArr objectAtIndex:0]];
        int day = [[tempStringArr objectAtIndex:0] intValue];
        
        switch (day) {
            case 1:
            case 21:
            case 31:
                [tempDate appendString:@"st"];
                break;
            case 2:
            case 22:
                [tempDate appendString:@"nd"];
                break;
            case 3:
            case 23:
                [tempDate appendString:@"rd"];
                break;
            default:
                [tempDate appendString:@"th"];
                break;
        }
        
        NSString *strDay = [tempDate stringByAppendingString:@" "];
        NSString *strMonth = [strDay stringByAppendingString:[tempStringArr objectAtIndex:1]];
        NSString *strYear = [strMonth stringByAppendingString:@" "];
        NSString *finalDate = [strYear stringByAppendingString:[tempStringArr objectAtIndex:2]];
        
        return finalDate;
    }
    @catch (NSException *exception) {
        isCrash = YES;
    }
    @finally {
        if(isCrash)
            return eventDate;
    }
    isCrash = NO;
}

+ (NSString *)encodeImageToBase64String:(UIImage *)image
{
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (NSString *) getCurrentDateAndTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-ddhh:mm:ss"];
    NSDate *dt = [NSDate date];
    NSString * strCurrentTime = [formatter stringFromDate:dt];
    return strCurrentTime;
}

+ (void)setTextFieldPlaceHolderColor:(UITextField *)textfield
{
    textfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textfield.placeholder attributes:@{NSForegroundColorAttributeName: textfield.textColor}];
}

+ (NSString *) getConvertServerDateTimeToLocalDeviceDateTime:(NSString *) strDateTime
{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter1 dateFromString:strDateTime];
    NSLog(@"date : %@",date);
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date];
    
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"dd-MMM-yyyy hh:mm"];
    [dateFormatters setDateStyle:NSDateFormatterShortStyle];
    [dateFormatters setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatters setDoesRelativeDateFormatting:YES];
    [dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
    strDateTime = [dateFormatters stringFromDate: destinationDate];
    NSLog(@"Local DateTime : %@", strDateTime);
    
    return strDateTime;
}

+ (void) setLoderOnImageViewWhereImageView:(UIImageView *) imgView andImageURL:(NSString *) strImgUrl withCustomFrame:(BOOL) isCustomFrame andCustomFrame:(CGRect) newFrame andLoderColor:(UIColor *) loderColor andPlaceHolderImage:(UIImage *) placeHolderImg
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if(!isCustomFrame)
        spinner.frame = CGRectMake((imgView.frame.size.width - 22)/2, (imgView.frame.size.height - 22)/2, 22, 22);
    else
        spinner.frame = newFrame;
    
    [spinner setColor:loderColor];
    [imgView addSubview:spinner];
    [spinner startAnimating];
    
    NSURL *imgURL = [NSURL URLWithString:[strImgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [imgView sd_setImageWithURL:imgURL
               placeholderImage:placeHolderImg
                        options:SDWebImageContinueInBackground
                       progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                          [spinner stopAnimating];
                      }];
}

+ (void)setNotificationBadge:(UILabel *)lblForBadge andStrBadge:(NSString *) strBadgeCount
{
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"badgeOfNotification"];
    //    [[NSUserDefaults standardUserDefaults] setObject:strBadgeCount forKey:@"badgeOfNotification"];
    //    APP_DELEGATE.strNotificationCount = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"badgeOfNotification"]];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //    if ([APP_DELEGATE.strNotificationCount intValue] > 0)
    //    {
    //        lblForBadge.text = [NSString stringWithFormat:@"%@", APP_DELEGATE.strNotificationCount];
    //        [lblForBadge setHidden:NO];
    //    }
    //    else
    //    {
    //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"badgeOfNotification"];
    //        lblForBadge.text = @"";
    //        [lblForBadge setHidden:YES];
    //    }
}

+ (void) displayAlertForInvalidUserOrTokenWhereMessage:(NSString *) strMessage onViewcon:(UIViewController *) viewCon
{
//    UIAlertController *alertCont = [UIAlertController alertControllerWithTitle:AlertTitle message:strMessage preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
//                         {
//                             APP_DELEGATE.isCalled = TRUE;
//                             NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
//                             NSDictionary * dict = [userDefault dictionaryRepresentation];
//                             for (id key in dict)
//                             {
//                                 if(![key isEqualToString:@"currentZipcode"] || ![key isEqualToString:@"currentCityName"])
//                                     [userDefault removeObjectForKey:key];
//                             }
//                             [userDefault synchronize];
//                             
//                             APP_DELEGATE.strForUserID = @"";
//                             APP_DELEGATE.strForToken = @"";
//                             APP_DELEGATE.strHandleSocial = @"";
//                             
//                             
//                             [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
//                             [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
//                             [[UIApplication sharedApplication] unregisterForRemoteNotifications];
//                             
//                             
//                             BOOL found = NO;
//                             for (UIViewController *controller in viewCon.navigationController.viewControllers)
//                             {
//                                 if ([controller isKindOfClass:[LoginViewController class]])
//                                 {
//                                     [viewCon.navigationController popToViewController:controller animated:NO];
//                                     found = YES;
//                                     break;
//                                 }
//                             }
//                             if (!found)
//                             {
//                                 LoginViewController *loginViewCon = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
//                                 [viewCon.navigationController pushViewController:loginViewCon animated:NO];
//                             }
//                         }];
//    [alertCont addAction:ok];
//    [viewCon presentViewController:alertCont animated:YES completion:nil];
}

+ (void)openPopUpViewWhereDimView:(UIView *) dimView andInerView:(UIView *)innerView
{
    dimView.hidden = NO;
    innerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView animateWithDuration:0.3/1.5 animations:^{
        innerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            innerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                innerView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

+ (void)closePopUpViewWhereDimView:(UIView *) dimView andInerView:(UIView *)innerView
{
    innerView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3/1.5 animations:^{
        innerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            innerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        }completion:^(BOOL finished) {
            dimView.hidden = YES;
        }];
    }];
}

+ (NSAttributedString *)setAttributedString:(NSString *)str
{
    NSArray *arr = [str componentsSeparatedByString:@" : "];
    
    NSMutableAttributedString *attString =
    [[NSMutableAttributedString alloc]
     initWithString:[NSString stringWithFormat:@"%@ : ",[arr objectAtIndex:0]]];
    
    [attString addAttribute: NSForegroundColorAttributeName
                      value: [UIColor blackColor]
                      range: NSMakeRange(0,[attString length] )];
    
    NSMutableAttributedString *attString1 =
    [[NSMutableAttributedString alloc]
     initWithString:[arr objectAtIndex:1]];
    
    [attString1 addAttribute: NSForegroundColorAttributeName
                       value: [UIColor colorWithRed:241.0f/255.0f green:86.0f/255.0f blue:40.0f/255.0f alpha:1.0]
                       range: NSMakeRange(0,[attString1 length] )];
    
    [attString appendAttributedString:attString1];
    
    return attString;
}

+ (BOOL)validateEmailAddress:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (void)makeShadoForImageView:(UIImageView *) myImgView
{
    CALayer *layer = myImgView.layer;
    layer.shadowOpacity = 0.3;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 15;
}

+ (UIColor *) rgbColorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
