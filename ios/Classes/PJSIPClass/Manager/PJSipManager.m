//
//  ZDSipManager.m
//  test1111
//
//  Created by gjm on 2018/1/3.
//  Copyright © 2018年 ZYY. All rights reserved.
//

#import "PJSipManager.h"
#import "PJSIPViewController.h"
#import "PJSIPComingViewController.h"
#import "PJSIPModel.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <AVFoundation/AVFoundation.h>
#include <pjsua-lib/pjsua.h>
#import "AVSound.h"
//原生传给flutter
#define method_call_status_changed  @"method_call_state_changed"

// 来电冲突：CoreTelephony框架监听

static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata);
static void on_call_state(pjsua_call_id call_id, pjsip_event *e);
static void on_call_media_state(pjsua_call_id call_id);
static void on_reg_state(pjsua_acc_id acc_id);

@interface PJSipManager (){
    pjsua_call_id _call_id;
    pjsua_call_id _incommingcall_id;
    
    pjsua_conf_port_id pjsipConfAudioId;
}
@property (nonatomic,assign) BOOL  connecting;//已经在通话中
@property (nonatomic,assign) BOOL  isHangup;//已经挂断
@property (nonatomic,assign) BOOL  isMute;//是否静音
@property (nonatomic,strong) NSString * phoneNumber;
@property (nonatomic,weak) id <ZDSipManagerDelegate>delegate;
@property(nonatomic,strong)CTCallCenter * callCenter; //必须在这里声明，要不不会回调block



@end

@implementation PJSipManager
static PJSipManager * tmp = nil;
static dispatch_once_t onceToken;

+ (instancetype)manager {
    dispatch_once(&onceToken, ^{
        tmp = [[PJSipManager alloc] init];
        [tmp create];
        [tmp callCenter];
        
    });
    return tmp;
}

+(void)attempDealloc{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"login_account_id"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"server_uri"];
    onceToken = 0; // 只有置成0,GCD才会认为它从未执行过.它默认为0.这样才能保证下次再次调用shareInstance的时候,再次创建对象.
    tmp = nil;
}


- (BOOL)create {
    
    static NSInteger i = 1;
    tmp.isMute = NO;
//    NSLog(@"我执行了%ld次",i++);
    if (i > 2) {
        return YES;
    }
    //来电接听
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIncommingCall:) name:@"SIPIncomingCallNotification" object:nil];
    //电话状态监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCllStatusChanged:) name:@"SIPCallStatusChangedNotification" object:nil];
    
    //sip环境初始化
    pj_status_t status;
    // 创建SUA
    status = pjsua_create();
    
    if (status != PJ_SUCCESS) {
        NSLog(@"error create pjsua");
        return NO;
    }
    
    {
        // SUA相关配置
        pjsua_config cfg;
        pjsua_media_config media_cfg;
        pjsua_logging_config log_cfg;
        
        pjsua_config_default(&cfg);
        
        // 回调函数配置
        cfg.cb.on_incoming_call = &on_incoming_call; // 来电回调
        cfg.cb.on_call_media_state = &on_call_media_state; // 媒体状态回调（通话建立后，要播放RTP流）
        cfg.cb.on_call_state = &on_call_state; // 电话状态回调
        cfg.cb.on_reg_state = &on_reg_state; // 注册状态回调
        
        // 媒体相关配置
        pjsua_media_config_default(&media_cfg);
        media_cfg.clock_rate = 16000;
        media_cfg.snd_clock_rate = 16000;
        media_cfg.ec_tail_len = 0;
        
        // 日志相关配置
        pjsua_logging_config_default(&log_cfg);
        
#ifdef DEBUG
        log_cfg.msg_logging = PJ_TRUE;
        log_cfg.console_level = 4;
        log_cfg.level = 5;
#else
        log_cfg.msg_logging = PJ_FALSE;
        log_cfg.console_level = 0;
        log_cfg.level = 0;
#endif
        
        // 初始化PJSUA
        status = pjsua_init(&cfg, &log_cfg, &media_cfg);
        if (status != PJ_SUCCESS) {
            NSLog(@"error init pjsua");
            return NO;
        }
    }
    
    // udp transport
    {
        pjsua_transport_config cfg;
        pjsua_transport_config_default(&cfg);
        
        // 传输类型配置
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, NULL);
        if (status != PJ_SUCCESS) {
            NSLog(@"error add transport for pjsua");
            return NO;
        }
    }
    
    // 启动PJSUA
    status = pjsua_start();
    if (status != PJ_SUCCESS) {
        NSLog(@"error start pjsua");
        return NO;
    }
    return YES;
}
//登录
- (BOOL)registerAccountWithName:(NSString *)name password:(NSString *)password IPAddress:(NSString *)ipaddress {
    if (name.length == 0 ||
        password.length == 0 ||
        ipaddress.length == 0
        ) {
        return NO;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegisterStatus:) name:@"SIPRegisterStatusNotification" object:nil];
    
    //        [[NSUserDefaults standardUserDefaults] setInteger:[name integerValue] forKey:@"login_account_id"];
    [[NSUserDefaults standardUserDefaults] setObject:ipaddress forKey:@"server_uri"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    pjsua_acc_id acc_id;
    pjsua_acc_config cfg;
    
    // 调用这个函数来初始化帐户配置与默认值
    pjsua_acc_config_default(&cfg);
    cfg.id = pj_str((char *)[NSString stringWithFormat:@"sip:%@@%@", name, ipaddress].UTF8String);
    // 这是URL放在请求URI的注册，看起来就像“SIP服务提供商”。如果需要注册，则应指定此字段。如果价值是空的，没有帐户注册将被执行。
    cfg.reg_uri = pj_str((char *)[NSString stringWithFormat:@"sip:%@", ipaddress].UTF8String);
    // 在注册失败时指定自动注册重试的时间间隔,0禁用自动重新注册
    cfg.reg_retry_interval = 0;
    cfg.cred_count = 1;
    // 凭证数组。如果需要注册，通常至少应该有一个凭据指定，成功地对服务提供程序进行身份验证。可以指定更多的凭据，例如，当请求被期望在路由集中的代理受到挑战时。
    cfg.cred_info[0].realm = pj_str("*");
    cfg.cred_info[0].username = pj_str((char *)name.UTF8String);
    cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    cfg.cred_info[0].data = pj_str((char *)password.UTF8String);
    
    // 指定传入的视频是否自动显示在屏幕上
    //        cfg.vid_in_auto_show = PJ_TRUE;
    cfg.vid_in_auto_show = PJ_FALSE;
    // 设定当有视频来电，或拨出电话时，是否默认激活视频传出
    //        cfg.vid_out_auto_transmit = PJ_TRUE;
    cfg.vid_out_auto_transmit = PJ_FALSE;
    
    cfg.vid_cap_dev = PJMEDIA_VID_DEFAULT_CAPTURE_DEV;
    //偶尔出BUG
    pj_status_t status = pjsua_acc_add(&cfg, PJ_TRUE, &acc_id);
    if (status != PJ_SUCCESS) {
        NSString *errorMessage = [NSString stringWithFormat:@"登录失败，返回错误号：%d!", status];
        NSLog(@"register error: %@", errorMessage);
        return NO;
        
    }
    return YES;
}
-(BOOL)logOut{
    pjsua_acc_id acct_id = (pjsua_acc_id)[[NSUserDefaults standardUserDefaults] integerForKey:@"login_account_id"];
    pj_status_t status = pjsua_acc_del(acct_id &_call_id);
    if (status != PJ_SUCCESS) {
        NSString *errorMessage = [NSString stringWithFormat:@"退出登录失败，返回错误号：%d!", status];
        NSLog(@"register error: %@", errorMessage);
        return NO;
    }else{
        NSLog(@"退出登录成功，登录信息：%d", status);
    }
    return YES;
}
/** 登录状态监听*/
- (void)handleRegisterStatus:(NSNotification *)notification {
    pjsua_acc_id acc_id = [notification.userInfo[@"acc_id"] intValue];
    pjsip_status_code status = [notification.userInfo[@"status"] intValue];
    NSString *statusText = notification.userInfo[@"status_text"];
    
    if (status != PJSIP_SC_OK) {
        NSLog(@"登录失败，错误信息：%d（%@）", status, statusText);
        if (status == PJSIP_SC_FORBIDDEN) {
            NSLog(@"注册被拒：账号或密码错误");
        }
        return;
    }
    if (status == PJSIP_SC_OK) {
        NSLog(@"登录成功，登录信息：%d（%@）", status, statusText);
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:acc_id forKey:@"login_account_id"];
    //    [[NSUserDefaults standardUserDefaults] setObject:_serveAddressTF.text forKey:@"server_uri"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //    [self dailWithPhonenumber:self.phoneNumber];
    //    [self switchToDailVC];
}
//- (void)dailWithPhonenumber:(NSString *)phonenumber Name:(NSString *)name password:(NSString *)password IPAddress:(NSString *)ipaddress {
//    self.phoneNumber = phonenumber;
//    [self registerAccountWithName:name password:password IPAddress:ipaddress];
//}
- (void)dailWithDelegate:(id)delelgate phonenumber:(NSString *)phonenumber Name:(NSString *)name password:(NSString *)password IPAddress:(NSString *)ipaddress {
    self.delegate = delelgate;
    self.phoneNumber = phonenumber;
    [self registerAccountWithName:name password:password IPAddress:ipaddress];
}
//打电话
- (void)dailWithPhonenumber:(NSString *)phonenumber {
    
    pjsua_acc_id acct_id = (pjsua_acc_id)[[NSUserDefaults standardUserDefaults] integerForKey:@"login_account_id"];
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server_uri"];
    NSString *targetUri = [NSString stringWithFormat:@"sip:%@@%@", phonenumber, server];
    
    pj_status_t status;
    pj_str_t dest_uri = pj_str((char *)targetUri.UTF8String);
    
    status = pjsua_call_make_call(acct_id, &dest_uri, 0, NULL, NULL, &_call_id);
    [[AVSound sharedInstance] playWithString:@"ring_back" type:@"wav" loop:YES];
    [[AVSound sharedInstance] play];
    
    if (status != PJ_SUCCESS) {
        char  errMessage[PJ_ERR_MSG_SIZE];
        pj_strerror(status, errMessage, sizeof(errMessage));
        NSLog(@"外拨错误, 错误信息:%d(%s) !", status, errMessage);
        [[AVSound sharedInstance] stop];
    }
    
    //添加拨打状态通知
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCllStatusChanged:) name:@"SIPCallStatusChangedNotification" object:nil];
    
}

// 来电监听
- (void)handleIncommingCall:(NSNotification *)notification {
    [[AVSound sharedInstance] playWithString:@"incoming_ring" type:@"wav" loop:YES];
    [[AVSound sharedInstance] play];
    pjsua_call_id call_id = [notification.userInfo[@"call_id"] intValue];
    pjsipConfAudioId = [notification.userInfo[@"pjsipConfAudioId"] intValue];
    pjsua_call_answer((pjsua_call_id)call_id, 180, NULL, NULL);
}
// 呼叫状态
- (void)handleCllStatusChanged:(NSNotification *)notification {
    pjsua_call_id call_id = [notification.userInfo[@"call_id"] intValue];
    pjsip_inv_state state = [notification.userInfo[@"state"] intValue];
    pjsipConfAudioId = [notification.userInfo[@"pjsipConfAudioId"] intValue];
    NSString * address = notification.userInfo[@"remote_address"];
    NSString * stateText = notification.userInfo[@"stateText"];
    NSLog(@"\n通话状态回调通话状态回调通话状态回调通话状态回调通话状态回调----%d---%@",state,stateText);
    if (state == PJSIP_INV_STATE_CONFIRMED||state == PJSIP_INV_STATE_DISCONNECTED) {
        [[AVSound sharedInstance] stop];
    }
    if (state == PJSIP_INV_STATE_CONNECTING) {
        if (!_connecting) {
            self.connecting = !self.connecting;
            state = PJSIP_INV_STATE_CONNECTING;
        }
    }
    if (call_id != _call_id) {//来电
        _call_id = call_id;
    }
    NSDictionary * dict = @{@"call_state":stateText,
                            @"remote_uri":address,
                            };
    [tmp.methodChannel invokeMethod:method_call_status_changed arguments:dict];
    
    
}

// 呼叫状态
//- (void)handleCllStatusChanged:(NSNotification *)notification {
//    pjsua_call_id call_id = [notification.userInfo[@"call_id"] intValue];
//    pjsip_inv_state state = [notification.userInfo[@"state"] intValue];
//    pjsipConfAudioId = [notification.userInfo[@"pjsipConfAudioId"] intValue];
//    NSLog(@"\n通话状态回调通话状态回调通话状态回调通话状态回调通话状态回调----%d",state);
//    if (call_id != _call_id) {
//        return;
//    }
//    if (state == PJSIP_INV_STATE_DISCONNECTED) {
//        NSLog(@"可以呼叫");
//    } else if (state == PJSIP_INV_STATE_CONNECTING) {
//        NSLog(@"呼叫中。。。");
//    } else if (state == PJSIP_INV_STATE_CONFIRMED) {
//        NSLog(@"接通。。。可以选择挂断");
//    }
//    if ([self.delegate respondsToSelector:@selector(sipmanager:callstatus:)]) {
//        CallStatusType type = CallStatusTypeUnknown;
//        switch (state) {
//            case 5:
//            {
//                if (!_connecting) {
//                    self.connecting = !self.connecting;
//                    type = CallStatusTypeConnecting;
//                }
//                
//                
//            }
//                break;
//            case 6:
//            {
//                type = CallStatusTypeDisconnected;
//                //通话结束，自动挂起
//                if (!self.isHangup) {
//                    [self hangup];
//                }
//            }
//                break;
//                
//                
//            default:
//            {
//                type = CallStatusTypeUnknown;
//            }
//                break;
//        }
//        [self.delegate sipmanager:self callstatus:type];
//    }
//}
// 这里，我把所有的回调函数都包装成通知对外发布，在这里需要注意，所有的通知都放到了主线程
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    
    NSString *remote_info = [NSString stringWithUTF8String:ci.remote_info.ptr];
    
    NSUInteger startIndex = [remote_info rangeOfString:@"<"].location;
    NSUInteger endIndex = [remote_info rangeOfString:@">"].location;
    
    NSString *remote_address = [remote_info substringWithRange:NSMakeRange(startIndex + 1, endIndex - startIndex - 1)];
    remote_address = [remote_info componentsSeparatedByString:@":"][1];
    //来电监听
    id argument = @{
                    @"call_id":@(call_id),
                    @"state":@(ci.state),
                    @"pjsipConfAudioId":@(ci.conf_slot),
                    @"remote_address":remote_address,
                    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SIPIncomingCallNotification" object:nil userInfo:argument];
    });
}


static void on_call_state(pjsua_call_id call_id, pjsip_event *e) {
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    PJ_UNUSED_ARG(e);
    NSString *remote_state = [NSString stringWithUTF8String:ci.state_text.ptr];
    NSString *remote_info = [NSString stringWithUTF8String:ci.remote_info.ptr];
    NSString * string1 = [remote_info componentsSeparatedByString:@"@"].firstObject;
   NSString * remote_address = [string1 componentsSeparatedByString:@":"].lastObject;
    id argument = @{
                    @"call_id":@(call_id),
                    @"state":@(ci.state),
                    @"stateText":remote_state,
                    @"pjsipConfAudioId":@(ci.conf_slot),
                    @"remote_address":remote_address
                    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SIPCallStatusChangedNotification" object:nil userInfo:argument];
    });
}

static void on_call_media_state(pjsua_call_id call_id) {
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    // 获取通话信息
    if (ci.rem_offerer && ci.rem_vid_cnt) {
        // 有视频
        
    }
    // 判断是否开启了视频
    if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
        pj_bool_t has_video = PJ_FALSE;
        if (ci.media_cnt == 2 && ci.media[1].type == PJMEDIA_TYPE_VIDEO && ci.media[1].dir != PJMEDIA_DIR_NONE) {
            has_video = PJ_TRUE;
        }
    }
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}

static void on_reg_state(pjsua_acc_id acc_id) {
    pj_status_t status;
    pjsua_acc_info info;
    
    status = pjsua_acc_get_info(acc_id, &info);
    if (status != PJ_SUCCESS) {
        return;
    }
    
    id argument = @{
                    @"acc_id":@(acc_id),
                    @"status_text":[NSString stringWithUTF8String:info.status_text.ptr],
                    @"status":@(info.status)
                    };
    dispatch_async(dispatch_get_main_queue(), ^{
        //注册结果通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SIPRegisterStatusNotification" object:nil userInfo:argument];
    });
}

//来电接听
-(void)incommingCallReceive{
    pjsua_call_answer((pjsua_call_id)_call_id, 200, NULL, NULL);
}
//来电拒绝&&挂断
- (void)hangup {
    
    pj_status_t status;
    self.isHangup = !self.isHangup;
    status = pjsua_call_hangup(_call_id, 0, NULL, NULL);
    //    pjsua_acc_id acct_id = (pjsua_acc_id)[[NSUserDefaults standardUserDefaults] integerForKey:@"login_account_id"];
    //
    //    pjsua_acc_del(acct_id);
    //    pjsua_call_update(<#pjsua_call_id call_id#>, <#unsigned int options#>, <#const pjsua_msg_data *msg_data#>)
    //    pjsua_destroy();
    
    if (status == PJ_SUCCESS) {
        //        [ZDSipManager attempDealloc];
    }
}
// 静音
- (void)muteMicrophone {
    @try {
        if(pjsipConfAudioId != 0) {
            NSLog(@"WC_SIPServer microphone disconnected from call");
            if (tmp.isMute) {
                 pjsua_conf_connect(0,pjsipConfAudioId);
                tmp.isMute = NO;
            }else{
            pjsua_conf_disconnect(0, pjsipConfAudioId);
                tmp.isMute = YES;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to mute microphone: %@", exception);
    }
}
// 取消静音
- (void)unmuteMicrophone {
    @try {
        if(pjsipConfAudioId != 0) {
            NSLog(@"WC_SIPServer microphone reconnected to call");
            pjsua_conf_connect(0,pjsipConfAudioId);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to un-mute microphone: %@", exception);
    }
}
//免提
-(void)setAudioSession{
    if ([[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryPlayback]){
        //切换为听筒播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else{
        //切换为扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}
#pragma mark--系统电话回调
-(void)callCenterBlock{
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler=^(CTCall* call){
        if([call.callState isEqualToString:CTCallStateDisconnected]){
            NSLog(@"Call has been disconnected");
        }else if([call.callState isEqualToString:CTCallStateConnected]){
            NSLog(@"Callhasjustbeen connected");
        }else if([call.callState isEqualToString:CTCallStateIncoming]){
            NSLog(@"Call is incoming");//系统来电
            [tmp hangup];
        }else if([call.callState isEqualToString:CTCallStateDialing]){
            NSLog(@"Call is Dialing");
        }else{
            NSLog(@"Nothing is done");
        }
    };
}
@end
