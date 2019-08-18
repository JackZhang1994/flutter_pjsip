//
//  FlutterAppDelegate+Pjsip.h
//  Runner
//
//  Created by gejianmin on 2019/8/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>
#import "PJSipManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlutterAppDelegate (Pjsip)<ZDSipManagerDelegate>

- (void)setupPjsip:(UIApplication *)launchOptions rootController:(UIViewController *)rootController;

@end

NS_ASSUME_NONNULL_END
