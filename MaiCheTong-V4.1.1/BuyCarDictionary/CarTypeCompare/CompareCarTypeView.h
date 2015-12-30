//
//  CompareCarTypeView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-15.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CompareCarTypeView;

@protocol CompareCarTypeViewDelegate <NSObject>

- (void)compareReduceBtnClick:(CompareCarTypeView *)carTypeView;

@end
@interface CompareCarTypeView : UIView
@property (nonatomic,strong) NSDictionary *dataDict;

@property (nonatomic,weak) id<CompareCarTypeViewDelegate> delegate;
@end
