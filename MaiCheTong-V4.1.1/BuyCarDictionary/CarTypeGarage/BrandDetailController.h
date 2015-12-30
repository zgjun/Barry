//
//  BrandDetailController.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-19.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BrandDetailControllerDelegate <NSObject>

- (void)closeClick;

@end

@interface BrandDetailController : UIViewController
@property (nonatomic,strong) NSDictionary *brandInfo;

@property (nonatomic,weak) id<BrandDetailControllerDelegate> delegate;


- (instancetype)initWithBrandInfo:(NSDictionary *)brandInfo;
@end
