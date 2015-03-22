//
//  RJLocation.m
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "RJLocation.h"
#import "RJLocationManager.h"
#import <CoreLocation/CLLocation.h>

static NSString * const RJFullNameKey = @"fullName";
static NSString * const RJLocationKey = @"geo_position";
static NSString * const RJLatitudeKey = @"latitude";
static NSString * const RJLongitudeKey = @"longitude";

@implementation RJLocation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self != nil) {
        _fullName = [dictionary objectForKey:RJFullNameKey];
        NSDictionary *locationDictionary = [dictionary objectForKey:RJLocationKey];
        double latitude = [[locationDictionary objectForKey:RJLatitudeKey] doubleValue];
        double longitude = [[locationDictionary objectForKey:RJLongitudeKey] doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocation *currentLocation = [[RJLocationManager manager] currentLocation];
        double distance = [location distanceFromLocation:currentLocation];
        _distance = distance;
    }
    return self;
}

@end
