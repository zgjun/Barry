//
//  ScreeningResultCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-19.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScreeningResultCell;

@protocol ScreeningResultCellDelegate <NSObject>

- (void)screeningResultCellClick:(ScreeningResultCell *)resultCell;

@end

@interface ScreeningResultCell : UIView

@property (nonatomic,weak) id<ScreeningResultCellDelegate> delegate;

@property (nonatomic,strong) NSDictionary *screeningResultDict;

@end
