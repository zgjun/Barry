//
//  PriceContentView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-20.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "PriceContentView.h"
#define PriceCellWidth (ScreenWidth - 80) * 0.5

@interface PriceContentView()
@property (nonatomic,weak) UILabel *companyPrice;
@property (nonatomic,weak) UILabel *gobalLowPrice;
@end

@implementation PriceContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, PriceCellWidth, 1)];
        topLine.backgroundColor = MainBackGroundColor;
        [self addSubview:topLine];
        
        UILabel *companyPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, PriceCellWidth, 30)];
        self.companyPrice = companyPrice;
        companyPrice.textAlignment = NSTextAlignmentCenter;
//        companyPrice.text = @"厂商指导价";
        companyPrice.font = [UIFont systemFontOfSize:12];
        [self addSubview:companyPrice];
        
        UIView *centerLine = [[UIView alloc]initWithFrame:CGRectMake(0, 29, PriceCellWidth, 1)];
        centerLine.backgroundColor = MainBackGroundColor;
        [self addSubview:centerLine];
        
        UILabel *gobalLowPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, PriceCellWidth, 30)];
        self.gobalLowPrice = gobalLowPrice;
        gobalLowPrice.textAlignment = NSTextAlignmentCenter;
        gobalLowPrice.font = [UIFont systemFontOfSize:12];
        gobalLowPrice.textColor = MainFontRedColor;
//        gobalLowPrice.text = @"全国最低价";
        [self addSubview:gobalLowPrice];
        
        UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 59, PriceCellWidth, 1)];
        bottomLine.backgroundColor = MainBackGroundColor;
        [self addSubview:bottomLine];
        
        UIView *upRightLine = [[UIView alloc]initWithFrame:CGRectMake(PriceCellWidth - 1, 0, 1, 30)];
        upRightLine.backgroundColor = MainBackGroundColor;
        [self addSubview:upRightLine];
        
        UIView *downRightLine = [[UIView alloc]initWithFrame:CGRectMake(PriceCellWidth - 1, 30, 1, 30)];
        downRightLine.backgroundColor = MainBackGroundColor;
        [self addSubview:downRightLine];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    self.companyPrice.text = dataDict[@"companyPrice"];
    self.gobalLowPrice.text = dataDict[@"lowPrice"];
}

@end
