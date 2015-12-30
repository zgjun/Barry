//
//  CalculateTool.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-3-20.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculateTool : NSObject

+ (NSDictionary *)calculateTax:(CGFloat)pureValue taxDictM:(NSMutableDictionary *)taxDictM;
+ (NSDictionary *)calculateInsurance:(CGFloat)pureValue insureDictM:(NSMutableDictionary *)insureDictM familySites:(NSInteger)familySites;

@end
