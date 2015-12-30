//
//  CSImageView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-3-2.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSImageView.h"

@implementation CSImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(cSImageViewClick:)]) {
        [self.delegate cSImageViewClick:self];
    }
}

@end
