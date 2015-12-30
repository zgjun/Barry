//
//  CTNavBarView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-3.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CTNavBarView;
@class CarNavButton;

@protocol RPNavBarViewDelegate <NSObject>

- (void)cTNavBtnClick:(CTNavBarView *)cTNavBarView NavBtn:(CarNavButton *)carNavBtn RemberSliderX:(CGFloat)remberSliderX;

@end



@interface CTNavBarView : UIView

@property (nonatomic,weak) id<RPNavBarViewDelegate> delegate;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;

- (instancetype)initWithRemberTag:(NSInteger)remberTag RemberSliderX:(CGFloat)remberSliderX;

@end
