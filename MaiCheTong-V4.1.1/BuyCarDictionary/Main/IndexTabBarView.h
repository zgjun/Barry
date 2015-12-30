//
//  IndexTabBarView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndexTabBarView;

@protocol IndexTabBarViewDelegate <NSObject>

/** 选中自定义TabBar按钮 */
- (void)indexTabBarView:(IndexTabBarView *)indexTabBarView didSelectIndex:(NSInteger)index;

@end

@interface IndexTabBarView : UIImageView

- (void)barBtnclick:(UIButton *)btn;

//- (void)btnclick:(NSInteger)index;

@property (nonatomic, weak) id <IndexTabBarViewDelegate> delegate;


@end
