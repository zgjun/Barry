//
//  CarInsuranceCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-31.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarInsuranceCell;

@protocol CarInsuranceCellDelegate <NSObject>

- (void)carInsuranceCellChangeValue:(NSInteger)rowValue component:(NSInteger)component;

- (void)carInsuranceCellSwitch:(BOOL)isSwitch rowValue:(NSInteger)rowValue;

@end

@interface CarInsuranceCell : UIView

@property (nonatomic,weak) UILabel *contentLabel;

@property (nonatomic,weak) id<CarInsuranceCellDelegate> delegate;

@property (nonatomic,assign) NSInteger rowValue;

- (instancetype)initWithInsuranceDict:(NSDictionary *)insuranceDict isChoose:(BOOL)isChoose contentArr:(NSArray *)contentArr;

@end
