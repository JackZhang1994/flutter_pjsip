//
//  PJSIPComingViewController.m
//  Runner
//
//  Created by gejianmin on 2019/8/16.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "PJSIPComingViewController.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <AVFoundation/AVFoundation.h>
#import "PJSipManager.h"
#import "AVSound.h"
#include <pjsua-lib/pjsua.h>
//屏幕的高度
#define HH_SCREEN_H [UIScreen mainScreen].bounds.size.height
//屏幕的宽带
#define HH_SCREEN_W [UIScreen mainScreen].bounds.size.width
/*!< 弱引用 */
#define JTDWeakSelf __weak typeof(self) WeakSelf = self;
//log日志打印,包含该函数名,行数
#if DEBUG
#define HHLog(id, ...) NSLog((@"%s [Line %d] " id),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define HHLog(id, ...)
#endif
//SIP
#define  CRM_SERVCE_HOST   @"117.78.34.48"
#define  CRM_SERVCE_PORT   @"6050"
#define  CRM_SERVCE_USERNAME   @"1010"//分机号53827816501
#define  CRM_SERVCE_PASSWORD   @"123@jvtd"//123456//06b90c26
#define  CRM_SERVCE_PHONE   @"1012"


@interface PJSIPComingViewController ()<ZDSipManagerDelegate>{
    NSTimer * _timer;
    NSInteger _timeTick;
    NSString * _crm_servce_mainConfig;//主机号
    NSString * _crm_servce_host;
    NSString * _crm_servce_port;
    NSString * _crm_servce_config;//分机号
    NSString * _crm_servce_password;
    
}
@property(nonatomic,strong)CTCallCenter * callCenter; //必须在这里声明，要不不会回调block
@property (nonatomic, strong) CRMCallCenterView * callCenterView;
@property (nonatomic, assign) BOOL timeEnable;

@end

@implementation PJSIPComingViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:self];
    //    [PJSipManager attempDealloc];
    
    [[AVSound sharedInstance] stop];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallStatusChanged:) name:@"SIPCallStatusChangedNotification" object:nil];
    self.callCenterPhoneStype = IncomingPhoneStype;
    [self initUI];
//    pjsua_call_answer((pjsua_call_id)_callId, 180, NULL, NULL);
    [self.callCenterView.makeCall_btn setHidden:YES];
    [self.callCenterView.phone_image setHidden:YES];
    [self.callCenterView.time_lbl setText:@"请接收"];
    [[AVSound sharedInstance] playWithString:@"incoming_ring" type:@"wav" loop:YES];
    [[AVSound sharedInstance] play];
}
-(void)initUI{
    [self.view addSubview:self.callCenterView];
    
}

-(CRMCallCenterView *)callCenterView{
    if (!_callCenterView) {
        JTDWeakSelf
        _callCenterView = [[CRMCallCenterView alloc]initWithTelPhoneStype:self.callCenterPhoneStype];
        [_callCenterView relaodWithTelPhoneStype:self.callCenterPhoneStype model:self.model phoneStutas:@"新的来电..."];
        _callCenterView.frame = CGRectMake(0, 0, HH_SCREEN_W, HH_SCREEN_H);
        _callCenterView.buttonBlock = ^(CustomBtn *sender) {
            [WeakSelf callBuutonEvent:sender];
        };
    }
    return _callCenterView;
}
-(void)callBuutonEvent:(CustomBtn *)sender{
    NSInteger tag = sender.tag;
    if (tag == 1000) {//静音
        if (sender.selected) {
            [[PJSipManager manager] muteMicrophone];
        }else{
            [[PJSipManager manager] unmuteMicrophone];
        }
    }else if (tag == 1002){//免提
        [self setAudioSession];
    }else if (tag == 1003){//拒绝
        [[AVSound sharedInstance] stop];
        [[PJSipManager manager] icncommingCallRefuse];
    }else if (tag == 1004){//接收
        [[AVSound sharedInstance] stop];
        [[PJSipManager manager] incommingCallReceive];
    }else{//挂断电话
        [[PJSipManager manager] icncommingCallRefuse];
    }
}
// 状态变化
- (void)handleCallStatusChanged:(NSNotification *)notification {
    pjsua_call_id call_id = [notification.userInfo[@"call_id"] intValue];
    pjsip_inv_state state = [notification.userInfo[@"state"] intValue];
    if (state == PJSIP_INV_STATE_CONNECTING) {
        NSLog(@"连接中");
    } else if (state == PJSIP_INV_STATE_CONFIRMED) {
        [[AVSound sharedInstance] stop];
        NSLog(@"接听成功！！！！！");
        [self.callCenterView.makeCall_btn setHidden:NO];
        [self.callCenterView.phone_image setHidden:NO];
        [self.callCenterView.refuse_btn setHidden:YES];
        [self.callCenterView.receive_btn setHidden:YES];
        [self.callCenterView.mute_btn setHidden:NO];
        [self.callCenterView.handsfree_btn setHidden:NO];
        _callCenterView.mute_btn.enabled = YES;
        _callCenterView.handsfree_btn.enabled = YES;
        [self startTime];
        [_callCenterView relaodWithTelPhoneStype:self.callCenterPhoneStype model:self.model phoneStutas:@"通话中..."];
    }else if (state == PJSIP_INV_STATE_DISCONNECTED) {
        [_callCenterView.time_lbl setText:@"通话已结束"];
        [self stopIdleTiming];
        _callCenterView.mute_btn.enabled = NO;
        _callCenterView.handsfree_btn.enabled = NO;
        [self delay:1.0 task:^{
            [self viewDissmiss];
        }];
    }
}

#pragma mark--linPhone
-(void)makeLinPhoneWithIP:(NSString *)IPStr port:(NSString *)portStr config:(NSString *)config password:(NSString *)password{
    [[PJSipManager manager] dailWithDelegate:self phonenumber:CRM_SERVCE_PHONE Name:CRM_SERVCE_USERNAME password:CRM_SERVCE_PASSWORD IPAddress:[NSString stringWithFormat:@"%@:%@",CRM_SERVCE_HOST,CRM_SERVCE_PORT]];
}
-(void)viewDissmiss{
    if (self.finishCallBlock) {
        self.finishCallBlock(YES);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)delay:(NSTimeInterval)timer task:(dispatch_block_t)task{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timer * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        task();
    });
}
#pragma mark--系统电话回调
-(void)callCenterBlock{
    _callCenter = [[CTCallCenter alloc] init];
    JTDWeakSelf
    _callCenter.callEventHandler=^(CTCall* call){
        if([call.callState isEqualToString:CTCallStateDisconnected]){
            HHLog(@"Call has been disconnected");
        }else if([call.callState isEqualToString:CTCallStateConnected]){
            HHLog(@"Callhasjustbeen connected");
        }else if([call.callState isEqualToString:CTCallStateIncoming]){
            HHLog(@"Call is incoming");
            [WeakSelf viewDissmiss];
        }else if([call.callState isEqualToString:CTCallStateDialing]){
            HHLog(@"Call is Dialing");
        }else{
            HHLog(@"Nothing is done");
        }
    };
}
#pragma mark--设置计时器
-(void)startTime{
    _timeTick = 0;
    _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
-(void)timeFireMethod{
    _timeTick ++;
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",_timeTick/3600];//时
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(_timeTick%3600)/60];//分
    NSString *str_second = [NSString stringWithFormat:@"%02ld",_timeTick%60];//秒
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    _callCenterView.time_lbl.text =[NSString stringWithFormat:@"通话时长: %@",format_time];
}
- (void)stopIdleTiming{
    _timeTick = 0;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
- (void)setTimerEnable:(BOOL)enable{
    self.timeEnable = enable;
    if (!enable) {
        [self stopIdleTiming];
    }
}
-(void)setAudioSession{
    if ([[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryPlayback]){
        //切换为听筒播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else{
        //切换为扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
