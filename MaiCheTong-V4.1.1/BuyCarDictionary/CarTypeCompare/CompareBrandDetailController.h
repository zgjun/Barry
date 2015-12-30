//
//  CompareBrandDetailController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-25.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompareBrandDetailController : UIViewController

@property (nonatomic,strong) NSDictionary *brandInfo;

- (instancetype)initWithBrandInfo:(NSDictionary *)brandInfo;

@end
