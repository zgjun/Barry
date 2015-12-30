//
//  NewCarGuideController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-17.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "NewCarGuideController.h"
#import "GuideContentController.h"
#import "NCGNavBarView.h"
#import "CarNavButton.h"
#import "MainTabBarController.h"


#define RPNavBarViewHeight 44

#define NavHeight 64

#define ContentScrollHeight (ScreenHeight - NavHeight - RPNavBarViewHeight)

@interface NewCarGuideController ()<NCGNavBarViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,weak) NCGNavBarView *nCGBarView;


@property (nonatomic,weak) UIScrollView *contentScrollView;

@property (nonatomic,strong) NSArray *navHeads;

@property (nonatomic,weak) UIButton *cityBtn;

@property (nonatomic,strong) NSMutableArray *guideVcs;

@property (nonatomic,strong) GuideContentController *currentVc;

@property (nonatomic,strong) NSString *cityStr;

@property (nonatomic,assign) NSInteger type;
@end

@implementation NewCarGuideController

- (NSMutableArray *)guideVcs {
    if (_guideVcs == nil) {
        _guideVcs = [NSMutableArray array];
    }
    return _guideVcs;
}

- (NSArray *)navHeads {
    if (_navHeads == nil) {
        _navHeads = @[@{@"type":@2,@"name":@"多车导购"},
                      @{@"type":@1,@"name":@"单车导购"},
                      @{@"type":@3,@"name":@"终极PK"},
                      ];
    }
    return _navHeads;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.navigationController.viewControllers.count == 1){
        
        //关闭主界面的右滑返回
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}



- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    
    return YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.view.backgroundColor = [UIColor redColor];
    
    //导航视图
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navView];
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"chexun_backarrow_black"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    //标题视图
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.text = @"新车导购";
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    //创建头视图
    NCGNavBarView *nCGBarView = [[NCGNavBarView alloc]init];
    
    nCGBarView.delegate = self;
    
    nCGBarView.navTittles = self.navHeads;
    
    
    self.nCGBarView = nCGBarView;
    self.nCGBarView.frame = CGRectMake(0, CGRectGetMaxY(navView.frame), ScreenWidth,RPNavBarViewHeight);
    [self.view addSubview:nCGBarView];
    
    //创建内容视图
    UIScrollView *contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(nCGBarView.frame), ScreenWidth, ContentScrollHeight)];
    contentScrollView.backgroundColor = [UIColor blueColor];
    self.contentScrollView = contentScrollView;
    
    contentScrollView.contentSize = CGSizeMake(self.navHeads.count * ScreenWidth, 0);
    contentScrollView.bounces = NO;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.pagingEnabled = YES;
    contentScrollView.delegate = self;
    for (int i = 0; i < self.navHeads.count; i++) {
        GuideContentController *guideVc = [[GuideContentController alloc]init];
        guideVc.navTittles = self.navHeads;
        guideVc.tableView.tag = i + 1;
        guideVc.tableView.frame = CGRectMake(i * ScreenWidth, 0, ScreenWidth, ContentScrollHeight);
        [contentScrollView addSubview:guideVc.tableView];
        [self addChildViewController:guideVc];
        
        //添加到数组
        [self.guideVcs addObject:guideVc];
    }
    
    [self.view addSubview:contentScrollView];
    
    GuideContentController *guideVc = self.guideVcs[0];
    
    self.currentVc = guideVc;
    
    self.type = 2;
    [self.currentVc loadDataWithType:self.type];
    
}



- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;
    
}

#pragma mark - RPNavBarView代理方法

- (void)nCGNavBtnClick:(NCGNavBarView *)nCGNavBarView NavBtn:(CarNavButton *)carNavBtn {
    
    //点击按钮切换内容视图
    [UIView animateWithDuration:0.5 animations:^{
        self.contentScrollView.contentOffset = CGPointMake((carNavBtn.tag - 1) * ScreenWidth, 0);
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.nCGBarView contentViewDidScroll:scrollView];
    
    CGFloat contentX = scrollView.contentOffset.x;
    if (contentX == 0 * ScreenWidth) {
        GuideContentController *guideVc = self.guideVcs[0];
        self.currentVc = guideVc;
        self.type = 2;
        [guideVc loadDataWithType:self.type];
    } else if (contentX == 1 * ScreenWidth) {
        GuideContentController *guideVc = self.guideVcs[1];
        self.currentVc = guideVc;
        self.type = 1;
        [guideVc loadDataWithType:self.type];
    } else if (contentX == 2 * ScreenWidth) {
        GuideContentController *guideVc = self.guideVcs[2];
        self.currentVc = guideVc;
        self.type = 3;
        [guideVc loadDataWithType:self.type];
    }
    
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
