//
//  CarParamTypeModel.m
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/18.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarParamTypeModel.h"
#import "CarParamItemModel.h"

@implementation CarParamTypeModel
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"paramitems" : [CarParamItemModel class]
             };
}

@end
