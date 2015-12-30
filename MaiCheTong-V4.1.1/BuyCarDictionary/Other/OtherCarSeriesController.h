//
//  OtherCarTypeController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OtherCarSeriesController;

@protocol OtherCarSeriesDelegate <NSObject>

- (void)otherCarSeriesSelected:(NSDictionary *)carSeriesDict;

@end

@interface OtherCarSeriesController : UIViewController

@property (nonatomic,weak) id<OtherCarSeriesDelegate> delegate;

@property (nonatomic,strong) NSDictionary *brandInfo;

- (instancetype)initWithBrandInfo:(NSDictionary *)brandInfo;

- (instancetype)initWithBrandInfo:(NSDictionary *)brandInfo indicator:(NSString *)indicator;


@end
