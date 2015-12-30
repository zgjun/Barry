//
//  QueryDealerCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QueryDealerCell;

@protocol QueryDealerCellDelegate <NSObject>

- (void)queryCellClick:(QueryDealerCell *)dealerCell QueryBtn:(UIButton *)queryBtn;

@end

@interface QueryDealerCell : UIView

@property (nonatomic,strong) NSMutableDictionary *queryDict;

@property (nonatomic,weak) id<QueryDealerCellDelegate> delegate;

@end
