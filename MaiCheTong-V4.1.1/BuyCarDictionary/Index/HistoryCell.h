//
//  HistoryCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HistoryCell;

@protocol HistoryCellDelegate <NSObject>

- (void)historyCellClick:(HistoryCell *)historyCell;

@end

@interface HistoryCell : UIView
@property (nonatomic,strong) NSDictionary *historyCellDict;

@property (nonatomic,weak) id<HistoryCellDelegate> delegate;
@end
