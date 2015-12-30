//
//  CTNavBarView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-3.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "RPNavBarView.h"

#import "CarNavButton.h"

#define RPNavBarViewHeight 44
#define SliderHeight 2

#define NavBtnNum (ScreenWidth < 375 ? 3 : 4)
#define NavBtnWidth (ScreenWidth / (NavBtnNum + 0.5))



@interface RPNavBarView()<UIScrollViewDelegate>
/**车型导航条*/
@property (nonatomic,weak) UIScrollView *rPNavBar;
/**车型导航线*/
@property (nonatomic,weak) UIView *rPNavLine;
/**导航线上的滑块*/
@property (nonatomic,weak) UIView *sliderBar;

@property (nonatomic,strong) NSMutableArray *navBtns;

@property (weak,nonatomic) UIButton *currentBtn;
@end


@implementation RPNavBarView

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
        UIScrollView *rPNavBar = [[UIScrollView alloc]init];
        rPNavBar.delegate = self;
        rPNavBar.bounces = NO;
        rPNavBar.showsHorizontalScrollIndicator = NO;
        
        self.rPNavBar = rPNavBar;
        [self addSubview:rPNavBar];
        //导航线
        UIView *rPNavLine = [[UIView alloc]init];
        self.rPNavLine = rPNavLine;
        rPNavLine.backgroundColor = MainLineGrayColor;
        [self.rPNavBar addSubview:rPNavLine];
        //滑块
        UIView *sliderBar = [[UIView alloc]init];
        self.sliderBar = sliderBar;
        sliderBar.backgroundColor = MainGoldenColor;
        [self.rPNavBar addSubview:sliderBar];
    }
    
    return self;
}


- (void)setNavTittles:(NSArray *)navTittles {
    _navTittles = navTittles;
    [self createCTNavBtn];
}

- (void)createCTNavBtn {
    for (int i = 1; i <= self.navTittles.count; i++) {
        //创建按钮
        CarNavButton *navBtn = [[CarNavButton alloc]init];
        [navBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [navBtn setTitleColor:MainGoldenColor forState:UIControlStateSelected];
        navBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        NSDictionary *dict = self.navTittles[i-1];
        navBtn.contentDict = dict;
        navBtn.tag = [dict[@"sort"] integerValue];
        [navBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
        
        [navBtn addTarget:self action:@selector(navBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.navBtns addObject:navBtn];
        [self.rPNavBar addSubview:navBtn];
        

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
    
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderBar.transform = CGAffineTransformMakeTranslation((navBtn.tag - 1) * NavBtnWidth, 0);
    }];
    
    //通知代理刷新列表
    if ([self.delegate respondsToSelector:@selector(rPNavBtnClick:NavBtn:)]) {
        [self.delegate rPNavBtnClick:self NavBtn:navBtn];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
   
    //设置车型子视图的frame
    self.rPNavBar.frame = CGRectMake(0, 0, ScreenWidth,RPNavBarViewHeight);
    self.rPNavBar.contentSize = CGSizeMake(self.navBtns.count * NavBtnWidth, RPNavBarViewHeight);
    
    
    
    self.rPNavLine.frame = CGRectMake(0, self.rPNavBar.height - SliderHeight, self.navBtns.count * NavBtnWidth, SliderHeight);
    self.sliderBar.frame = CGRectMake(0, self.rPNavBar.height - SliderHeight, NavBtnWidth, SliderHeight);
    
    
    for (CarNavButton *btn in self.navBtns) {
        btn.frame = CGRectMake((btn.tag - 1) * NavBtnWidth, 0, NavBtnWidth, RPNavBarViewHeight - 4);
        
    }
}

- (void)contentViewDidScroll:(UIScrollView *)scrollView {
    
    //控制滑块的移动
    self.sliderBar.transform = CGAffineTransformMakeTranslation(scrollView.contentOffset.x / (NavBtnNum + 0.5), 0);
    
    CGFloat sliderX;
    CGFloat contentSizeW = self.rPNavBar.contentSize.width;
    CGFloat contentOffSetX = self.rPNavBar.contentOffset.x;
    CGFloat frameW = ScreenWidth;
    if (self.sliderBar.x >= contentOffSetX + ScreenWidth) {
        
        if (frameW * 0.5 >= contentSizeW - contentOffSetX - frameW) {
            sliderX = contentSizeW - contentOffSetX - frameW;
        } else {
            sliderX = frameW * 0.5;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.rPNavBar.contentOffset = CGPointMake(contentOffSetX + sliderX, 0);
        }];
        
    }
    if (self.sliderBar.x <= contentOffSetX) {
        
        if (frameW * 0.5 > contentOffSetX) {
            sliderX = contentOffSetX;
        } else {
            sliderX = frameW * 0.5;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.rPNavBar.contentOffset = CGPointMake(contentOffSetX - sliderX, 0);
        }];
        
    }
    
    
    NSInteger pageNum = scrollView.contentOffset.x / ScreenWidth;
    
    for (CarNavButton *navBtn in self.navBtns) {
        if ((pageNum + 1) == navBtn.tag) {
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
