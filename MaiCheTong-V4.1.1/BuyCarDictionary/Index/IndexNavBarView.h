//
//  IndexNavBarView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>


@class IndexNavBarView;
@class CarNavButton;

@protocol IndexNavBarViewDelegate <NSObject>

- (void)indexBtnClick:(IndexNavBarView *)cTNavBarView NavBtn:(CarNavButton *)carNavBtn RemberSliderX:(CGFloat)remberSliderX;

@end

@interface IndexNavBarView : UIImageView

@property (nonatomic,weak) id<IndexNavBarViewDelegate> delegate;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;

- (instancetype)initWithRemberTag:(NSInteger)remberTag RemberSliderX:(CGFloat)remberSliderX;

- (void)contentViewDidScroll:(UIScrollView *)scrollView;

@end
