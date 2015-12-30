//
//  CanBuyCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CanBuyCell;

@protocol CanBuyCellDelegate <NSObject>

- (void)canBuyCellClick:(CanBuyCell *)canBuyCell;

@end
@interface CanBuyCell : UIView
@property (nonatomic,strong) NSDictionary *canBuyDict;

@property (nonatomic,weak) id<CanBuyCellDelegate> delegate;


/*
 0:未选中
 1:选中
 2:不可用
 */
@property (nonatomic,assign) NSInteger isSelected;


- (instancetype)initWithSelectCount:(NSInteger)selectCount;
@end
