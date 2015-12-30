//
//  IndexTabBarView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "IndexTabBarView.h"
#import "NonHighButton.h"

#import "UIImage+Extension.h"

@interface IndexTabBarView()
@property (nonatomic, weak) UIButton *selectedButton;

@property (nonatomic,weak) UIButton *ctcBtn;
@end

@implementation IndexTabBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.image = [UIImage resizableImageWithName:@"chexun_navbarbg"];
        //在这里创建五个按钮
        //首页
        UIButton *indexBtn = [[UIButton alloc]init];
        indexBtn.tag = 0;
        indexBtn.contentMode = UIViewContentModeCenter;
        [indexBtn setImage:[UIImage imageNamed:@"chexun_modelsicon"] forState:UIControlStateNormal];
        [indexBtn setImage:[UIImage imageNamed:@"chexun_modelsicon_selected"] forState:UIControlStateSelected];
        [indexBtn addTarget:self action:@selector(barBtnclick:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:indexBtn];
        //车型库
        UIButton *ctgBtn = [[UIButton alloc]init];
        ctgBtn.tag = 1;
        [ctgBtn setImage:[UIImage imageNamed:@"chexun_homeicon"] forState:UIControlStateNormal];
        [ctgBtn setImage:[UIImage imageNamed:@"chexun_homeicon_selected"] forState:UIControlStateSelected];
        [ctgBtn addTarget:self action:@selector(barBtnclick:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:ctgBtn];
        
        UIButton *otherBtn = [[UIButton alloc]init];
        
        otherBtn.tag = 2;
        [otherBtn setImage:[UIImage imageNamed:@"chexun_othericon"] forState:UIControlStateNormal];
        [otherBtn setImage:[UIImage imageNamed:@"chexun_othericon_selected"] forState:UIControlStateSelected];
        [otherBtn addTarget:self action:@selector(barBtnclick:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:otherBtn];
        
        //添加通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compareChoose) name:@"compareChoose" object:nil];
        
    }
    return self;
}
- (void)compareChoose {
    [self barBtnclick:self.ctcBtn];
}

- (void)dealloc {
    //移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 重新调整按钮的位置，现在视图中有几个子视图
    CGFloat y = 0;
    CGFloat w = self.bounds.size.width / self.subviews.count;
    CGFloat h = self.bounds.size.height;
    
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *btn = self.subviews[i];
        
        // 设置按钮位置
        CGFloat x = i * w;
        
        btn.frame = CGRectMake(x, y, w, h);
        
        // 设置按钮的索引
        btn.tag = i;
        
        if (i == 0) {
            [self barBtnclick:(UIButton *)btn];
        }
    }
}

/**
 1> 记录住上一次选中的按钮
 2> 遍历所有按钮
 */
- (void)barBtnclick:(UIButton *)btn
{

    if (self.selectedButton == btn) return;
    
    btn.selected = YES;
    
    [self.selectedButton setSelected:NO];
    
    
    // 把button当成被选中的按钮
    self.selectedButton = btn;
    
    // 修改selectedIndex，可以切换TabBarController的视图控制器
    if ([self.delegate respondsToSelector:@selector(indexTabBarView:didSelectIndex:)]) {
        [self.delegate indexTabBarView:self didSelectIndex:btn.tag];
    }
}

//- (void)btnclick:(NSInteger)index {
//    UIButton *btn = (UIButton *)[self viewWithTag:index];
//    
//    [self barBtnclick:btn];
//}

@end
