//
//  CSHeaderImageView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSHeaderImageView;

@protocol  CSHeaderImageViewDelegate<NSObject>

- (void)cSHeaderImageViewClick:(CSHeaderImageView *)headerImageView;

@end

@interface CSHeaderImageView : UIImageView

@property (nonatomic,weak) id<CSHeaderImageViewDelegate> delegate;

@end
