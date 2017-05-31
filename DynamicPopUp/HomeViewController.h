//
//  HomeViewController.h
//  DynamicPopUp
//
//  Created by iPatel on 5/27/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iDynamicPopup.h"

@interface HomeViewController : UIViewController <iDynamicPopupDelegate>
{
    iDynamicPopup *customPopup;
}

@end
