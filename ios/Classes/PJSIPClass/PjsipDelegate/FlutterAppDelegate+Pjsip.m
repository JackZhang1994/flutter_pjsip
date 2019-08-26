//
//  FlutterAppDelegate+Pjsip.m
//  Runner
//
//  Created by gejianmin on 2019/8/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "FlutterAppDelegate+Pjsip.h"
#import "PJSIPViewController.h"
#import "PJSIPModel.h"

/** 信号通道*/
#define flutterMethodChannel  @"flutter_pjsip"
/** pjsip初始化*/
#define method_pjsip_init  @"method_pjsip_init"
/** pjsip登录*/
#define method_pjsip_login  @"method_pjsip_login"
/** pjsip拨打电话*/
#define method_pjsip_call  @"method_pjsip_call"
/** 接收电话*/
#define method_pjsip_receive  @"method_pjsip_receive"
/** 挂断&&拒接*/
#define method_pjsip_refuse  @"method_pjsip_refuse"
/** 免提*/
#define method_pjsip_hands_free  @"method_pjsip_hands_free"
/** 静音*/
#define method_pjsip_mute  @"method_pjsip_mute"
/** pjsip登出*/
#define method_pjsip_logout  @"method_pjsip_logout"
/** pjsip销毁*/
#define method_pjsip_deinit  @"method_pjsip_deinit"

@implementation FlutterAppDelegate (Pjsip)

- (void)setupPjsip:(UIApplication *)launchOptions rootController:(UIViewController *)rootController{
    
    [self methodChannelFunctionWithRootController:rootController];
    
}
- (void)methodChannelFunctionWithRootController:(UIViewController *)rootController{
    
    FlutterMethodChannel* methodChannel = [FlutterMethodChannel
                                           methodChannelWithName:flutterMethodChannel binaryMessenger:(FlutterViewController *)rootController];
    [PJSipManager manager].methodChannel = methodChannel;
    //设置监听
    [methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        NSString *method=call.method;
        NSDictionary * dict = (NSDictionary *)call.arguments;
        if ([method isEqualToString:method_pjsip_init]) {/** 初始化*/
            [PJSipManager manager];
            result(@(YES));
        }else if ([method isEqualToString:method_pjsip_login]) {/** 登录*/
            NSLog(@"登录名称：%@",[dict objectForKey:@"username"]);
            if ([[PJSipManager manager] registerAccountWithName:[dict objectForKey:@"username"] password:[dict objectForKey:@"password"] IPAddress:[NSString stringWithFormat:@"%@:%@",[dict objectForKey:@"ip"],[dict objectForKey:@"port"]]]) {
                result(@(YES));
            }else{
                 result(@(NO));
            }
        }else if ([method isEqualToString:method_pjsip_call]) {/** 拨打电话*/
            NSLog(@"拨打的电话号码：%@",[dict objectForKey:@"username"]);
            [[PJSipManager manager] dailWithPhonenumber:[dict objectForKey:@"username"]];
            result(@(YES));
        }else if ([method isEqualToString:method_pjsip_receive]) {/** 接收电话*/
            [[PJSipManager manager] incommingCallReceive];
            result(@(YES));
        }else if ([method isEqualToString:method_pjsip_hands_free]) {/** 免提*/
            [[PJSipManager manager]setAudioSession];
            result(@(YES));
        }else if ([method isEqualToString:method_pjsip_mute]) {/** 静音*/
            [[PJSipManager manager] muteMicrophone];
            result(@(YES));
        }else if ([method isEqualToString:method_pjsip_refuse]) {/** 挂断&&拒接*/
            [[PJSipManager manager]hangup];
            result(@(YES));
        }else if ([method isEqualToString:method_pjsip_logout]) {/** 登出*/
            if ([[PJSipManager manager]logOut]) {
                result(@(YES));
            }else{
                result(@(NO));
            }
        }else if ([method isEqualToString:method_pjsip_deinit]) {/** 销毁*/
            [PJSipManager attempDealloc];
            result(@(YES));
        }
    }];
}


@end
