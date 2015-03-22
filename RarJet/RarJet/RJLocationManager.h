//
//  RJLocationManager.h
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface RJLocationManager : NSObject
@property (atomic, readonly) CLLocation *currentLocation;
+ (instancetype)manager;
+ (BOOL)isAuthorized;
@end
