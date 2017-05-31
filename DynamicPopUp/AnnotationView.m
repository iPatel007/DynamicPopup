//
//  AnnotationView.m
//  AdjustRegionToFitAnnotationCallout
//
//  Created by Stanislaw Pankevich on 17/12/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import "AnnotationView.h"

@implementation AnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];

    return self;
}

- (CGRect)annotationViewWithCalloutViewFrame {
    CGRect annotationViewWithCalloutViewFrame = self.frame;

    annotationViewWithCalloutViewFrame.size.width += CGRectGetWidth(self.frame) * 2;
    annotationViewWithCalloutViewFrame.size.height += CGRectGetHeight(self.frame) * 2;

    return annotationViewWithCalloutViewFrame;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}

@end
