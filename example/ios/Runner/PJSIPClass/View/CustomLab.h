//
//  CustomLab.h
//  Mobile-money
//
//  Created by songbin on 15/11/26.
//  Copyright © 2015年 hengchang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomLab : UILabel
/**
 *
 * @param frame       自身的位置
 * @param font        文字字号
 * @param aligment    位置 剧中，居左，居右
 * @param text        文本内容
 * @param color       文本颜色色
 */
- (id)initWithFrame:(CGRect)frame font:(NSInteger)font aligment:(NSTextAlignment)aligment text:(NSString*)text textcolor:(UIColor *)color;

@end
