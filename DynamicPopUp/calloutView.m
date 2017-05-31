//
//  ArrwoView.m
//  ChatView
//
//  Created by iPatel on 7/13/16.
//  Copyright © 2016 iPatel. All rights reserved.
//

#import "calloutView.h"

#define kArrowHeight 15

@implementation calloutView


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float temp = kArrowHeight/4;
    float minus = 3;
    
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    [fillPath moveToPoint:CGPointMake(0, self.bounds.size.height-(kArrowHeight - minus))];
    [fillPath addLineToPoint:CGPointMake(kArrowHeight + temp, self.bounds.size.height-(kArrowHeight - minus))];
    [fillPath addLineToPoint:CGPointMake((kArrowHeight*1.5) + temp, self.bounds.size.height)];
    [fillPath addLineToPoint:CGPointMake((kArrowHeight*2) + temp, self.bounds.size.height-(kArrowHeight - minus))];
    [fillPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-(kArrowHeight - minus))];
    [fillPath addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [fillPath addLineToPoint:CGPointMake(0, 0)];
    [fillPath closePath];
    
    CGContextAddPath(context, fillPath.CGPath);
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([[[defaults valueForKey:@"USERINFO"] valueForKey:@"is_paid_user"] isEqualToString:@"0"])
//        CGContextSetFillColorWithColor(context, [GeneralClass rgbColorFromHexString:@"#035070"].CGColor);
//    else
//        CGContextSetFillColorWithColor(context, [GeneralClass rgbColorFromHexString:[[defaults objectForKey:@"USERINFO"] objectForKey:@"color_hexa"]].CGColor);
    
    CGContextSetFillColorWithColor(context, [GeneralClass rgbColorFromHexString:@"HAXA_COLOR_STRING"].CGColor);

    
    CGContextFillPath(context);
}


@end
