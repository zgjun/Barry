//
//  OtherHotController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OtherHotController;

@protocol OtherHotDelegate <NSObject>

- (void)otherHotSelected:(NSDictionary *)carSeriesDict;

@end

@interface OtherHotController : UIViewController

- (instancetype)initWithIndicator:(NSString *)indicator;

@property (nonatomic,weak) id<OtherHotDelegate> delegate;

@end
