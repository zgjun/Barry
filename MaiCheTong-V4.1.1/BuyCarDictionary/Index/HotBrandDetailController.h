//
//  HotBrandDetailController.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-16.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotBrandDetailController : UIViewController

@property (nonatomic,strong) NSDictionary *brandInfo;


- (instancetype)initWithBrandInfo:(NSDictionary *)brandInfo;

@end
