//
//  TabbarButton.h
//  DoAnythingYouWant
//
//  Created by zgjun on 15/12/24.
//  Copyright © 2015年 barry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TabbarItem;

@interface TabbarButton : UIView

@property (nonatomic,strong) UIColor *titleColor;
@property (nonatomic,strong) UIColor *titleSelectedColor;
@property (nonatomic,strong) UIFont *titleFont;
@property (nonatomic,strong) UIFont *titleSelectedFont;

@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,strong) TabbarItem *tabbarItem;

- (instancetype)initWithTabbarItem:(TabbarItem *)tabbarItem;

- (void)addClickTarget:(NSObject *)target action:(SEL)action forEvents:(NSString *)event;
@end
