//
//  TimeTool.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-2.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTool : NSObject
+ (NSString *)returnSampleTime:(NSString *)timeStr;
+ (NSString *)returnRemainTime:(NSString *)timeStr;
+ (NSString *)returnStringTime:(NSString *)timeStr;
@end
