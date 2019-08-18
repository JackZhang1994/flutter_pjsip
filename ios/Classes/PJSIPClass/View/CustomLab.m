//
//  CustomLab.m
//  Mobile-money
//
//  Created by songbin on 15/11/26.
//  Copyright © 2015年 hengchang. All rights reserved.
//

#import "CustomLab.h"

@implementation CustomLab

- (id)initWithFrame:(CGRect)frame font:(NSInteger)font aligment:(NSTextAlignment)aligment text:(NSString*)text textcolor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont systemFontOfSize:font];
        self.textAlignment = aligment;
        self.text = text;
        self.frame = frame;
        self.textColor =color;
    }
    return self;
}

@end
