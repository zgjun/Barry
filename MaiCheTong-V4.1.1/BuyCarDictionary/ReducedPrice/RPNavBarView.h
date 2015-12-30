//
//  CTNavBarView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-3.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RPNavBarView;
@class CarNavButton;

@protocol RPNavBarViewDelegate <NSObject>

- (void)rPNavBtnClick:(RPNavBarView *)rPNavBarView NavBtn:(CarNavButton *)carNavBtn;

@end



@interface RPNavBarView : UIView

@property (nonatomic,weak) id<RPNavBarViewDelegate> delegate;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;

//内容切换的视图
- (void)contentViewDidScroll:(UIScrollView *)scrollView;

@end
