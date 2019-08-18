//
//  UIView+Shadow.h
//  CRMSystemClient
//
//  Created by tongda ju on 2017/8/2.
//  Copyright © 2017年 juTongDa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Shadow)
/**
 阴影设置
 
 @param color 阴影颜色
 @param shadowOffsetX 阴影偏移量左右 x向右偏移4，y向下偏移4，默认(0, -3)
 @param shadowOffsetY 阴影偏移量上下 x向右偏移4，y向下偏移4，默认(0, -3)
 @param shadowOpacity 阴影透明度，默认0
 @param shadowRadius 阴影半径，默认3
 */

-(void)makeShadowWithshadowColor:(UIColor *)color cornerRadius:(CGFloat )cornerRadius shadowOffsetX:(CGFloat )shadowOffsetX shadowOffsetY:(CGFloat )shadowOffsetY shadowOpacity:(float)shadowOpacity shadowRadius:(float)shadowRadius;
/**
 设置圆角
 
 @param cornerRadiusColor 圆角尺寸
 @param borderColor 边缘线颜色
 @param borderWidth 边缘线宽度
 */
- (void)makeCornerWithCornerRadius:(CGFloat )cornerRadiusColor borderWidth:(CGFloat )borderWidth borderColor:(UIColor *)borderColor;
/**
 设置弥散阴影
 
 @param rect CGRectMake(-1, -1, self.frame.size.width, self.frame.size.height)
 */
- (void)makeShadowPathWithCGRectMake:(CGRect)rect;



- (void)configCornerOfCircleWithCornerRadius:(CGFloat)cornerRadius;

#pragma mark - 设置部分圆角
/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii;
/**
 *  设置部分圆角(相对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect;

/**
 阴影设置
 
 @param color 阴影颜色
 @param shadowOffsetX 阴影偏移量左右 x向右偏移4，y向下偏移4，默认(0, -3)
 @param shadowOffsetY 阴影偏移量上下 x向右偏移4，y向下偏移4，默认(0, -3)
 @param shadowOpacity 阴影透明度，默认0
 @param shadowRadius 阴影半径，默认3
 */
-(void)makeShadowAndCorner:(UIView *)superview bgColor:(UIColor *)bgColor shadowColor:(UIColor *)color cornerRadius:(CGFloat )cornerRadius shadowOffsetX:(CGFloat )shadowOffsetX shadowOffsetY:(CGFloat )shadowOffsetY shadowOpacity:(float)shadowOpacity shadowRadius:(float)shadowRadius;

/**
 渐变

 @param fromColor 开始
 @param toColor 结束
 */
-(void)makeGradientfrom:(UIColor *)fromColor to:(UIColor *)toColor;
/** 判断self和anotherView是否重叠 */
- (BOOL)hu_intersectsWithAnotherView:(UIView *)anotherView;
@end
