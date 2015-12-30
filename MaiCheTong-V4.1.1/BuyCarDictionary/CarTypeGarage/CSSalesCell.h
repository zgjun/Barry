//
//  CSSalesCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSSalesCell;

@protocol CSSalesCellDelegate <NSObject>

- (void)cSSalesCellClick:(CSSalesCell *)saleCell;

@end

@interface CSSalesCell : UIView

@property (nonatomic,strong) NSDictionary *salesDict;

@property (nonatomic,weak) id<CSSalesCellDelegate> delegate;

@end
