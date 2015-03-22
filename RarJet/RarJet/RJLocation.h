//
//  RJLocation.h
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJLocation : NSObject
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic) double distance; //i didn't want to import UIKit just to use CGFloat, double is fine too

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
