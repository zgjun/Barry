//
//  CSMarketCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSMarketCell : UIView
@property (nonatomic,strong) NSDictionary *marketDict;

- (instancetype)initWithLineType:(NSInteger)lineType;

@end
