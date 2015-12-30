//
//  OtherFourSCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OtherFourSCell;

@protocol OtherFourSCellDelegate <NSObject>

- (void)activeBtnClick:(NSString *)activeUrl;

@end

@interface OtherFourSCell : UIView

@property (nonatomic,weak) id<OtherFourSCellDelegate> delegate;

@property (nonatomic,strong) NSDictionary *dealerDict;

@end
