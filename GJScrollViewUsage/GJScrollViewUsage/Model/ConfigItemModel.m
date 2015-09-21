//
//  ConfigItemModel.m
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/18.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ConfigItemModel.h"
#import "ItemModel.h"

@implementation ConfigItemModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"configitems" : [ItemModel class]
             };
}

@end
