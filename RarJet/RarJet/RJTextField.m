//
//  RJTextField.m
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "RJTextField.h"

@implementation RJTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    //all textfields in the app should look similar
    self.tintColor = [UIColor redColor];
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:24.f];
    self.borderStyle = UITextBorderStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    
    UILabel *leftLabel = [UILabel new];
    [leftLabel setFont:[UIFont italicSystemFontOfSize:20.f]];
    [leftLabel setTextColor:self.textColor];
    [leftLabel setText:self.placeholder];
    [leftLabel sizeToFit];
    [self setLeftView:leftLabel];
    [self setLeftViewMode:UITextFieldViewModeAlways];
    self.placeholder = @"";
}

@end
