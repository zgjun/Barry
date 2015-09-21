//
//  ParameterCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-29.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParameterCell : UIView

@property (nonatomic,strong) NSString *contentStr;

@property (nonatomic,assign) BOOL isAll;

- (instancetype)initWithFrame:(CGRect)frame indicator:(NSString *)indicator;

@end
