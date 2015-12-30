//
//  CSImageShowController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSImageShowController.h"
#import "CSImageBarView.h"
#import "CarNavButton.h"
#import "CityChooseController.h"
#import "CSImageContentController.h"
#import "AFNetworking.h"


#define NavBtnNum 4
#define NavBtnWidth (ScreenWidth / (NavBtnNum + 0.5))

#define RPNavBarViewHeight 44

#define NavHeight 64

#define ContentScrollHeight (ScreenHeight - NavHeight - RPNavBarViewHeight)

@interface CSImageShowController ()<CSImageBarViewDelegate,UIScrollViewDelegate,CityChooseControllerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,weak) CSImageBarView *cSImageBarView;

@property (nonatomic,weak) UIScrollView *contentScrollView;

@property (nonatomic,strong) NSArray *navHeads;

@property (nonatomic,weak) UIButton *cityBtn;

@property (nonatomic,strong) NSMutableArray *cSImageVcs;

@property (nonatomic,strong) NSString *carTitle;


@property (nonatomic,strong) NSString *seriesId;

@property (nonatomic,strong) CityChooseController *cityVc;

@end

@implementation CSImageShowController

- (instancetype)initWithTitle:(NSString *)carTitle seriesId:(NSString *)seriesId {
    if (self = [super init]) {
        self.carTitle = carTitle;
        self.seriesId = seriesId;
    }
    return self;
}

- (NSMutableArray *)cSImageVcs {
    if (_cSImageVcs == nil) {
        _cSImageVcs = [NSMutableArray array];
    }
    return _cSImageVcs;
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
    
    self.navigationItem.title = self.carTitle;
    
    
    //禁用autolayout
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
    
    titleLabel.text = @"图片";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //创建头视图
    
    CSImageBarView *cSImageBarView = [[CSImageBarView alloc]init];
    
    cSImageBarView.delegate = self;
    
    cSImageBarView.navTittles = self.navHeads;
    
    
    self.cSImageBarView = cSImageBarView;
    self.cSImageBarView.frame = CGRectMake(0, NavHeight, ScreenWidth,RPNavBarViewHeight);
    [self.view addSubview:cSImageBarView];
    
    //创建内容视图
    UIScrollView *contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NavHeight + RPNavBarViewHeight, ScreenWidth, ContentScrollHeight)];
    self.contentScrollView = contentScrollView;
    
    contentScrollView.contentSize = CGSizeMake(self.navHeads.count * ScreenWidth, 0);
    contentScrollView.bounces = NO;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.pagingEnabled = YES;
    contentScrollView.delegate = self;
    for (int i = 0; i < self.navHeads.count; i++) {
        CSImageContentController *cSImageVc = [[CSImageContentController alloc]init];
        cSImageVc.navTittles = self.navHeads;
        cSImageVc.seriesId = self.seriesId;
        cSImageVc.tableView.tag = i;
        cSImageVc.tableView.frame = CGRectMake(i * ScreenWidth, 0, ScreenWidth, ContentScrollHeight);
        [contentScrollView addSubview:cSImageVc.tableView];
        [self addChildViewController:cSImageVc];
        
        //添加到数组
        [self.cSImageVcs addObject:cSImageVc];
    }
    
    
    
    [self.view addSubview:contentScrollView];
    
    
    CSImageContentController *cSImageVc = self.cSImageVcs[0];
    [cSImageVc loadDataWithType:@"out"];
    
    
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cityBtnClick:(UIButton *)btn {
    CityChooseController *cityVc = [[CityChooseController alloc]init];
    self.cityVc = cityVc;
    cityVc.cityDelegate = self;
    
    [self.navigationController pushViewController:cityVc animated:YES];
}
//城市控制器的代理方法
- (void)didCityTableRowClick:(CityChooseController *)cityVc infoDict:(NSDictionary *)infoDict {
    
    [self.cityBtn setTitle:infoDict[@"cityName"] forState:UIControlStateNormal];
}


- (NSArray *)navHeads {
    if (_navHeads == nil) {
        _navHeads = @[@"外观",@"内饰",@"细节",@"图解",@"官方图",@"车展"];
    }
    return _navHeads;
}
#pragma mark - UIScrollView代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.cSImageBarView contentViewDidScroll:scrollView];
    
    CGFloat contentX = scrollView.contentOffset.x;
    if (contentX == 0 * ScreenWidth) {
        CSImageContentController *cSImageVc = self.cSImageVcs[0];
        
        
        [cSImageVc loadDataWithType:@"out"];
        
    } else if (contentX == 1 * ScreenWidth) {
        CSImageContentController *cSImageVc = self.cSImageVcs[1];
        [cSImageVc loadDataWithType:@"in"];
    } else if (contentX == 2 * ScreenWidth) {
        CSImageContentController *cSImageVc = self.cSImageVcs[2];
        [cSImageVc loadDataWithType:@"detail"];
    } else if (contentX == 3 * ScreenWidth) {
        CSImageContentController *cSImageVc = self.cSImageVcs[3];
        [cSImageVc loadDataWithType:@"disa"];
    } else if (contentX == 4 * ScreenWidth) {
        CSImageContentController *cSImageVc = self.cSImageVcs[4];
        [cSImageVc loadDataWithType:@"office"];
    } else if (contentX == 5 * ScreenWidth) {
        CSImageContentController *cSImageVc = self.cSImageVcs[5];
        [cSImageVc loadDataWithType:@"show"];
    } else if (contentX == 6 * ScreenWidth) {
        CSImageContentController *cSImageVc = self.cSImageVcs[6];
        [cSImageVc loadDataWithType:@"user"];
    }
    
}

#pragma mark - RPNavBarView代理方法

- (void)cSImageBtnClick:(CSImageBarView *)cSImageBarView NavBtn:(CarNavButton *)carNavBtn {
    
    //点击按钮切换内容视图
    [UIView animateWithDuration:0.5 animations:^{
        self.contentScrollView.contentOffset = CGPointMake(carNavBtn.tag * ScreenWidth, 0);
    }];
    
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
