//
//  CSContentCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-6.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSContentCell;

@protocol CSContentCellDelegate <NSObject>

- (void)cSContentCellClick:(CSContentCell *)contentCell;

@end

@interface CSContentCell : UIView

@property (nonatomic,strong) NSDictionary *cellDict;

@property (nonatomic,weak) id<CSContentCellDelegate> delegate;

@end
