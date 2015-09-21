//
//  ItemModel.m
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/18.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ItemModel.h"
#import "ValueItemModel.h"

@implementation ItemModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"valueitems" : [ValueItemModel class]
             };
}

@end
