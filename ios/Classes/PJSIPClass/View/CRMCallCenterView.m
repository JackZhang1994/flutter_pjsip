//
//  CRMCallCenterView.m
//  CRMSystemClient
//
//  Created by tongda ju on 2017/12/13.
//  Copyright © 2017年 juTongDa. All rights reserved.
//

#import "CRMCallCenterView.h"
#import "UIView+Shadow.h"
//屏幕的高度
#define HH_SCREEN_H [UIScreen mainScreen].bounds.size.height
//屏幕的宽带
#define HH_SCREEN_W [UIScreen mainScreen].bounds.size.width

//#define self.sizeScaleY self.sizeScaleY

#define kColorWhite             [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]
#define kColorGray1             [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]//#333333
#define kColorGray6             [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]//#9b9b9b(#999999)
//通道十六进制颜色
#define COLORHEX(hex) [UIColor colorWithRed:((float)(((hex) & 0xFF0000) >> 16)) / 255.0 green:((float)(((hex) & 0xFF00) >> 8))/255.0 blue:((float)((hex) & 0xFF)) / 255.0 alpha:1.0]
@implementation CRMCallCenterView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //        [self initUI];
        [self setupMainInfoSettiong];
        
    }
    return self;
}
-(instancetype)initWithTelPhoneStype:(CRMCallCenterStype )callCenterPhoneStype{
    
    if (self = [super init]) {
        [self initUIWithStype:callCenterPhoneStype];
    }
    return self;
}
- (void)setupMainInfoSettiong{
    
    if(HH_SCREEN_H != 667){
        self.sizeScaleX = HH_SCREEN_W/375;
        self.sizeScaleY = HH_SCREEN_H/667;
    }else{
        self.sizeScaleX = 1.0;
        self.sizeScaleY = 1.0;
    }
}
-(void)initUIWithStype:(CRMCallCenterStype )callCenterPhoneStype{
    [self setBackgroundColor:kColorGray1];
    
    [self addSubview:self.title_lbl];
    [self addSubview:self.subTitle_lbl];
    [self addSubview:self.shimmeringView];
    [self addSubview:self.right_lbl];
    [self addSubview:self.time_lbl];
    
    [self addSubview:self.makeCall_btn];
    [self addSubview:self.mute_btn];
    [self addSubview:self.handsfree_btn];
    
    [self addSubview:self.mark_lbl];
    [self addSubview:self.right_image];
    [self addSubview:self.phone_image];
    //来电的接收与拒绝
    [self addSubview:self.refuse_btn];
    [self addSubview:self.receive_btn];
    
    [self.title_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(128*self.sizeScaleY));
        make.centerX.equalTo(self);
    }];
    [self.subTitle_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title_lbl.mas_bottom).offset(15*self.sizeScaleY);
        make.centerX.equalTo(self);
    }];
    [self.makeCall_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-(64*self.sizeScaleY));
        make.centerX.equalTo(self);
        make.height.equalTo(@(49));
        make.left.equalTo(self).offset(96.5*self.sizeScaleY);
        make.right.equalTo(self).offset(-(96.5*self.sizeScaleY));
        
    }];
    [self.phone_image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.makeCall_btn.mas_centerY);
        make.centerX.equalTo(self.makeCall_btn.mas_centerX);
        make.height.equalTo(@(19*self.sizeScaleY));
        make.width.equalTo(@(56*self.sizeScaleY));
        
    }];
    if (callCenterPhoneStype == CallingPhoneStype) {//去电
        //通话中。。。或新的来电或正在呼叫
        [self.right_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.subTitle_lbl.mas_bottom).offset(30*self.sizeScaleY);
            make.centerX.equalTo(self);
            make.width.height.equalTo(@(100*self.sizeScaleY));
        }];
        _right_lbl.text = @"接通中...";
        [_right_lbl makeCornerWithCornerRadius:50*self.sizeScaleY borderWidth:0.5 borderColor:kColorGray6];
        
        //请耐心等待或通话时长或请接听
        [self.time_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.right_lbl.mas_bottom).offset(30*self.sizeScaleY);
            make.centerX.equalTo(self);
        }];
        _time_lbl.text = @"通话时长  00:00:00";
        //静音
        [self.mute_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.makeCall_btn.mas_centerY);
            make.width.height.equalTo(@(44));
            make.right.equalTo(self.makeCall_btn.mas_left).offset(-(22.5*self.sizeScaleY));
        }];
        //免提
        [self.handsfree_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.makeCall_btn.mas_centerY);
            make.width.height.equalTo(@(44));
            make.left.equalTo(self.makeCall_btn.mas_right).offset(22.5*self.sizeScaleY);
        }];
        //接收
    }else{//来电
        //通话中。。。或新的来电或正在呼叫
        [self.right_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.subTitle_lbl.mas_bottom).offset(30*self.sizeScaleY);
            make.centerX.equalTo(self);
            make.width.height.equalTo(@(100*self.sizeScaleY));
        }];
        [_right_lbl makeCornerWithCornerRadius:50*self.sizeScaleY borderWidth:0.5 borderColor:kColorGray6];
        
        //请耐心等待或通话时长或请接听
        [self.time_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.right_lbl.mas_bottom).offset(30*self.sizeScaleY);
            make.centerX.equalTo(self);
        }];
        
        //静音
        [self.mute_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.makeCall_btn.mas_centerY);
            make.width.height.equalTo(@(44));
            make.right.equalTo(self.makeCall_btn.mas_left).offset(-(22.5*self.sizeScaleY));
        }];
        //免提
        [self.handsfree_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.makeCall_btn.mas_centerY);
            make.width.height.equalTo(@(44));
            make.left.equalTo(self.makeCall_btn.mas_right).offset(22.5*self.sizeScaleY);
        }];
        [self.refuse_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.makeCall_btn.mas_centerY);
            make.width.height.equalTo(@(44));
            make.right.equalTo(self.makeCall_btn.mas_left).offset(-(22.5*self.sizeScaleY));
        }];
        //拒绝
        [self.receive_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.makeCall_btn.mas_centerY);
            make.width.height.equalTo(@(44));
            make.left.equalTo(self.makeCall_btn.mas_right).offset(22.5*self.sizeScaleY);
        }];
    }
    
    //    [self.mark_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.equalTo(self.mas_bottom).offset(-(20*self.sizeScaleY));
    //        make.centerX.equalTo(self);
    //    }];
    //    [self.right_image mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.equalTo(self.mark_lbl.mas_left).offset(-(10*self.sizeScaleY));
    //        make.centerY.equalTo(self.mark_lbl.mas_centerY);
    //        make.width.height.equalTo(@(14*self.sizeScaleY));
    //    }];
}
-(void)relaodWithTelPhoneStype:(CRMCallCenterStype )callCenterPhoneStype model:(PJSIPModel *)model phoneStutas:(NSString *)stutasString{
//    if (callCenterPhoneStype ==CallingPhoneStype) {
        _right_lbl.text = stutasString;
//    }
    _title_lbl.text = model.nickName?:@"1010";
    _subTitle_lbl.text = model.phone?:@"sip:1010@117.78.34.48:6050";
}

-(CustomLab *)title_lbl{
    if (_title_lbl == nil) {
        _title_lbl = [[CustomLab alloc]initWithFrame:CGRectZero font:17.0f aligment:NSTextAlignmentLeft text:@"王乐乐的线索" textcolor:kColorWhite];
    }
    return _title_lbl;
}
-(CustomLab *)subTitle_lbl{
    if (_subTitle_lbl == nil) {
        _subTitle_lbl = [[CustomLab alloc]initWithFrame:CGRectZero font:15.0f aligment:NSTextAlignmentLeft text:@"18810950985(美国洛杉矶)" textcolor:kColorWhite];
    }
    return _subTitle_lbl;
}
-(FBShimmeringView *)shimmeringView{
    if (_shimmeringView == nil) {
        _shimmeringView = [[FBShimmeringView alloc] init];
        _shimmeringView.shimmering = YES;
        _shimmeringView.shimmeringBeginFadeDuration = 0.3;
        _shimmeringView.shimmeringOpacity = 0.3;
        // The speed of shimmering, in points per second. Defaults to 230.
        _shimmeringView.shimmeringSpeed = 230;
    }
    return _shimmeringView;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect shimmeringFrame = self.bounds;
    shimmeringFrame.origin.y = shimmeringFrame.size.height * 0.12;
    shimmeringFrame.size.height = shimmeringFrame.size.height * 0.69;
    self.shimmeringView.frame = shimmeringFrame;
}

-(CustomLab *)right_lbl{
    
    if (_right_lbl == nil) {
        _right_lbl = [[CustomLab alloc]initWithFrame:CGRectZero font:16.0f aligment:NSTextAlignmentCenter text:@"请先接听来电，随后将自动拨打对方" textcolor:kColorWhite];
        //        _shimmeringView.contentView = _right_lbl;
        //        [_right_lbl makeCornerWithCornerRadius:50*self.sizeScaleY borderWidth:0.5 borderColor:kColorGray6];
    }
    return _right_lbl;
}

-(CustomLab *)time_lbl{
    if (_time_lbl == nil) {
        _time_lbl = [[CustomLab alloc]initWithFrame:CGRectZero font:14.0f aligment:NSTextAlignmentCenter text:@"对方无法看到你的手机号，有效保护隐私" textcolor:kColorWhite];
    }
    return _time_lbl;
}

-(UIImageView *)phone_image{
    if (_phone_image == nil) {
        _phone_image = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"callcenter_makeCall"]];
    }
    return _phone_image;
}
//挂断电话按钮
-(CustomBtn *)makeCall_btn{
    if (_makeCall_btn == nil) {
        _makeCall_btn = [[CustomBtn alloc]initWithFrame:CGRectZero Tag:1001 Title:nil backgroundColor:COLORHEX(0xf34d42) TitleTextColor:kColorWhite Font:13.0f Image:nil];
        [_makeCall_btn makeCornerWithCornerRadius:24.5 borderWidth:0.0 borderColor:kColorGray6];
        
        [_makeCall_btn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _makeCall_btn;
}
//静音
-(CustomBtn *)mute_btn{
    if (_mute_btn == nil) {
        _mute_btn = [[CustomBtn alloc]initWithFrame:CGRectZero Tag:1000 Title:@"静音" backgroundColor:[UIColor clearColor] TitleTextColor:kColorWhite Font:15.0f Image:nil];
        [_mute_btn setTitleColor:kColorGray1 forState:UIControlStateSelected];
        [_mute_btn setCustomBtnBackgroundColor:0xFFFFFF forState:UIControlStateSelected];
        [_mute_btn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_mute_btn makeCornerWithCornerRadius:22 borderWidth:0.5 borderColor:kColorGray6];
        _mute_btn.enabled = NO;
        [_mute_btn setHidden:YES];
    }
    return _mute_btn;
}
//免提
-(CustomBtn *)handsfree_btn{
    if (_handsfree_btn == nil) {
        _handsfree_btn = [[CustomBtn alloc]initWithFrame:CGRectZero Tag:1002 Title:@"免提" backgroundColor:[UIColor clearColor] TitleTextColor:kColorWhite Font:15.0f Image:nil];
        [_handsfree_btn setTitleColor:kColorGray1 forState:UIControlStateSelected];
        [_handsfree_btn setCustomBtnBackgroundColor:0xFFFFFF forState:UIControlStateSelected];
        [_handsfree_btn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_handsfree_btn makeCornerWithCornerRadius:22 borderWidth:0.5 borderColor:kColorGray6];
        _handsfree_btn.enabled = NO;
        [_handsfree_btn setHidden:YES];
        
        
    }
    return _handsfree_btn;
}
//拒绝
-(CustomBtn *)refuse_btn{
    if (_refuse_btn == nil) {
        _refuse_btn = [[CustomBtn alloc]initWithFrame:CGRectZero Tag:1003 Title:@"拒绝" backgroundColor:[UIColor clearColor] TitleTextColor:kColorWhite Font:15.0f Image:nil];
        //        [_refuse_btn setTitleColor:kColorGray1 forState:UIControlStateSelected];
        [_refuse_btn setBackgroundColor:COLORHEX(0xF44336)];
        [_refuse_btn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_refuse_btn makeCornerWithCornerRadius:22 borderWidth:0.0 borderColor:COLORHEX(0xF44336) ];
//        _refuse_btn.enabled = NO;
    }
    return _refuse_btn;
}
//接收
-(CustomBtn *)receive_btn{
    if (_receive_btn == nil) {
        _receive_btn = [[CustomBtn alloc]initWithFrame:CGRectZero Tag:1004 Title:@"接收" backgroundColor:[UIColor clearColor] TitleTextColor:kColorWhite Font:15.0f Image:nil];
        //        [_receive_btn setTitleColor:kColorGray1 forState:UIControlStateSelected];
        //        [_receive_btn setCustomBtnBackgroundColor:0x009688 forState:UIControlStateNormal];
        [_receive_btn setBackgroundColor:COLORHEX(0x009688)];
        [_receive_btn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_receive_btn makeCornerWithCornerRadius:22 borderWidth:0.0 borderColor:COLORHEX(0x009688)];
//        _receive_btn.enabled = NO;
    }
    return _receive_btn;
}
//-(UIImageView *)right_image{
//    if (_right_image == nil) {
//        _right_image = [[UIImageView alloc]initWithImage: ImageNamed(@"clue_dateImage")];
//    }
//    return _right_image;
//}

//-(CustomLab *)mark_lbl{
//    if (_mark_lbl == nil) {
//        _mark_lbl = [[CustomLab alloc]initWithFrame:CGRectZero font:12.0f aligment:NSTextAlignmentLeft text:@"本次呼叫由中国移动提供" textcolor:kColorGray6];
//    }
//    return _mark_lbl;
//}
-(void)buttonEvent:(CustomBtn *)sender{
    if (sender.tag == 1000||sender.tag == 1002) {
        sender.selected = !sender.isSelected;
    }
    if (self.buttonBlock) {
        self.buttonBlock(sender);
    }
}
@end
