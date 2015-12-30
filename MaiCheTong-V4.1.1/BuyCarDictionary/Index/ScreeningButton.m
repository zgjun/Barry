//
//  ScreeningButton.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-7.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "ScreeningButton.h"
#define ScreeningRatio 0.4
#define GapHeight 6

@implementation ScreeningButton

//- (void)setHighlighted:(BOOL)highlighted {
//
//}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, GapHeight, self.width, self.height * ScreeningRatio);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, self.height * ScreeningRatio, self.width, self.height * (1 - ScreeningRatio));
}


@end
