//
//  IndexContentCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IndexContentCell;

@protocol IndexContentCellDelegate <NSObject>

- (void)carTypeCellViewClick:(IndexContentCell *)carTypeCellView;

@end

@interface IndexContentCell : UIView
@property (nonatomic,strong) NSDictionary *dataDict;

@property (nonatomic,weak) id<IndexContentCellDelegate> delegate;
@end


