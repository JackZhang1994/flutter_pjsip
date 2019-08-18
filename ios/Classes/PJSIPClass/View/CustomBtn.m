//
//  CustomBtn.m
//  Mobile-money
//
//  Created by songbin on 15/11/26.
//  Copyright © 2015年 hengchang. All rights reserved.
//

#import "CustomBtn.h"
//通道十六进制颜色
#define COLORHEX(hex) [UIColor colorWithRed:((float)(((hex) & 0xFF0000) >> 16)) / 255.0 green:((float)(((hex) & 0xFF00) >> 8))/255.0 blue:((float)((hex) & 0xFF)) / 255.0 alpha:1.0]
@implementation CustomBtn

- (id)initWithFrame:(CGRect)frame Tag:(int)tag Title:(NSString *)title backgroundColor:(UIColor *)color TitleTextColor:(UIColor *)titletColor Font:(int)font Image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tag = tag;
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:titletColor forState:UIControlStateNormal];
        self.backgroundColor = color;
        self.frame = frame;
        self.titleLabel.font = [UIFont fontWithName:@"Arial" size:font];
        [self setBackgroundImage:image forState:UIControlStateNormal];
    }
    return self;
}

- (void)setCustomBtnBackgroundColor:(int)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[CustomBtn createImageWithColor:backgroundColor] forState:state];

}

+ (UIImage*)createImageWithColor:(int)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [COLORHEX(color) CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
//    self.layer.cornerRadius  = 6;
//    self.layer.masksToBounds = YES;
//    self.layer.borderColor   = COLORHEX(0xFFFFFF).CGColor;
}

@end
