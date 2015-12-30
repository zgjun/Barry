//
//  NonHighButton.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "NonHighButton.h"


#define TabBarButtonRatio 0.7

@implementation NonHighButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.设置按钮的属性
        // 设置按钮图片居中显示
        self.imageView.contentMode = UIViewContentModeCenter;
        // 设置按钮标题居中显示
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 设置按钮的字体大小
        self.titleLabel.font = [UIFont systemFontOfSize:16];
         //设置标题颜色
        
        [self setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
         //设置按钮选中状态的文字颜色
        [self setTitleColor:MainGoldenColor forState:UIControlStateSelected];
        
    }
    return self;
}
// 控制器图片的位置
// contentRect 就是当前按钮的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height;
    return CGRectMake(imageX, imageY, imageW, imageH);
}
// 控制器标题的位置
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = self.height * TabBarButtonRatio + 5;
    CGFloat titleW = self.width;
    CGFloat titleH = self.height - titleY;
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)setHighlighted:(BOOL)highlighted{
    
}

@end
