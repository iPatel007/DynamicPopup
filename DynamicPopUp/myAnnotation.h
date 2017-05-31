//
//  MyAnnotation.h
//  VestinMe
//
//  Created by iPatel on 14/10/14.
//  Copyright (c) 2014iPatel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface myAnnotation : NSObject <MKAnnotation>
{    
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString *strTitle;
@property (nonatomic, copy) NSString *strSubtitle;
@property (nonatomic, strong) UIImage *imgOfPin;
@property (nonatomic, strong) NSMutableDictionary *pinDic;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
