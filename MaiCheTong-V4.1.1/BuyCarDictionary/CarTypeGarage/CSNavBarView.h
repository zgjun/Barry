//
//  CSNavBarView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-5.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CSNavBarView;
@class CarNavButton;

@protocol CSNavBarViewDelegate <NSObject>

- (void)cSNavBtnClick:(CSNavBarView *)cSNavBarView Displacement:(NSString *)displacement;

@end



@interface CSNavBarView : UIView

@property (nonatomic,weak) id<CSNavBarViewDelegate> delegate;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;

//内容切换的视图
//- (void)contentViewDidScroll:(UIScrollView *)scrollView;
//
//- (void)contentViewEndScroll:(NSInteger)pageNum;

@end
