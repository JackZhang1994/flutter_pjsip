//
//  PJSIPModel.h
//  Runner
//
//  Created by gejianmin on 2019/8/9.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PJSIPModel : NSObject
@property (nonatomic, copy) NSString            *phone;/*!< 手机号*/
@property (nonatomic, copy) NSString            *followStatus;/*!< 跟进状态*/
@property (nonatomic, copy) NSString            *createTime;/*!< 创建时间*/
@property (nonatomic, copy) NSString            *contactName;/*!< 联系人名称*/
@property (nonatomic, copy) NSString            *ID;/*!< 线索id*/
@property (nonatomic, copy) NSString            *fixedTel;/*!< 固定电话*/

@property (nonatomic, copy) NSString            *nickName;/*!< 用户名*/
@property (nonatomic, copy) NSString            *password;/*!< 密码*/
@property (nonatomic, copy) NSString            *sipIp;/*!< ip*/
@property (nonatomic, copy) NSString            *sip_port;/*!< 端口号*/

@end

NS_ASSUME_NONNULL_END
