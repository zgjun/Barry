//
//  OtherCarTypeController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OtherCarTypeController;

@protocol OtherCarTypeDelegate <NSObject>

- (void)otherCarTypeSelected:(NSDictionary *)carTypeDict;

@end

@interface OtherCarTypeController : UIViewController

@property (nonatomic,weak) id<OtherCarTypeDelegate> delegate;

- (instancetype)initWithCarSeriesId:(NSString *)carSeriesId;

@end
