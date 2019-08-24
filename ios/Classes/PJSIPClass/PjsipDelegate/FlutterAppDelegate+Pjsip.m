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
/** pjsip登出*/
#define method_pjsip_logout  @"method_pjsip_logout"
/** pjsip销毁*/
#define method_pjsip_deinit  @"method_pjsip_deinit"


@implementation FlutterAppDelegate (Pjsip)

- (void)setupPjsip:(UIApplication *)launchOptions rootController:(UIViewController *)rootController{
    
    [self methodChannelFunctionWithRootController:rootController];
    
}
- (void)methodChannelFunctionWithRootController:(UIViewController *)rootController{
    //创建 FlutterMethodChannel
    
    FlutterMethodChannel* methodChannel = [FlutterMethodChannel
                                           methodChannelWithName:flutterMethodChannel binaryMessenger:(FlutterViewController *)rootController];
    //设置监听
    [methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // TODO
        NSString *method=call.method;
        /*
         ip = "117.78.34.48";
         password = "123@jvtd";
         port = 6050;
         username = 1012;
         */
        PJSIPModel * model = [[PJSIPModel alloc]init];
        NSDictionary * dict = (NSDictionary *)call.arguments;
        model.phone = [dict objectForKey:@"ip"];
        if ([method isEqualToString:method_pjsip_init]) {/** 初始化*/
            [PJSipManager manager];
            result(@"初始化成功");
        }else if ([method isEqualToString:method_pjsip_login]) {/** 登录*/
            result(@"present返回到flutter");
            PJSIPModel * model = [[PJSIPModel alloc]init];
            NSDictionary * dict = (NSDictionary *)call.arguments;
            model.sipIp = [dict objectForKey:@"ip"];
            model.sip_port = [dict objectForKey:@"port"];
            model.nickName = [dict objectForKey:@"username"];
            model.password = [dict objectForKey:@"password"];
            NSLog(@"返回值%@",call.arguments);//[dict objectForKey:@"username"
            if ([[PJSipManager manager] registerAccountWithName:@"1010" password:[dict objectForKey:@"password"] IPAddress:[NSString stringWithFormat:@"%@:%@",[dict objectForKey:@"ip"],[dict objectForKey:@"port"]]]) {
                NSLog(@"登陆成功");
            }else{
                NSLog(@"登陆失败");
            }
        }else if ([method isEqualToString:method_pjsip_call]) {/** 拨打电话*/
//            PJSIPViewController *vc = [[PJSIPViewController alloc] init];
//            PJSIPModel * model = [[PJSIPModel alloc]init];
//            NSDictionary * dict = (NSDictionary *)call.arguments;
//            model.sipIp = [dict objectForKey:@"ip"];
//            model.sip_port = [dict objectForKey:@"port"];
//            model.nickName = [dict objectForKey:@"username"];
//            model.password = [dict objectForKey:@"password"];
//            model.phone = [dict objectForKey:@"username"];
//            vc.model = model;
//            //vc.dict = call.arguments;
//            [rootController presentViewController:vc animated:NO completion:nil];
            [[PJSipManager manager] dailWithPhonenumber:[dict objectForKey:@"username"]];
            
            result(@"present返回到flutter");
        }else if ([method isEqualToString:method_pjsip_logout]) {/** 登出*/
            if ([[PJSipManager manager]logOut]) {
                result(@(YES));
            }else{
                result(@(NO));

            }
//            [[PJSipManager manager]logOut];//暂时用销毁

            result(@"present返回到flutter");
        }else if ([method isEqualToString:method_pjsip_deinit]) {/** 销毁*/
            [PJSipManager attempDealloc];
            result(@"present返回到flutter");
        }
    }];
}


@end
