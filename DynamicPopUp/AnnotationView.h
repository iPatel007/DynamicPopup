//
//  AnnotationView.h
//  AdjustRegionToFitAnnotationCallout
//
//  Created by Stanislaw Pankevich on 17/12/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AnnotationView : MKAnnotationView

@property (readonly) CGRect annotationViewWithCalloutViewFrame;


@end
