//
//  CSNavBarView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-5.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSNavBarView.h"
#import "AFNetworking.h"
#import "CarNavButton.h"


#define CSNavBarViewHeight 44
#define NavBtnNum 3
#define NavBtnWidth (ScreenWidth / NavBtnNum)
#define SliderHeight 2


@interface CSNavBarView()<UIScrollViewDelegate>
/**车型导航条*/
@property (nonatomic,weak) UIScrollView *cSNavBar;
/**车型导航线*/
@property (nonatomic,weak) UIView *cSNavLine;
/**导航线上的滑块*/
@property (nonatomic,weak) UIView *sliderBar;

@property (nonatomic,strong) NSMutableArray *navBtns;

@property (weak,nonatomic) UIButton *currentBtn;


@end


@implementation CSNavBarView

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
    [self layoutSubviews];
}

- (void)createCTNavBtn {
    for (int i = 1; i < self.navTittles.count; i++) {
        //创建按钮
        CarNavButton *navBtn = [[CarNavButton alloc]init];
        [navBtn setTitleColor:MainBlackColor forState:UIControlStateNormal];
        [navBtn setTitleColor:MainGoldenColor forState:UIControlStateSelected];
        navBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        
        
        navBtn.tag = i;
        [navBtn setTitle:[NSString stringWithFormat:@"%@L",self.navTittles[i-1]] forState:UIControlStateNormal];
        
        [navBtn addTarget:self action:@selector(navBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.navBtns addObject:navBtn];
        [self.cSNavBar addSubview:navBtn];
        
        if (navBtn.tag == 1) {
            self.currentBtn.selected = NO;
            navBtn.selected = YES;
            self.currentBtn = navBtn;
            
        }
    }
}

/**导航按钮点击事件*/
- (void)navBtnClick:(CarNavButton *)navBtn {
    
    if (navBtn == self.currentBtn) return;
    
    
    self.currentBtn.selected = NO;
    navBtn.selected = YES;
    self.currentBtn = navBtn;
    
    CGFloat btnWidth = 0.0;
    if (self.navBtns.count == 1) {
        btnWidth = self.width;
    } else if (self.navBtns.count == 2) {
        btnWidth = self.width * 0.5;
    } else {
        btnWidth = NavBtnWidth;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderBar.transform = CGAffineTransformMakeTranslation((navBtn.tag - 1) * btnWidth, 0);
    }];
    
    //通知代理刷新列表
    if ([self.delegate respondsToSelector:@selector(cSNavBtnClick:Displacement:)]){
        [self.delegate cSNavBtnClick:self Displacement:[NSString stringWithFormat:@"%@",self.navTittles[navBtn.tag - 1]]];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    //设置车型子视图的frame
    self.cSNavBar.frame = CGRectMake(0, 0, ScreenWidth,CSNavBarViewHeight);
    self.cSNavBar.contentSize = CGSizeMake(self.navBtns.count * NavBtnWidth, CSNavBarViewHeight);
    
    
    if (self.navBtns.count == 1) {
        CarNavButton *btn = self.navBtns[0];
        btn.frame = CGRectMake(0, 0, self.width, CSNavBarViewHeight - 4);
        self.cSNavLine.frame = CGRectMake(0, self.cSNavBar.height - SliderHeight, self.width, SliderHeight);
        self.sliderBar.frame = CGRectMake((ScreenWidth - NavBtnWidth) * 0.5, self.cSNavBar.height - SliderHeight, NavBtnWidth, SliderHeight);
    } else if (self.navBtns.count == 2) {
        CarNavButton *btn0 = self.navBtns[0];
        btn0.frame = CGRectMake(0, 0, self.width * 0.5, CSNavBarViewHeight - 4);
        CarNavButton *btn1 = self.navBtns[1];
        btn1.frame = CGRectMake(self.width * 0.5, 0, self.width * 0.5, CSNavBarViewHeight - 4);
        self.cSNavLine.frame = CGRectMake(0, self.cSNavBar.height - SliderHeight, self.width, SliderHeight);
        
        self.sliderBar.frame = CGRectMake(0, self.cSNavBar.height - SliderHeight, self.width * 0.5, SliderHeight);
    } else {
        for (CarNavButton *btn in self.navBtns) {
            btn.frame = CGRectMake((btn.tag - 1) * NavBtnWidth, 0, NavBtnWidth, CSNavBarViewHeight - 4);
            
        }
        self.cSNavLine.frame = CGRectMake(0, self.cSNavBar.height - SliderHeight, self.navBtns.count * NavBtnWidth, SliderHeight);
        
        self.sliderBar.frame = CGRectMake(0, self.cSNavBar.height - SliderHeight, NavBtnWidth, SliderHeight);
    }
}
@end
