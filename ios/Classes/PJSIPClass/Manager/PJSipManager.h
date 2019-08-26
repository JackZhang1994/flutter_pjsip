//
//  ZDSipManager.h
//  test1111
//
//  Created by gjm on 2018/1/3.
//  Copyright © 2018年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>


//PJSIP_INV_STATE_NULL,        /**< Before INVITE is sent or received  */0
//PJSIP_INV_STATE_CALLING,        /**< After INVITE is sent            */1
//PJSIP_INV_STATE_INCOMING,        /**< After INVITE is received.        */2
//PJSIP_INV_STATE_EARLY,        /**< After response with To tag.        */3
//PJSIP_INV_STATE_CONNECTING,        /**< After 2xx is sent/received.        */4
//PJSIP_INV_STATE_CONFIRMED,        /**< After ACK is sent/received.        */5
//PJSIP_INV_STATE_DISCONNECTED,   /**< Session is terminated.            */6
//} pjsip_inv_state;

typedef NS_ENUM(NSUInteger, CallStatusType) {
    CallStatusTypeUnknown = -1,
    CallStatusTypeNULL = 0,
    CallStatusTypeCalling = 1,// 响铃中
    CallStatusTypeIncoming = 2,//来电 响铃中
    CallStatusTypeEarly = 3,//通话之前
    CallStatusTypeConnecting = 4,//通话中
    CallStatusTypeConfirmed = 5,
    CallStatusTypeDisconnected = 6,//通话结束
};

@protocol ZDSipManagerDelegate <NSObject>
// 电话状态回调
- (void)sipmanager:(id)manager callstatus:(CallStatusType)callstatus;

@end
@interface PJSipManager : NSObject

//单例服务
+ (instancetype)manager;
//销毁单例
+(void)attempDealloc;
//登录
- (BOOL)registerAccountWithName:(NSString *)name password:(NSString *)password IPAddress:(NSString *)ipaddress;
//搭建环境
- (BOOL)create;
//拨号
- (void)dailWithPhonenumber:(NSString *)phonenumber;

@property(nonatomic,strong) FlutterMethodChannel* methodChannel;

/**
 拨打电话

 @param delelgate 代理
 @param phonenumber 对方电话号码
 @param name 分机号 e.g. 9123
 @param password 密码 e.g. 557921
 @param ipaddress ID地址和端口号 e.g. 116.62.54.47:8890
 */
- (void)dailWithDelegate:(id)delelgate phonenumber:(NSString *)phonenumber Name:(NSString *)name password:(NSString *)password IPAddress:(NSString *)ipaddress;
//电话挂起并销毁
- (void)hangup;
//去电挂断
- (void)callingHangup;
//来电挂断
- (void)inComingHangup;

//来电接听
-(void)incommingCallReceive;
//来电拒绝
-(void)icncommingCallRefuse;
// 静音
- (void)muteMicrophone;

// 取消静音
- (void)unmuteMicrophone;
//退出登录
-(BOOL)logOut;
//免提
-(void)setAudioSession;

@end
