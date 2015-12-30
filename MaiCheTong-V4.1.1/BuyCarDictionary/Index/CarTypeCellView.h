//
//  CarTypeCellView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-2.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarTypeCellView;

@protocol CarTypeCellViewDelegate <NSObject>

- (void)carTypeCellViewClick:(CarTypeCellView *)carTypeCellView;

@end

@interface CarTypeCellView : UIView

@property (nonatomic,strong) NSDictionary *dataDict;

@property (nonatomic,weak) id<CarTypeCellViewDelegate> delegate;

@end
