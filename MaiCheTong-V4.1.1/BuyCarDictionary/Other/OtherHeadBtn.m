//
//  OtherHeadBtn.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherHeadBtn.h"

@implementation OtherHeadBtn


- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(contentRect.size.width * 0.6 -  10 - 38, 0, 38, contentRect.size.height);
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(contentRect.size.width * 0.6, (contentRect.size.height - 10) * 0.5, 10, 5);
}

@end
