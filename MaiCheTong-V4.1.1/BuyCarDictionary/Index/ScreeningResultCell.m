//
//  ScreeningResultCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-19.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ScreeningResultCell.h"

@implementation ScreeningResultCell

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(screeningResultCellClick:)]) {
        [self.delegate screeningResultCellClick:self];
    }
}

@end
