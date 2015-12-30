//
//  UIImage+Extension.m
//  Project-新浪微博
//
//  Created by zgjun on 14-8-7.
//  Copyright (c) 2014年 changeyourself. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)
+(UIImage *)resizableImageWithName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    /*对拉伸方法的理解
     leftCapWidth:左边不拉伸的宽度(一般都设置为imageWidth * 0.5)
     topCapHeight:上面不拉伸的高度(一般都设置为imageHeight * 0.5)
     还有两个参数：
     rightCapWidth = imageWidth - (leftCapWidth + 1);
     bottomCapHeight = imageHeight - (topCapHeight + 1);
     那么:
     rightCapWidth = imageWidth * 0.5 - 1
     bottomCapHeight = imageHeight * 0.5 - 1
     所以综上所述
     被拉伸的区域只有中间的一个点
     */
    //拉伸的方法有三种
    //1>
    //image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    //2>
    CGSize imageSize = image.size;
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageSize.height * 0.4, imageSize.width * 0.5, imageSize.height * 0.6, imageSize.width * 0.5)];
    //3>
    //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageSize.height * 0.5, imageSize.width * 0.5, imageSize.height * 0.5, imageSize.width * 0.5) resizingMode:UIImageResizingModeStretch];
    
    return image;
    
}
@end
