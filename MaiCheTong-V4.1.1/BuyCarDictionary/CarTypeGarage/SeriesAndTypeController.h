//
//  CarSeriesChooseController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SeriesAndTypeController;

@protocol SeriesAndTypeDelegate <NSObject>

- (void)seriesAndTypeSelected:(NSDictionary *)contentDict;

@end

@interface SeriesAndTypeController : UIViewController

@property (nonatomic,weak) id<SeriesAndTypeDelegate> delegate;

- (instancetype)initWithDealerId:(NSString *)dealerId;

- (instancetype)initWithDealerId:(NSString *)dealerId carSeriesId:(NSString *)carSeriesId priceType:(NSString *)priceType;

@end
