//
//  NSString+Deal.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-3-19.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "NSString+Deal.h"

@implementation NSString (Deal)

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
