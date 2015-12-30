//
//  TabbarCustom.m
//  DoAnythingYouWant
//
//  Created by zgjun on 15/12/24.
//  Copyright © 2015年 barry. All rights reserved.
//

#import "TabbarCustom.h"
#import "TabbarButton.h"

@interface TabbarCustom()
@property (nonatomic,strong) NSMutableArray *buttons;
@property (nonatomic,weak) UIView *spliteLine;
@property (nonatomic,weak) TabbarButton *selectedButton;
@end

@implementation TabbarCustom

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.tabbarItems = [NSMutableArray array];
        
    }
    return self;
}

- (void)setTabbarItems:(NSMutableArray *)tabbarItems{
    if (tabbarItems == nil) return;
    _tabbarItems = tabbarItems;
    self.buttons = [NSMutableArray array];

    //create TabbarButton
    
    for (int i = 0; i < tabbarItems.count; i++) {
        TabbarButton *tabbarButton = [[TabbarButton alloc]initWithTabbarItem:tabbarItems[i]];
        tabbarButton.tag = i;
        if (i == 0) {
           tabbarButton.isSelected = YES;
            self.selectedButton = tabbarButton;
        } else {
            tabbarButton.isSelected = NO;
        }
        [tabbarButton addClickTarget:self action:@selector(tabbarButtonClick:) forEvents:@"touchUp"];
        tabbarButton.backgroundColor = [UIColor whiteColor];
        [self.buttons addObject:tabbarButton];
        [self addSubview:tabbarButton];
    }
    
    UIView *spliteLine = [[UIView alloc]init];
    self.spliteLine = spliteLine;
    spliteLine.backgroundColor = MainLineGrayColor;
    [self addSubview:spliteLine];
}


- (void)tabbarButtonClick:(TabbarButton *)btn {
    
    if (btn == self.selectedButton) return;
    btn.isSelected = !btn.isSelected;
    if (btn.isSelected) {
        self.selectedButton.isSelected = NO;
        self.selectedButton = btn;
    }
    self.tabJumpBlock(btn.tag);
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonWidth = (ScreenWidth / self.buttons.count);
    for (int i = 0; i < self.buttons.count; i++) {
        TabbarButton *tabbarButton = self.buttons[i];
        tabbarButton.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, self.height);
    }
    
    self.spliteLine.frame = CGRectMake(0, 0, ScreenWidth, 0.5);
    
}



@end
