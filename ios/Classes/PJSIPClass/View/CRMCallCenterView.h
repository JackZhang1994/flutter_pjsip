//
//  CRMCallCenterView.h
//  CRMSystemClient
//
//  Created by tongda ju on 2017/12/13.
//  Copyright © 2017年 juTongDa. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CRMCallCenterViewController.h"
#import "FBShimmeringView.h"
#import "PJSIPModel.h"
#import "CustomBtn.h"
#import "CustomLab.h"
#import "Masonry.h"
typedef NS_ENUM(NSUInteger, CRMCallCenterStype) {
    
//    callCenterSmartPhoneStype,
//    callCenterNetworkPhoneStype,
    CallingPhoneStype,
    IncomingPhoneStype
};
typedef void (^buttonClick) (CustomBtn * sender);

@interface CRMCallCenterView : UIView

@property (nonatomic, strong) CustomLab * title_lbl;
@property (nonatomic, strong) CustomLab * subTitle_lbl;
@property (nonatomic, strong) CustomLab * right_lbl;
@property (nonatomic, strong)FBShimmeringView * shimmeringView;
@property (nonatomic, strong) CustomLab * time_lbl;

@property (nonatomic, strong) CustomBtn * makeCall_btn;
@property (nonatomic, strong) CustomBtn * mute_btn;
@property (nonatomic, strong) CustomBtn * handsfree_btn;

@property (nonatomic, strong) CustomLab * mark_lbl;
@property (nonatomic, strong) UIImageView * right_image;
@property (nonatomic, strong) UIImageView * phone_image;
@property (nonatomic, copy) buttonClick buttonBlock;

@property (nonatomic, strong) CustomBtn * refuse_btn;
@property (nonatomic, strong) CustomBtn * receive_btn;

@property (nonatomic, assign)float sizeScaleX;
@property  (nonatomic, assign)float sizeScaleY;

-(void)relaodWithTelPhoneStype:(CRMCallCenterStype )callCenterPhoneStype model:(PJSIPModel *)model phoneStutas:(NSString *)stutasString;

-(instancetype)initWithTelPhoneStype:(CRMCallCenterStype )callCenterPhoneStype;

@end
