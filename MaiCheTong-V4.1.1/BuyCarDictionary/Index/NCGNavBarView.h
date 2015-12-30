//
//  NCGNavBarView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-17.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NCGNavBarView;
@class CarNavButton;

@protocol NCGNavBarViewDelegate <NSObject>

- (void)nCGNavBtnClick:(NCGNavBarView *)nCGNavBarView NavBtn:(CarNavButton *)carNavBtn;

@end



@interface NCGNavBarView : UIView

@property (nonatomic,weak) id<NCGNavBarViewDelegate> delegate;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;

//内容切换的视图
- (void)contentViewDidScroll:(UIScrollView *)scrollView;

@end
