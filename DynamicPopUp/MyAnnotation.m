//
//  MyAnnotation.m
//  VestinMe
//
//  Created by iPatel on 14/10/14.
//  Copyright (c) 2014iPatel. All rights reserved.
//

#import "myAnnotation.h"

@implementation myAnnotation

@synthesize coordinate;


-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    coordinate=coord;
    return self;
}

-(CLLocationCoordinate2D)coord
{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}

@end
