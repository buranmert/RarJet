//
//  RJLocationManager.m
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "RJLocationManager.h"
#import <UIKit/UIApplication.h>
#import <CoreLocation/CoreLocation.h>

static const CLLocationDistance RJThresholdDistance = 250.0;

@interface RJLocationManager() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation RJLocationManager

+ (instancetype)manager
{
    static id instance;
    static dispatch_once_t onceTokenSharedInstance;
    dispatch_once(&onceTokenSharedInstance, ^{
        instance = [self new];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        CLLocation *defaultLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0]; //default value to be used until current location is determined
        _currentLocation = defaultLocation;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; //no need for high precision
        if ([RJLocationManager isAuthorized] == NO) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    //no need to explicitly call [super dealloc], ARC takes care of it
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self.locationManager stopUpdatingLocation];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self.locationManager startUpdatingLocation];
}

+ (BOOL)isAuthorized {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    _currentLocation = newLocation;
    if ([newLocation distanceFromLocation:oldLocation] < RJThresholdDistance) { //no need to determine current location with too high precision
        [self.locationManager stopUpdatingLocation];
    }
}

@end
