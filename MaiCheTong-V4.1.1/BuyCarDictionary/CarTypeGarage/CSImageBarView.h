//
//  CSImageBarView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSImageBarView;
@class CarNavButton;

@protocol CSImageBarViewDelegate <NSObject>

- (void)cSImageBtnClick:(CSImageBarView *)cSImageBarView NavBtn:(UIButton *)carNavBtn;

@end

@interface CSImageBarView : UIView
@property (nonatomic,weak) id<CSImageBarViewDelegate> delegate;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;

//内容切换的视图
- (void)contentViewDidScroll:(UIScrollView *)scrollView;
@end
