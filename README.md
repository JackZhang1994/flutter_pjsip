# flutter_pjsip

A new Flutter plugin.

 Flutter插件集成PJSIP说明文档（iOS及Android 端）
@[TOC](Flutter插件集成PJSIP说明文档（iOS及Android 端）)
## 实现方式
 本PJSIP插件是以flutter的Dart语言实现页面功能，iOS和Android以原生方式集成PJSIP的SDK，flutter与原生之间以信号通道的方式进行交互，已实现PJSIP的网络拨打电话功能。

## Flutter调原生信号通道
  信号通道名称
 ```javascript
 /** 信号通道*/
 flutter_pjsip
  ```
## Flutter 传值给原生方法名
方法名
 ```javascript
1./** pjsip初始化*/
method_pjsip_init
2./** pjsip登录*/
method_pjsip_login
3./** pjsip拨打电话*/
method_pjsip_call
4./** pjsip登出*/
method_pjsip_logout
5./** pjsip销毁*/
method_pjsip_deinit
6./** 接收电话*/
method_pjsip_receive
7./** 挂断&&拒接*/
method_pjsip_refuse
8./** 免提*/
method_pjsip_audioSession
9./** 静音*/
method_pjsip_muteMicrophone
 ```

## 原生调Flutter信号通道
  信号通道名称
 ```javascript
 /** 信号通道*/
 native_pjsip
  ```


 ##   原生传值给Flutter

  PJSIP里所有的回调状态
 ```javascript
 /**
 * This enumeration describes invite session state.
 */
typedef enum pjsip_inv_state
{
    PJSIP_INV_STATE_NULL,	    /**< Before INVITE is sent or received  */
    PJSIP_INV_STATE_CALLING,	    /**< After INVITE is sent		    */
    PJSIP_INV_STATE_INCOMING,	    /**< After INVITE is received.	    */
    PJSIP_INV_STATE_EARLY,	    /**< After response with To tag.	    */
    PJSIP_INV_STATE_CONNECTING,	    /**< After 2xx is sent/received.	    */
    PJSIP_INV_STATE_CONFIRMED,	    /**< After ACK is sent/received.	    */
    PJSIP_INV_STATE_DISCONNECTED,   /**< Session is terminated.		    */
} pjsip_inv_state;
  ```
这里原生会以json串的形式传值给Flutter，Flutter会根据不同的value值处理相应的事件
 ```javascript
例如：{  callStatusChanged: @(PJSIP_INV_STATE_CONNECTING) }
这里对应的key值有七个状态，都包含：
   PJSIP_INV_STATE_NULL,	    		/**< 在发送或接收邀请之前  */
   PJSIP_INV_STATE_CALLING,	   		 /**< 发送邀请后		    */
   PJSIP_INV_STATE_INCOMING,		 /**< 来电中	    */
   PJSIP_INV_STATE_EARLY,	   		 /**< 来电之前	    */
   PJSIP_INV_STATE_CONNECTING,	    /**响铃中	    */
   PJSIP_INV_STATE_CONFIRMED,	    /**<已确认	    */
   PJSIP_INV_STATE_DISCONNECTED,   /**已挂断或已拒绝    */
  ```

## PJSIP插件iOS端集成说明
1.配置本地依赖库
> CoreTelephony.framework
>AVFoundation.framework

2	在APPdelegate里引入头文件并调用

 ```javascript
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "MainViewController.h"
#import "FlutterAppDelegate+Pjsip.h" /** 需要导入的头文件*/
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    /** 设置主控制器继承FlutterViewController*/
    MainViewController * VC = [[MainViewController alloc]init];
    UINavigationController * NVC = [[UINavigationController alloc]initWithRootViewController:VC];
    [self.window setRootViewController:NVC];
    [self setupPjsip:application rootController:VC];/** 需要调用的方法*/
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
 ```
 3.运行cocoaPods
> pod install --verbose --no-repo-update

4.手动配置flutter的flutter_pjsip.xcconfig文件

需要保证flutter_pjsip.xcconfig文件与Pods-Runner.debug.xcconfig文件的`'GCC_PREPROCESSOR_DEFINITIONS'`和`'HEADER_SEARCH_PATHS'` 的配置高度一致，否者会报#include <pjsua-lib/pjsua.h>头文件找不到的错。





## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
