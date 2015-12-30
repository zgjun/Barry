//
//  CTContentCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-8.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CTContentCell;

@protocol CTContentCellDelegate <NSObject>

- (void)cTContentPhoneClick:(NSDictionary *)dealerDict;
- (void)cTContentTryDriveClick:(NSDictionary *)dealerDict;
- (void)cTContentLowPriceClick:(NSDictionary *)dealerDict;


@end

@interface CTContentCell : UIView

@property (nonatomic,weak) id<CTContentCellDelegate> delegate;

@property (nonatomic,strong) NSDictionary *dealerDict;

@end
