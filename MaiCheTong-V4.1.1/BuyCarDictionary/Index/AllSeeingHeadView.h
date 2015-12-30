//
//  HistoryHeadView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-2.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AllSeeingHeadView;

@protocol  AllSeeingHeadViewDelegate<NSObject>

- (void)allSeeingHeadViewClick;

@end

@interface AllSeeingHeadView : UIView

@property (nonatomic,weak) id<AllSeeingHeadViewDelegate> delegate;

@end
