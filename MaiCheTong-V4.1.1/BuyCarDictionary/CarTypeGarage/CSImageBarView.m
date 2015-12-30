//
//  CSImageBarView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSImageBarView.h"
#import "AFNetworking.h"


#define CSImageBarViewHeight 44
#define NavBtnNum 4
#define NavBtnWidth (ScreenWidth / (NavBtnNum + 0.5))
#define SliderHeight 2

@interface CSImageBarView()<UIScrollViewDelegate>
/**车型导航条*/
@property (nonatomic,weak) UIScrollView *cSNavBar;
/**车型导航线*/
@property (nonatomic,weak) UIView *cSNavLine;
/**导航线上的滑块*/
@property (nonatomic,weak) UIView *sliderBar;

@property (nonatomic,strong) NSMutableArray *navBtns;

@property (weak,nonatomic) UIButton *currentBtn;
@end

@implementation CSImageBarView

- (NSMutableArray *)navBtns {
    if (_navBtns == nil) {
        _navBtns = [NSMutableArray array];
    }
    return _navBtns;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = MainWhiteColor;
        //导航条
        UIScrollView *cSNavBar = [[UIScrollView alloc]init];
        cSNavBar.delegate = self;
        cSNavBar.bounces = NO;
        cSNavBar.showsHorizontalScrollIndicator = NO;
        
        self.cSNavBar = cSNavBar;
        [self addSubview:cSNavBar];
        //导航线
        UIView *cSNavLine = [[UIView alloc]init];
        self.cSNavLine = cSNavLine;
        cSNavLine.backgroundColor = MainLineGrayColor;
        [self.cSNavBar addSubview:cSNavLine];
        //滑块
        UIView *sliderBar = [[UIView alloc]init];
        self.sliderBar = sliderBar;
        sliderBar.backgroundColor = MainGoldenColor;
        [self.cSNavBar addSubview:sliderBar];
    }
    
    return self;
}


- (void)setNavTittles:(NSArray *)navTittles {
    _navTittles = navTittles;
    [self createCTNavBtn];
}

- (void)createCTNavBtn {
    for (int i = 0; i < self.navTittles.count; i++) {
        //创建按钮
        UIButton *navBtn = [[UIButton alloc]init];
        [navBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [navBtn setTitleColor:MainGoldenColor forState:UIControlStateSelected];
        navBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [navBtn setTitle:self.navTittles[i] forState:UIControlStateNormal];
        navBtn.tag = i ;
        
        [navBtn addTarget:self action:@selector(navBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.navBtns addObject:navBtn];
        [self.cSNavBar addSubview:navBtn];
        
        if (navBtn.tag == 0) {
            self.currentBtn.selected = NO;
            navBtn.selected = YES;
            self.currentBtn = navBtn;
            navBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        }
    }
}

/**导航按钮点击事件*/
- (void)navBtnClick:(UIButton *)navBtn {
    if (navBtn == self.currentBtn) return;
    self.currentBtn.selected = NO;
    navBtn.selected = YES;
    self.currentBtn = navBtn;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderBar.transform = CGAffineTransformMakeTranslation(navBtn.tag * NavBtnWidth, 0);
    }];
    
    //通知代理刷新列表
    if ([self.delegate respondsToSelector:@selector(cSImageBtnClick:NavBtn:)]) {
        [self.delegate cSImageBtnClick:self NavBtn:navBtn];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    //设置车型子视图的frame
    self.cSNavBar.frame = CGRectMake(0, 0, ScreenWidth,CSImageBarViewHeight);
    self.cSNavBar.contentSize = CGSizeMake(self.navBtns.count * NavBtnWidth, CSImageBarViewHeight);
    
    
    
    self.cSNavLine.frame = CGRectMake(0, self.cSNavBar.height - SliderHeight, self.navBtns.count * NavBtnWidth, SliderHeight);
    self.sliderBar.frame = CGRectMake(0, self.cSNavBar.height - SliderHeight, NavBtnWidth, SliderHeight);
    
    
    for (UIButton *btn in self.navBtns) {
        btn.frame = CGRectMake((btn.tag) * NavBtnWidth, 0, NavBtnWidth, CSImageBarViewHeight - 4);
        
    }
}

- (void)contentViewDidScroll:(UIScrollView *)scrollView {
    
    //控制滑块的移动
    self.sliderBar.transform = CGAffineTransformMakeTranslation((scrollView.contentOffset.x / ScreenWidth) * NavBtnWidth, 0);
    CGFloat sliderX;
    CGFloat contentSizeW = self.cSNavBar.contentSize.width;
    CGFloat contentOffSetX = self.cSNavBar.contentOffset.x;
    CGFloat frameW = ScreenWidth;
    if (self.sliderBar.x >= contentOffSetX + ScreenWidth) {
        
        if (frameW * 0.5 >= contentSizeW - contentOffSetX - frameW) {
            sliderX = contentSizeW - contentOffSetX - frameW;
        } else {
            sliderX = frameW * 0.5;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.cSNavBar.contentOffset = CGPointMake(contentOffSetX + sliderX, 0);
        }];
        
    }
    if (self.sliderBar.x <= contentOffSetX) {
        
        if (frameW * 0.5 > contentOffSetX) {
            sliderX = contentOffSetX;
        } else {
            sliderX = frameW * 0.5;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.cSNavBar.contentOffset = CGPointMake(contentOffSetX - sliderX, 0);
        }];
        
    }
    
    NSInteger pageNum = scrollView.contentOffset.x / ScreenWidth;
    
    for (UIButton *navBtn in self.navBtns) {
        if (pageNum == navBtn.tag) {
            self.currentBtn.selected = NO;
            navBtn.selected = YES;
            self.currentBtn = navBtn;
            navBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        } else {
            navBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        }
    }
}



@end
