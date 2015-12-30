//
//  CarTypeScreenController.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-31.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarTypeScreenController;

@protocol CarTypeScreenControllerDelegate <NSObject>

- (void)cTParaChooseBgClick;

- (void)carTypeScreenViewBtnClick:(NSString *)conditionStr screenSelected:(NSMutableDictionary *)screenSelected;

@end

@interface CarTypeScreenController : UIViewController


@property (nonatomic,strong) NSDictionary *conditionData;

- (instancetype)initWithConditions:(NSDictionary *)conditions screenSelected:(NSMutableDictionary *)screenSelected;

@property (nonatomic,weak) id<CarTypeScreenControllerDelegate> delegate;

@end
