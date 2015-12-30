//
//  OtherCompareCarView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-15.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OtherCompareCarView;

@protocol OtherCompareCarViewDelegate <NSObject>

- (void)otherReduceBtnClick:(OtherCompareCarView *)carTypeView;

- (void)otherCompareBtnClick;

@end


@interface OtherCompareCarView : UIView
@property (nonatomic,strong) NSDictionary *dataDict;

@property (nonatomic,weak) id<OtherCompareCarViewDelegate> delegate;


@end
