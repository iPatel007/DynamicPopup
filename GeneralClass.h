//
//  HomeViewController.m
//  DynamicPopUp
//
//  Created by iPatel on 5/27/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import "UIImageView+WebCache.h"

@interface GeneralClass : NSObject

+ (NSString *) getDocumentDirectory;

+ (NSMutableURLRequest *) generateRequestForAPI:(NSString *) api withParameters:(NSString *) strParams; // For send images with params is putted in "appDelegate.h" file

+ (UIColor *)colorWithHexString:(NSString *)stringColor;

+ (UIColor*) getRGBColorFromImage:(UIImage*)image atX:(int)xx andY:(int)yy;

+ (void) setDynamicHeightOfLabel:(UILabel *) myLabel withFont:(UIFont *) fontText andDefaultHeightOfLabel:(CGFloat) defaultHeight;

+ (void) setDynamicHeightOfButton:(UIButton *) myButton withFont:(UIFont *) fontText andDefaultHeightOfButton:(CGFloat) defaultHeight;

+ (CGFloat) getHeightOfLabel:(UILabel *) myLabel withFont:(UIFont *) fontText;

+ (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize;

+ (NSString *) getProperFormationOfDate:(NSString *) startDate andTime:(NSString *) strTime;

+ (NSString *) getProperFormationOfDate:(NSString *) eventDate;

+ (NSString *) encodeImageToBase64String:(UIImage *)image;

+ (NSString *) getCurrentDateAndTime;

+ (void)setTextFieldPlaceHolderColor:(UITextField *)textfield;

+ (NSString *) getConvertServerDateTimeToLocalDeviceDateTime:(NSString *) strDateTime;

+ (void) setLoderOnImageViewWhereImageView:(UIImageView *) imgView andImageURL:(NSString *) strImgUrl withCustomFrame:(BOOL) isCustomFrame andCustomFrame:(CGRect) newFrame andLoderColor:(UIColor *) loderColor andPlaceHolderImage:(UIImage *) placeHolderImg;

+ (void)setNotificationBadge:(UILabel *)lblForBadge andStrBadge:(NSString *) strBadgeCount;

+ (void) displayAlertForInvalidUserOrTokenWhereMessage:(NSString *) strMessage onViewcon:(UIViewController *) viewCon;

+ (void)openPopUpViewWhereDimView:(UIView *) dimView andInerView:(UIView *)innerView;
+ (void)closePopUpViewWhereDimView:(UIView *) dimView andInerView:(UIView *)innerView;

+ (NSAttributedString *)setAttributedString:(NSString *)str;
+ (BOOL)validateEmailAddress:(NSString*)email;

+ (void)makeShadoForImageView:(UIImageView *) myImgView;
+ (UIColor *) rgbColorFromHexString:(NSString *)hexString;

@end
