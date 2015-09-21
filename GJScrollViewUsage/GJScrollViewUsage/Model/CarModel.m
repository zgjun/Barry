//
//  CarModel.m
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/18.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarModel.h"
#import "CarParamTypeModel.h"

@implementation CarModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"paramtypeitems" : [CarParamTypeModel class]
             };
}

@end
