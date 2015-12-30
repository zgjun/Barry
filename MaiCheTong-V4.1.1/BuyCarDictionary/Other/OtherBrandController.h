//
//  OtherBrandController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OtherBrandController;

@protocol OtherBrandDelegate <NSObject>

- (void)otherBrandSelected:(NSDictionary *)carSeriesDict;

@end

@interface OtherBrandController : UIViewController

- (instancetype)initWithIndicator:(NSString *)indicator;

@property (nonatomic,weak) id<OtherBrandDelegate> delegate;

@end
