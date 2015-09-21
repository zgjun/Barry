//
//  CarItemModel.m
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/18.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarItemModel.h"
#import "ConfigItemModel.h"

@implementation CarItemModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"configItemModels" : [ConfigItemModel class]
             };
}

@end
