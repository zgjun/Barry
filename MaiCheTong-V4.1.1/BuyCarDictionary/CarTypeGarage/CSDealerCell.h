//
//  CSDealerCell.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-9.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSDealerCell;

@protocol CSDealerCellDelegate <NSObject>

- (void)activeBtnClick:(NSString *)activeUrl;

@end

@interface CSDealerCell : UIView

@property (nonatomic,weak) id<CSDealerCellDelegate> delegate;

@property (nonatomic,strong) NSDictionary *dealerDict;

- (instancetype)initWithLineType:(NSInteger)lineType;
@end
