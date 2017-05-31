//
//  UINavigationController+RotationAllOrientation.m
//  DynamicPopUp
//
//  Created by iPatel on 5/28/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import "UINavigationController+RotationAllOrientation.h"

@implementation UINavigationController (RotationAllOrientation)


- (BOOL)shouldAutorotate
{
    UIViewController *top = self.topViewController;
    return [top shouldAutorotate];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    UIViewController *top = self.topViewController;
    return top.supportedInterfaceOrientations;
}


@end
