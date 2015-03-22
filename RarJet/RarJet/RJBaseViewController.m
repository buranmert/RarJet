//
//  RJBaseViewController.m
//  RarJet
//
//  Created by Mert Buran on 22/03/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "RJBaseViewController.h"

@interface RJBaseViewController ()

@end

@implementation RJBaseViewController //for future-use. might have been useful if i implemented localization-on-the-fly

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"RarJet", nil);
}

@end
