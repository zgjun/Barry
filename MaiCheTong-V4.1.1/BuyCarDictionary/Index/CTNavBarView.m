//
//  CTNavBarView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-3.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "CTNavBarView.h"
#import "CarNavButton.h"


#define CTNavBarViewHeight 44
#define CTSpliteLineHeight 10
#define carTypeViewHeight self.view.bounds.size.height
#define NavBtnNum 4
#define NavBtnWidth (ScreenWidth / (NavBtnNum + 0.5))
#define SliderHeight 2

#define CarTypeCellWidth 140
#define CarTypeCellHeight 140

//static NSInteger remberTag = 0;
//static CGFloat rembersliderX = 0;

@interface CTNavBarView()
/**车型导航条*/
@property (nonatomic,weak) UIScrollView *cTNavBar;
/**车型导航线*/
@property (nonatomic,weak) UIView *cTNavLine;
/**导航线上的滑块*/
@property (nonatomic,weak) UIView *sliderBar;

@property (nonatomic,strong) NSMutableArray *navBtns;

@property (weak,nonatomic) UIButton *currentBtn;

@property (nonatomic,weak)  UIView *spliteLine;

@property (nonatomic,assign) NSInteger remberTag;

@property (nonatomic,assign) CGFloat rembersliderX;
@end

@implementation CTNavBarView

- (NSMutableArray *)navBtns {
    if (_navBtns == nil) {
        _navBtns = [NSMutableArray array];
    }
    return _navBtns;
}


- (instancetype)initWithRemberTag:(NSInteger)remberTag RemberSliderX:(CGFloat)remberSliderX {
    if (self = [super init]) {
        self.remberTag = remberTag;
        self.rembersliderX = remberSliderX;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = MainWhiteColor;
        
        //导航条
        UIScrollView *cTNavBar = [[UIScrollView alloc]init];
        cTNavBar.bounces = NO;
        cTNavBar.showsHorizontalScrollIndicator = NO;
        self.cTNavBar = cTNavBar;
        [self addSubview:cTNavBar];
        //导航线
        UIView *cTNavLine = [[UIView alloc]init];
        self.cTNavLine = cTNavLine;
        cTNavLine.backgroundColor = MainLineGrayColor;
        [self.cTNavBar addSubview:cTNavLine];
        //滑块
        UIView *sliderBar = [[UIView alloc]init];
        self.sliderBar = sliderBar;
        sliderBar.backgroundColor = MainGoldenColor;
        [self.cTNavBar addSubview:sliderBar];
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
        [self.cTNavBar addSubview:navBtn];
        
        if (self.remberTag == 0) {
            self.remberTag = 1;
        }
        
        if (navBtn.tag == self.remberTag) {
            self.currentBtn.selected = NO;
            navBtn.selected = YES;
            self.currentBtn = navBtn;
            navBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//            [self navBtnClick:navBtn];
            
        }
        
    }
    
    
    //设置车型子视图的frame
    self.cTNavBar.frame = CGRectMake(0, 0, ScreenWidth, CTNavBarViewHeight);
    
    
    self.cTNavBar.contentSize = CGSizeMake(self.navBtns.count * NavBtnWidth, 0);
    
    self.cTNavLine.frame = CGRectMake(0, self.cTNavBar.height - SliderHeight, self.navBtns.count * NavBtnWidth, SliderHeight);
    self.sliderBar.frame = CGRectMake((self.remberTag - 1) * NavBtnWidth, self.cTNavBar.height - SliderHeight, NavBtnWidth, SliderHeight);
    
    
    for (CarNavButton *btn in self.navBtns) {
        btn.frame = CGRectMake((btn.tag - 1) * NavBtnWidth, 0, NavBtnWidth, CTNavBarViewHeight - 4);
    }
    
    self.cTNavBar.contentOffset = CGPointMake(self.rembersliderX, 0);
}

/**导航按钮点击事件*/
- (void)navBtnClick:(CarNavButton *)navBtn {
    
    if (navBtn == self.currentBtn) return;
    
    self.remberTag = navBtn.tag;
    
    self.rembersliderX = self.cTNavBar.contentOffset.x;
    
//    self.currentBtn.selected = NO;
//    navBtn.selected = YES;
    self.currentBtn = navBtn;

    //通知代理刷新列表
    if ([self.delegate respondsToSelector:@selector(cTNavBtnClick:NavBtn:RemberSliderX:)]) {
        [self.delegate cTNavBtnClick:self NavBtn:navBtn RemberSliderX:self.rembersliderX];
    }
    
}

- (void)contentViewDidScroll:(UIScrollView *)scrollView {
    
    //控制滑块的移动
    self.sliderBar.transform = CGAffineTransformMakeTranslation((scrollView.contentOffset.x / ScreenWidth) * NavBtnWidth, 0);
    CGFloat sliderX;
    CGFloat contentSizeW = self.cTNavBar.contentSize.width;
    CGFloat contentOffSetX = self.cTNavBar.contentOffset.x;
    CGFloat frameW = ScreenWidth;
    if (self.sliderBar.x >= contentOffSetX + ScreenWidth) {
        
        if (frameW * 0.5 >= contentSizeW - contentOffSetX - frameW) {
            sliderX = contentSizeW - contentOffSetX - frameW;
        } else {
            sliderX = frameW * 0.5;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.cTNavBar.contentOffset = CGPointMake(contentOffSetX + sliderX, 0);
        }];
        
    }
    if (self.sliderBar.x <= contentOffSetX) {
        
        if (frameW * 0.5 > contentOffSetX) {
            sliderX = contentOffSetX;
        } else {
            sliderX = frameW * 0.5;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.cTNavBar.contentOffset = CGPointMake(contentOffSetX - sliderX, 0);
        }];
        
    }
    
    NSInteger pageNum = scrollView.contentOffset.x / ScreenWidth;
    
    for (CarNavButton *navBtn in self.navBtns) {
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
