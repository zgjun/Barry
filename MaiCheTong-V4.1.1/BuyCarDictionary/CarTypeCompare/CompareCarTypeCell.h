//
//  CompareCarTypeCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-25.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CompareCarTypeCell;

@protocol CompareCarTypeSelectedDelegate <NSObject>

- (void)compareCarTypeSelectedClick:(CompareCarTypeCell *)contentCell;

@end

@interface CompareCarTypeCell : UIView
@property (nonatomic,strong) NSDictionary *cellDict;

@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,weak) id<CompareCarTypeSelectedDelegate> delegate;
@end
