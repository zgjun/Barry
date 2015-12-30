//
//  CanBuyCarCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-3.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CanBuyCarCell;

@protocol CanBuyCarCellDelegate <NSObject>

- (void)canBuyCarCellSelected;

@end

@interface CanBuyCarCell : UIView

- (instancetype)initWithCanBuyCarDict:(NSDictionary *)canBuyCarDict;

@property (nonatomic,weak) id<CanBuyCarCellDelegate> delegate;

@end
