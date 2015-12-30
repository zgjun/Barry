//
//  CSImageView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-3-2.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSImageView;

@protocol CSImageViewDelegate <NSObject>

- (void)cSImageViewClick:(CSImageView *)cSImageView;

@end

@interface CSImageView : UIImageView

@property (nonatomic,weak) id<CSImageViewDelegate> delegate;

@end
