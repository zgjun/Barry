//
//  CTBgView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-21.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CTBgView.h"

@implementation CTBgView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(cTBgViewClick)]) {
        [self.delegate cTBgViewClick];
    }
}

@end
