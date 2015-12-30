//
//  BrandCellView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-8.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrandCellView;

@protocol BrandCellViewDelegate <NSObject>

- (void)brandCellViewClick:(BrandCellView *)brandCellView;

@end



@interface BrandCellView : UIView

@property (nonatomic,strong) NSDictionary *dataDict;

@property (nonatomic,weak) id<BrandCellViewDelegate> delegate;

@end
