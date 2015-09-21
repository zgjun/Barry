//
//  ParameterCarTypeView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-29.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ParameterCarTypeView;

@protocol ParameterCarTypeViewDelegate <NSObject>

- (void)parameterReduceBtnClick:(ParameterCarTypeView *)carTypeView;

- (void)parameterAddBtnClick:(ParameterCarTypeView *)carTypeView;

@end

@interface ParameterCarTypeView : UIView

@property (nonatomic,strong) NSDictionary *dataDict;

@property (nonatomic,weak) id<ParameterCarTypeViewDelegate> delegate;

@end
