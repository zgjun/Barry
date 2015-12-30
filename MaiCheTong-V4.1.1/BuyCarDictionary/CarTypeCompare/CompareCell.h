//
//  CompareCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CompareCell;

@protocol CompareCellDelegate <NSObject>

- (void)compareCellClick:(CompareCell *)compareCell;

@end

@interface CompareCell : UIView

@property (nonatomic,strong) NSDictionary *compareDict;

@property (nonatomic,weak) id<CompareCellDelegate> delegate;

/*
 0:未选中
 1:选中
 2:不可用
 */
@property (nonatomic,assign) NSInteger isSelected;



- (instancetype)initWithSelectCount:(NSInteger)selectCount;

@end
