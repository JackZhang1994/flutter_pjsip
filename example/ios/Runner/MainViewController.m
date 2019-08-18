//
//  MainViewController.m
//  Runner
//
//  Created by gejianmin on 2019/8/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
@end
