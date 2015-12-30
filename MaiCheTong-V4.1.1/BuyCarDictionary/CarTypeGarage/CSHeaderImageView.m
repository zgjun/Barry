//
//  CSHeaderImageView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSHeaderImageView.h"

@implementation CSHeaderImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(cSHeaderImageViewClick:)]) {
        [self.delegate cSHeaderImageViewClick:self];
    }
}

@end
