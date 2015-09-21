//
//  CarParamTypeModel.h
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/18.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarParamTypeModel : NSObject

@property (nonatomic,assign) NSInteger typeId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSArray *paramitems;

@end
