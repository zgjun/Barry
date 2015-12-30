//
//  TabbarButton.m
//  DoAnythingYouWant
//
//  Created by zgjun on 15/12/24.
//  Copyright © 2015年 barry. All rights reserved.
//

#import "TabbarButton.h"
#import "TabbarItem.h"

#define ImageSize 20
#define TitleHeight 10

@interface TabbarButton() {
    SEL _action;
    NSObject *_target;
}

@property (nonatomic,weak) UIImageView *imageView;
@property (nonatomic,weak) UILabel *titleLabel;

@end

@implementation TabbarButton

- (instancetype)initWithTabbarItem:(TabbarItem *)tabbarItem {
    if (self = [super init]) {
        self.tabbarItem = tabbarItem;
        
        
        
        //初始化一些值
        self.titleColor = MainFontGrayColor;
        self.titleSelectedColor = MainGoldenColor;
        self.titleFont = [UIFont systemFontOfSize:10];
        self.titleSelectedFont = [UIFont systemFontOfSize:10];
        
        [self createChildViews];
    }
    return self;
}

- (void)createChildViews {
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:self.tabbarItem.imageName];
    self.imageView = imageView;
    [self addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = self.tabbarItem.titleName;
    titleLabel.font = self.titleFont;
    titleLabel.textColor = MainFontGrayColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.height = ImageSize;
    self.imageView.width = ImageSize;
    self.imageView.center = CGPointMake(self.width/2, 30/2);
    
    self.titleLabel.height = TitleHeight;
    self.titleLabel.width = self.width;
    self.titleLabel.center = CGPointMake(self.width/2,30 + (self.height - 30)/2);
    
}


- (void)addClickTarget:(NSObject *)target action:(SEL)action forEvents:(NSString *)event {
    
    _target = target;
    _action = action;
    
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.titleLabel.textColor = self.titleSelectedColor;
        self.titleLabel.font = self.titleSelectedFont;
        self.imageView.image = [UIImage imageNamed:self.tabbarItem.imageSelectedName];
    } else {
        self.titleLabel.textColor = self.titleColor;
        self.titleLabel.font = self.titleFont;
        self.imageView.image = [UIImage imageNamed:self.tabbarItem.imageName];
    }
}

/**
 *  点击事件
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([_target respondsToSelector:_action]) {
        
        [_target performSelector:_action withObject:self];
    }
}

@end
