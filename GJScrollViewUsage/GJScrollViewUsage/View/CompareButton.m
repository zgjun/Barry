//
//  CompareButton.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-31.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "CompareButton.h"

@implementation CompareButton


- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0.3 * self.width, 0, 0.7 * self.width, self.height);
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, 0, 0.3 * self.width, self.height);
}
@end
