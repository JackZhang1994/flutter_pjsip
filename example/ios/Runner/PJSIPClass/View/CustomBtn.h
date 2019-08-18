//
//  CustomBtn.h
//  Mobile-money
//
//  Created by songbin on 15/11/26.
//  Copyright © 2015年 hengchang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBtn : UIButton
/**
 *
 * @param frame  自身的位置
 * @param tag    标记tag值
 * @param title  按钮的名字
 * @param color  背景色
 * @param titletColor  文字颜色
 * @param font         文字字号
 * @param image        背景图片
 */
- (id)initWithFrame:(CGRect)frame Tag:(int)tag Title:(NSString *)title backgroundColor:(UIColor *)color TitleTextColor:(UIColor *)titletColor Font:(int)font Image:(UIImage *)image;



/**
  *
  * set btn state bgColor
  * @param  backgroundColor  传入16进制色值
  * @param  state  系统的几种按钮状态
  */
- (void)setCustomBtnBackgroundColor:(int)backgroundColor forState:(UIControlState)state;


@end
