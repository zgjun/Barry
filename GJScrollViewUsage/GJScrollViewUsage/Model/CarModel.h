//
//  CarModel.h
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/18.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarModel : NSObject

@property (nonatomic,copy) NSString *seriesid;
@property (nonatomic,copy) NSString *seriesName;
@property (nonatomic,copy) NSString *seriesEnglish;
@property (nonatomic,strong) NSArray *paramtypeitems;

@end
