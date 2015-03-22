//
//  RJRandomColorGenerator.m
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "RJRandomColorGenerator.h"
#import <UIKit/UIColor.h>

@implementation RJRandomColorGenerator

+ (UIColor *)generateRandomColor {
    CGFloat r = arc4random_uniform(256)/255.f;
    CGFloat g = arc4random_uniform(256)/255.f;
    CGFloat b = arc4random_uniform(256)/255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}

@end
