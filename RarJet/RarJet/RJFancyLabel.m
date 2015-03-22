//
//  RJFancyLabel.m
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "RJFancyLabel.h"
#import "RJRandomColorGenerator.h"

//static const NSTimeInterval RJAnimationInterval = 10.0;

@interface RJFancyLabel()

@end

@implementation RJFancyLabel

- (instancetype)initWithText:(NSString *)text {
    self = [super initWithFrame:CGRectZero];
    if (self != nil) {
        self.font = [UIFont boldSystemFontOfSize:20.f];
        self.textColor = [UIColor whiteColor];
        self.text = text;
        [self sizeToFit];
    }
    return self;
}

@end
