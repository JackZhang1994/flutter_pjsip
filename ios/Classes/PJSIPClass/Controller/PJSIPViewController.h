//
//  PJSIPViewController.h
//  Runner
//
//  Created by gejianmin on 2019/8/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CRMCallCenterView.h"
#import "PJSIPModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface PJSIPViewController : UIViewController
@property(nonatomic,strong) NSDictionary  * dict;
@property(nonatomic,assign) CRMCallCenterStype callCenterPhoneStype;
@property(nonatomic,strong) PJSIPModel * model;
@property (nonatomic, copy) void (^finishCallBlock)(BOOL isCallVC);

@property(nonatomic,assign)NSInteger callId;
@end
NS_ASSUME_NONNULL_END
