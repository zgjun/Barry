//
//  OtherChooseController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OtherChooseController;

@protocol OtherChooseDelegate <NSObject>

- (void)otherChooseSelected:(NSDictionary *)carSeriesDict;

@end

@interface OtherChooseController : UIViewController

@property (nonatomic,weak) id<OtherChooseDelegate> delegate;

- (instancetype)initWithIndicator:(NSString *)indicator;

@end
