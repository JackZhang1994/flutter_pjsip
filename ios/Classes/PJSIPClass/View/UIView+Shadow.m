//
//  UIView+Shadow.m
//  CRMSystemClient
//
//  Created by tongda ju on 2017/8/2.
//  Copyright © 2017年 juTongDa. All rights reserved.
//

#import "UIView+Shadow.h"

@implementation UIView (Shadow)
/**
 阴影设置

 @param color 阴影颜色
 @param cornerRadius 设置圆角
 @param shadowOffsetX 阴影偏移量左右 x向右偏移4，y向下偏移4，默认(0, -3)
 @param shadowOffsetY 阴影偏移量上下 x向右偏移4，y向下偏移4，默认(0, -3)
 @param shadowOpacity 阴影透明度，默认0
 @param shadowRadius 阴影半径，默认3
 */
-(void)makeShadowWithshadowColor:(UIColor *)color cornerRadius:(CGFloat )cornerRadius shadowOffsetX:(CGFloat )shadowOffsetX shadowOffsetY:(CGFloat )shadowOffsetY shadowOpacity:(float)shadowOpacity shadowRadius:(float)shadowRadius{
    
    self.layer.shadowColor = color.CGColor;
    self.layer.cornerRadius = cornerRadius;
    self.layer.shadowOffset = CGSizeMake(shadowOffsetX,shadowOffsetY);
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowRadius = shadowRadius;
    }

/**
 设置弥散阴影

 @param rect CGRectMake(-1, -1, self.frame.size.width, self.frame.size.height)
 */
- (void)makeShadowPathWithCGRectMake:(CGRect)rect {
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
}

/**
 设置圆角

 @param cornerRadiusColor 圆角尺寸
 @param borderColor 边缘线颜色
 @param borderWidth 边缘线宽度
 */
- (void)makeCornerWithCornerRadius:(CGFloat )cornerRadiusColor borderWidth:(CGFloat )borderWidth borderColor:(UIColor *)borderColor  {
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadiusColor;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = (borderColor?borderColor:[UIColor clearColor]).CGColor;
    
}


- (void)configCornerOfCircleWithCornerRadius:(CGFloat)cornerRadius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = .5f;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    
}

#pragma mark - 设置部分圆角
/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.layer.mask = shape;
}

/**
 *  设置部分圆角(相对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.layer.mask = shape;
}

-(void)makeShadowAndCorner:(UIView *)superview bgColor:(UIColor *)bgColor shadowColor:(UIColor *)color cornerRadius:(CGFloat )cornerRadius shadowOffsetX:(CGFloat )shadowOffsetX shadowOffsetY:(CGFloat )shadowOffsetY shadowOpacity:(float)shadowOpacity shadowRadius:(float)shadowRadius{
    CALayer *layer = [CALayer layer];
    layer.frame = self.frame;
    layer.backgroundColor = bgColor.CGColor;
    layer.shadowColor = color.CGColor;
    layer.shadowOffset = CGSizeMake(shadowOffsetX, shadowOffsetY);
    layer.shadowOpacity = shadowOpacity;
    layer.cornerRadius = cornerRadius;
    layer.shadowRadius = shadowRadius;
    //这里self表示当前自定义的view
    [superview.layer addSublayer:layer];
    self.layer.masksToBounds =YES;
    self.layer.cornerRadius =cornerRadius;
}
-(void)makeGradientfrom:(UIColor *)fromColor to:(UIColor *)toColor{
    
    CAGradientLayer *gradientLayer0 = [[CAGradientLayer alloc] init];
    gradientLayer0.frame = self.bounds;
    gradientLayer0.colors = @[
                              (id)fromColor.CGColor,
                              (id)toColor.CGColor];
    gradientLayer0.locations = @[@0, @1];
    [gradientLayer0 setStartPoint:CGPointMake(1, 0)];
    [gradientLayer0 setEndPoint:CGPointMake(1, 1)];
//    [self.layer addSublayer:gradientLayer0];
    [self.layer insertSublayer:gradientLayer0 atIndex:0];
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.colors = @[(__bridge id)kColorMainBlue.CGColor, (__bridge id)COLORHEX(0x5fe2b3).CGColor];
//    gradientLayer.locations = @[@0.3, @1.0];
//    gradientLayer.startPoint = CGPointMake(0, 0);
//    gradientLayer.endPoint = CGPointMake(1.0, 0);
//    gradientLayer.frame = self.record_btn.bounds;
//    gradientLayer.cornerRadius = 22;
//    [self.record_btn.layer addSublayer:gradientLayer];
}
/** 判断self和anotherView是否重叠 */
- (BOOL)hu_intersectsWithAnotherView:(UIView *)anotherView
{
    
    //如果anotherView为nil，那么就代表keyWindow
    if (anotherView == nil) anotherView = [UIApplication sharedApplication].keyWindow;
    
    
    CGRect selfRect = [self convertRect:self.bounds toView:nil];
    
    CGRect anotherRect = [anotherView convertRect:anotherView.bounds toView:nil];
    
    //CGRectIntersectsRect是否有交叉
    return CGRectIntersectsRect(selfRect, anotherRect);
}
@end
