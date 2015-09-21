//
//  CarParamItemModel.m
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/18.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarParamItemModel.h"
#import "CarValueitemModel.h"

@implementation CarParamItemModel

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"ID" : @"id"};
}

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"valueitems" : [CarValueitemModel class]
             };
}

@end
