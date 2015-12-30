//
//  CTBgView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-21.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CTBgView;

@protocol CTBgViewDelegate <NSObject>

- (void)cTBgViewClick;

@end

@interface CTBgView : UIView

@property (nonatomic,weak) id<CTBgViewDelegate> delegate;
@end
