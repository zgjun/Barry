//
//  IndexController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "IndexController.h"
#import "NoHighLightBtn.h"
#import "ScreeningButton.h"
#import "ScreeningController.h"
#import "IndexHistoryController.h"
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "IndexNavBarView.h"
#import "CarNavButton.h"
#import "UIImage+Extension.h"
#import "IndexContentController.h"
#import "MainTabBarController.h"

#import "NonHighButton.h"
#import "CTSearchController.h"
#import "RPriceController.h"
#import "CTCompareController.h"
#import "NewCarGuideController.h"
#import "MobClick.h"


#define NavViewHeight 64

#define ScreeningBtnSide 44

#define GapHeight 10

#define TabBarHeight 49

#define CTNavBarViewHeight 44

#define CarTypeViewHeight (ScreenHeight - CTNavBarViewHeight - StatusHeight)

//以下是4.1.1
#define MenuWidth 145

#define bookDriveBtnHeight 176

@interface IndexController ()<UIScrollViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate,IndexContentControllerDelegate,IndexNavBarViewDelegate>

/**状态栏*/
@property (nonatomic,weak) UIView *navView;

/**导航栏上左边的label*/
@property (nonatomic,weak) UILabel *appNameLabel;

/**导航栏上右边的城市按钮*/
@property (nonatomic,weak)  NoHighLightBtn *cityBtn;

@property (nonatomic,weak) UIButton *historyBtn;

@property (nonatomic,weak) UITableView *indexTableView;

/**筛选按钮*/
@property (nonatomic,weak)  ScreeningButton *screeningBtn;


@property (nonatomic,strong) NSDictionary *navBarInfoDict;

@property (nonatomic,strong) NSArray *historyCars;

@property (nonatomic,strong) CLLocationManager *manager;

@property (nonatomic,strong) CLGeocoder *geocoder;

@property (nonatomic,strong) __block NSArray *citys;

@property (nonatomic,strong) __block NSString *cityStr;

//经度
@property (nonatomic,strong) __block NSString *longitude;
//纬度
@property (nonatomic,strong) __block NSString *latitude;

@property (nonatomic,assign) CGFloat upDistance;

@property (nonatomic,weak) UIImageView *navImageView;

@property (nonatomic,weak) UIImageView *statusImageView;

@property (nonatomic,strong) NSArray *navHeads;

@property (nonatomic,assign) NSInteger remberTag;

@property (nonatomic,assign) CGFloat rembersliderX;

@property (nonatomic,assign) NSInteger pageNo;

@property (nonatomic,assign) NSInteger pageSize;

@property (nonatomic,assign) NSInteger carLevel;

@property (nonatomic,weak) UIView *headView;

@property (nonatomic,weak) IndexNavBarView *indexNavBarView;

@property (nonatomic,weak) UIScrollView *contentScrollView;

@property (nonatomic,strong) NSMutableArray *indexContentVcs;

@property (nonatomic,weak) UIView *contentView;

@property (nonatomic,weak) UIView *menuView;

@property (nonatomic,weak) UIImageView *menuImageView;

@property (nonatomic,weak) UIView *menuBgView;

@property (nonatomic,weak) UIButton *menuBtn;

@property (nonatomic,strong) IndexContentController *currentVc;

@property (nonatomic,strong) RPriceController *reduceVc;

@property (nonatomic,strong) CTSearchController *searchVc;

@property (nonatomic,strong) CTCompareController *compareVc;

@property (nonatomic,strong) ScreeningController *screeningVc;

@property (nonatomic,strong) IndexHistoryController *historyVc;

@property (nonatomic,strong) NewCarGuideController *carGuideVc;

@end

@implementation IndexController

- (NSMutableArray *)indexContentVcs {
    if (_indexContentVcs == nil) {
        _indexContentVcs = [NSMutableArray array];
    }
    return _indexContentVcs;
}

- (NSArray *)navHeads {
    if (_navHeads == nil) {
        _navHeads = @[@{@"levelId":@0,@"name":@"值得买",@"sort":@0},//单独的模块
                      @{@"levelId":@2,@"name":@"紧凑型车",@"sort":@1},
                      @{@"levelId":@7,@"name":@"SUV",@"sort":@2},
                      @{@"levelId":@3,@"name":@"中型车",@"sort":@3},
                      @{@"levelId":@1,@"name":@"小型车",@"sort":@4},
                      @{@"levelId":@9,@"name":@"微型车",@"sort":@5},
                      @{@"levelId":@5,@"name":@"豪华车",@"sort":@6},
                      @{@"levelId":@4,@"name":@"中大型车",@"sort":@7},
                      @{@"levelId":@8,@"name":@"跑车",@"sort":@8},
                      @{@"levelId":@6,@"name":@"MPV",@"sort":@9}
                      ];
    }
    return _navHeads;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = NO;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



- (NSString *)cityStr {
    _cityStr = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    
    if (_cityStr == nil) {
        _cityStr = [NSString stringWithFormat:@"北京"];
    }
    return _cityStr;
}

- (NSArray *)citys {
    if (_citys == nil) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *urlStr = @"http://dealer.chexun.com/api/GetCityInfo.ashx";
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            _citys = responseObject;
            
                for (int i = 0; i < _citys.count; i++) {
                    NSDictionary *city = _citys[i];
                    
                    if ([self.cityStr rangeOfString:city[@"cityName"]].length > 0) {
                        
                        [[NSUserDefaults standardUserDefaults] setObject:city[@"cityId"] forKey:kDefaultCityIDKey];
                        [[NSUserDefaults standardUserDefaults] setObject:city[@"cityName"] forKey:kDefaultCityNameKey];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:city[@"cityId"] forKey:kGPRSCityIDKey];
                        [[NSUserDefaults standardUserDefaults] setObject:city[@"cityName"] forKey:kGPRSCityNameKey];
                        
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    } else {
                        //将相关的城市数据同步到偏好设置里面
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.cityBtn setTitle:@"北京" forState:UIControlStateNormal];
                        });
                        
                        //北京城市ID：1
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:kDefaultCityIDKey];
                        [[NSUserDefaults standardUserDefaults] setObject:@"北京" forKey:kDefaultCityNameKey];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:kGPRSCityIDKey];
                        [[NSUserDefaults standardUserDefaults] setObject:@"北京" forKey:kGPRSCityNameKey];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            MyLog(@"%@",error);
        }];
    }
    return _citys;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}
- (NSArray *)historyCars {
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"seriesHistory.plist"];
    //先读取之前的历史记录
    _historyCars = [[NSArray alloc]initWithContentsOfFile:fileName];
    return _historyCars;
}


- (void)loadView {
    self.view = [[UIView alloc]init];
    self.view.backgroundColor = [UIColor redColor];
    
}

- (void)contentPanRight:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    CGPoint translation = [panGestureRecognizer translationInView:self.contentView];
//    
//    if (translation.x > 0 && self.contentView.x >= MenuWidth) {
//        return;
//    }
    
    if (self.contentView.frame.origin.x <= 0 && translation.x > 0) {
        self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
        
        tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
        
        [panGestureRecognizer setTranslation:CGPointZero inView: self.contentView];
    } else if (self.contentView.frame.origin.x > 0 && self.contentView.frame.origin.x < MenuWidth) {
        self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
        
        tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
        
        [panGestureRecognizer setTranslation:CGPointZero inView: self.contentView];
    } else if (self.contentView.frame.origin.x == MenuWidth && translation.x < 0){
        self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
        
        tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
        
        [panGestureRecognizer setTranslation:CGPointZero inView: self.contentView];
    } else if (self.contentView.frame.origin.x >= MenuWidth && self.contentView.frame.origin.x <= MenuWidth + 5 && translation.x < 0) {
        self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
        
        tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
        
        [panGestureRecognizer setTranslation:CGPointZero inView: self.contentView];
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ) {
        if (self.contentView.frame.origin.x >= MenuWidth * 0.5) {
            
            [UIView animateWithDuration:0.2 animations:^{
                self.contentView.frame =CGRectMake(MenuWidth, 0, ScreenWidth, ScreenHeight);
                tab.tabBarView.frame = CGRectMake(MenuWidth, ScreenHeight - tab.tabBarView.bounds.size.height, tab.tabBarView.bounds.size.width, tab.tabBarView.bounds.size.height);
            }];
            self.menuBtn.selected = YES;
            //统计显示广告
            [MobClick event:@"iOS_AD_Show_Count"];
            
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                self.contentView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                tab.tabBarView.frame = CGRectMake(0, ScreenHeight - tab.tabBarView.bounds.size.height, tab.tabBarView.bounds.size.width, tab.tabBarView.bounds.size.height);
            }];
            self.contentScrollView.scrollEnabled = YES;
            self.menuBtn.selected = NO;
        }
    }
    
}
- (void)scrollPanRight:(UIPanGestureRecognizer *)panGestureRecognizer {
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    CGPoint translation = [panGestureRecognizer translationInView:self.contentView];
    
//    if (translation.x > 0 && self.contentView.x >= MenuWidth) {
//        return;
//    }
    
    if (self.contentScrollView.contentOffset.x == 0) {
        
        
        if (self.contentView.frame.origin.x <= 0 && translation.x > 50) {
            self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
            
            tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
            
            [panGestureRecognizer setTranslation:CGPointZero inView: self.contentView];
        } else if (self.contentView.frame.origin.x > 0 && self.contentView.frame.origin.x < MenuWidth) {
            self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
            
            tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
            
            [panGestureRecognizer setTranslation:CGPointZero inView: self.contentView];
        }else if (self.contentView.frame.origin.x == MenuWidth && translation.x < 0) {
            self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
            
            tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
            
            [panGestureRecognizer setTranslation:CGPointZero inView: self.contentView];
        }else if (self.contentView.frame.origin.x >= MenuWidth && self.contentView.frame.origin.x <= MenuWidth + 5 && translation.x < 0) {
            self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
            
            tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
            
            [panGestureRecognizer setTranslation:CGPointZero inView: self.contentView];
        }
        
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ) {
            if (self.contentView.frame.origin.x >= MenuWidth * 0.5) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.contentView.frame =CGRectMake(MenuWidth, 0, ScreenWidth, ScreenHeight);
                    tab.tabBarView.frame = CGRectMake(MenuWidth, ScreenHeight - tab.tabBarView.bounds.size.height, tab.tabBarView.bounds.size.width, tab.tabBarView.bounds.size.height);
                }];
                [self.view bringSubviewToFront:self.menuView];
                self.menuBtn.selected = YES;
                
                //统计显示广告
                [MobClick event:@"iOS_AD_Show_Count"];
                
            } else {
                [UIView animateWithDuration:0.2 animations:^{
                    self.contentView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                    tab.tabBarView.frame = CGRectMake(0, ScreenHeight - tab.tabBarView.bounds.size.height, tab.tabBarView.bounds.size.width, tab.tabBarView.bounds.size.height);
                }];
                self.contentScrollView.scrollEnabled = YES;
                self.menuBtn.selected = NO;
            }
        }
    }
}

- (void)menuBgViewPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    CGPoint translation = [panGestureRecognizer translationInView:self.menuBgView];
    if (translation.x > 0 && self.contentView.x >= MenuWidth) {
        return;
    }
    
    
    if (translation.x > (-1 * tab.tabBarView.bounds.size.width) && self.contentView.x <= 145 && self.contentView.x >= 0) {
        self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, translation.x, 0);
        self.menuView.transform = CGAffineTransformTranslate(self.menuView.transform, translation.x, 0);
        
        tab.tabBarView.transform = CGAffineTransformTranslate(tab.tabBarView.transform, translation.x, 0);
        
        
         [panGestureRecognizer setTranslation:CGPointZero inView: self.menuBgView];
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ) {
        
        if ((self.contentView.frame.origin.x + translation.x)  >= MenuWidth * 0.5) {
            
            [UIView animateWithDuration:0.2 animations:^{
                
                self.contentView.frame =CGRectMake(MenuWidth, 0, ScreenWidth, ScreenHeight);
                self.menuView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                
                tab.tabBarView.frame = CGRectMake(MenuWidth, ScreenHeight - tab.tabBarView.bounds.size.height, tab.tabBarView.bounds.size.width, tab.tabBarView.bounds.size.height);
            }];
            
            self.menuBtn.selected = YES;
            [self.view bringSubviewToFront:self.menuView];
            
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                
                self.contentView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                
                tab.tabBarView.frame = CGRectMake(0, ScreenHeight - tab.tabBarView.bounds.size.height, tab.tabBarView.bounds.size.width, tab.tabBarView.bounds.size.height);
                
            } completion:^(BOOL finished) {
                self.menuView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            }];
            
            self.contentScrollView.scrollEnabled = YES;
            
            self.menuBtn.selected = NO;
            [self.view bringSubviewToFront:self.contentView];
        }
        
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CLLocationManager *manager = [[CLLocationManager alloc]init];
    self.manager = manager;
    //在ios 8.0下要授权
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        [manager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
        
    }
    if ([CLLocationManager locationServicesEnabled]) {
        
        manager.delegate = self;
        [manager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [manager startUpdatingLocation];


    } else {
        MyLog(@"定位不可用");
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    //添加一个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToCompareVc) name:@"GoToCompareVc" object:nil];
    
    
    //4.1.1添加
    self.view.backgroundColor = [UIColor clearColor];
    
    //添加菜单视图
    UIView *menuView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//    menuView.backgroundColor = [UIColor redColor];
    self.menuView = menuView;
    [self.view addSubview:menuView];
    //添加菜单按钮
    UIImageView *menuImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, MenuWidth, ScreenHeight)];
    menuImageView.userInteractionEnabled = YES;
    self.menuImageView = menuImageView;
    menuImageView.image = [UIImage imageNamed:@"imgaebg_2"];
    [self.menuView addSubview:menuImageView];
    //搜索车系
    NonHighButton *searchSeriesBtn = [[NonHighButton alloc]initWithFrame:CGRectMake(0, 0, MenuWidth, (ScreenHeight - 3 * 50) / 4)];
    [searchSeriesBtn setImage:[UIImage imageNamed:@"chexun_seachicon"] forState:UIControlStateNormal];
    [searchSeriesBtn setTitle:@"搜索车系" forState:UIControlStateNormal];
    [searchSeriesBtn addTarget:self action:@selector(searchSeriesBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.menuImageView addSubview:searchSeriesBtn];
    //降价行情
    NonHighButton *reducePriceBtn = [[NonHighButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(searchSeriesBtn.frame), MenuWidth, (ScreenHeight - bookDriveBtnHeight) / 4)];
    [reducePriceBtn setImage:[UIImage imageNamed:@"chexun_saleicon"] forState:UIControlStateNormal];
    [reducePriceBtn setTitle:@"降价行情" forState:UIControlStateNormal];
    [reducePriceBtn addTarget:self action:@selector(reducePriceBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.menuImageView addSubview:reducePriceBtn];
    //新车导购
    NonHighButton *buyNewCarBtn = [[NonHighButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(reducePriceBtn.frame), MenuWidth, (ScreenHeight - bookDriveBtnHeight) / 4)];
    [buyNewCarBtn setImage:[UIImage imageNamed:@"chexun_newicon"] forState:UIControlStateNormal];
    [buyNewCarBtn setTitle:@"新车导购" forState:UIControlStateNormal];
    [buyNewCarBtn addTarget:self action:@selector(buyNewCarBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.menuImageView addSubview:buyNewCarBtn];
    //车型对比
    NonHighButton *carCompareBtn = [[NonHighButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(buyNewCarBtn.frame), MenuWidth, (ScreenHeight - bookDriveBtnHeight) / 4)];
    [carCompareBtn setImage:[UIImage imageNamed:@"chexun_pkicon"] forState:UIControlStateNormal];
    [carCompareBtn setTitle:@"车型对比" forState:UIControlStateNormal];
    [carCompareBtn addTarget:self action:@selector(carCompareBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.menuImageView addSubview:carCompareBtn];
    
    //预约试驾广告
    NonHighButton *bookDriveBtn = [[NonHighButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(carCompareBtn.frame), MenuWidth, bookDriveBtnHeight)];
    [bookDriveBtn setBackgroundImage:[UIImage imageNamed:@"chexu_ad"] forState:UIControlStateNormal];
    [bookDriveBtn addTarget:self action:@selector(bookDriveBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.menuImageView addSubview:bookDriveBtn];
    
    
    //添加菜单背景
    UIView *menuBgView = [[UIView alloc]initWithFrame:CGRectMake(MenuWidth, 0, ScreenWidth - MenuWidth, ScreenHeight)];
    menuBgView.backgroundColor = [UIColor clearColor];
    self.menuBgView = menuBgView;
    [self.menuView addSubview:menuBgView];
    //添加点击的手势
    UITapGestureRecognizer *menuBgViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(menuBgViewTap)];
    menuBgViewTap.delegate = self;
    [menuBgView addGestureRecognizer:menuBgViewTap];
    
    UIPanGestureRecognizer *menuBgViewPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(menuBgViewPan:)];
    menuBgViewPan.delegate = self;
    [menuBgView addGestureRecognizer:menuBgViewPan];
    
    //添加内容视图
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.contentView = contentView;
    [self.view addSubview:contentView];
    //添加向右的手势
    //滑动向左
    UIPanGestureRecognizer *recognizerRight = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(contentPanRight:)];
    
    [self.contentView addGestureRecognizer:recognizerRight];

    
    UIImageView *statusImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    self.statusImageView = statusImageView;
    statusImageView.alpha = 1.0;
    statusImageView.image = [UIImage imageNamed:@"imgaebg_1_1"];
    [self.contentView addSubview:statusImageView];
    
    //添加头视图
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(statusImageView.frame), ScreenWidth, 105 + 44)];
    self.headView = headView;
//    [self.view insertSubview:headView belowSubview:statusImageView];
    [self.contentView addSubview:headView];
    
    
    
    //添加导航视图
    UIImageView *navImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 105 + 44)];
    self.navImageView = navImageView;
    navImageView.userInteractionEnabled = YES;
    navImageView.image = [UIImage imageNamed:@"imgaebg_1_2"];
    [headView addSubview:navImageView];
    
    //添加菜单按钮
    UIButton *menuBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 30, 44, 44)];
    self.menuBtn = menuBtn;
    [menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"chexun_menuicon_white"] forState:UIControlStateNormal];
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"chexun_closeicon_white"] forState:UIControlStateSelected];
    [navImageView addSubview:menuBtn];
    //添加标题label
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 30, 80, 44)];
    titleLabel.textColor = MainWhiteColor;
    titleLabel.font = [UIFont systemFontOfSize:22];
    titleLabel.text = @"买车通";
    [navImageView addSubview:titleLabel];
    //添加历史记录按钮
    UIButton *historyBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 44 - 20, 30, 44, 44)];
    self.historyBtn = historyBtn;
    [historyBtn addTarget:self action:@selector(historyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    if (self.historyCars.count == 0) {
        historyBtn.enabled = NO;
    } else {
        historyBtn.enabled = YES;
    }
    
    [historyBtn setBackgroundImage:[UIImage imageNamed:@"chexun_historyicon_white"] forState:UIControlStateNormal];
    [navImageView addSubview:historyBtn];
    
    
    //添加tabbar
    IndexNavBarView *indexNavBarView = [[IndexNavBarView alloc]initWithRemberTag:self.remberTag RemberSliderX:self.rembersliderX];
    indexNavBarView.frame = CGRectMake(0, CGRectGetMaxY(headView.frame) - 44 - 20, ScreenWidth, 44);
    self.indexNavBarView = indexNavBarView;
    indexNavBarView.delegate = self;
    indexNavBarView.navTittles = self.navHeads;
    [headView addSubview:indexNavBarView];
    
    //添加更多按钮
    UIButton *moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 44, 0, 44, 44)];
    [moreBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_tabbarbg"] forState:UIControlStateNormal];
    moreBtn.backgroundColor = [UIColor clearColor];
    [moreBtn setImage:[UIImage imageNamed:@"chexun_more"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [indexNavBarView addSubview:moreBtn];
    
    
    //创建内容视图
    UIScrollView *contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame), ScreenWidth, ScreenHeight - 20 - 44)];
    contentScrollView.delegate = self;
    contentScrollView.backgroundColor = MainLineGrayColor;
    self.contentScrollView = contentScrollView;
    
    contentScrollView.contentSize = CGSizeMake(self.navHeads.count * ScreenWidth, 0);
    contentScrollView.bounces = NO;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.pagingEnabled = YES;
    contentScrollView.delegate = self;
    [self.contentView addSubview:contentScrollView];
    
    //向右滑动
    UIPanGestureRecognizer *scrollRight = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(scrollPanRight:)];
    scrollRight.delegate = self;
    [self.contentScrollView addGestureRecognizer:scrollRight];
    
    for (int i = 0; i < self.navHeads.count; i++) {
        NSDictionary *dict = self.navHeads[i];
        NSInteger carLevel = [dict[@"levelId"] integerValue];
        IndexContentController *indexContentVc = [[IndexContentController alloc]initWithCarLevel:carLevel SuperView:self.view];
        indexContentVc.mydelegate = self;
        indexContentVc.tableView.tag = i;
        indexContentVc.tableView.frame = CGRectMake(i * ScreenWidth, 0, ScreenWidth, ScreenHeight - 20 - 44);
        [contentScrollView addSubview:indexContentVc.tableView];
        [self addChildViewController:indexContentVc];
        
        //添加到数组
        [self.indexContentVcs addObject:indexContentVc];
        
    }
    
    IndexContentController *contentVc = self.indexContentVcs[0];
    
    self.currentVc = contentVc;
    
    self.carLevel = 0;
    [contentVc loadDataWithLevel:self.carLevel];
    
}

//移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//筛选按钮
- (void)moreBtnClick {
    ScreeningController *screeningVc = [[ScreeningController alloc]initWithInfo:self.navBarInfoDict];
    self.screeningVc = screeningVc;
    
    [self.navigationController pushViewController:screeningVc animated:YES];
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;

}

- (void)searchSeriesBtnClick {
    CTSearchController *searchVc = [[CTSearchController alloc]init];
    self.searchVc = searchVc;
    [self.navigationController pushViewController:searchVc animated:YES];
}

- (void)reducePriceBtnClick {
    
    RPriceController *reduceVc = [[RPriceController alloc]init];
    self.reduceVc = reduceVc;
    
    [self.navigationController pushViewController:reduceVc animated:YES];
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;
    
    
}

- (void)bookDriveBtnClick {
    
    //友盟统计
    
    [MobClick event:@"iOS_AD_Click_Count"];
    
    NSURL *url = [NSURL URLWithString:@"http://auto.news18a.com/init.php?m=price&c=index&a=index&from=maichetong"];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void)buyNewCarBtnClick {
    NewCarGuideController *carGuideVc = [[NewCarGuideController alloc]init];
    self.carGuideVc = carGuideVc;
    [self.navigationController pushViewController:carGuideVc animated:YES];
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;

}

- (void)carCompareBtnClick {
    CTCompareController *compareVc = [[CTCompareController alloc]init];
    self.compareVc = compareVc;
    [self.navigationController pushViewController:compareVc animated:YES];
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;

}

- (void)menuBgViewTap {
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        tab.tabBarView.frame = CGRectMake(0, ScreenHeight - tab.tabBarView.bounds.size.height, tab.tabBarView.bounds.size.width, tab.tabBarView.bounds.size.height);
    }];
    
    self.contentScrollView.scrollEnabled = YES;
    
    self.menuBtn.selected = NO;
    
    [self.view bringSubviewToFront:self.contentView];
    
}

- (void)menuBtnClick:(UIButton *)menuBtn {
    menuBtn.selected = !menuBtn.selected;
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    if (menuBtn.selected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.frame =CGRectMake(MenuWidth, 0, ScreenWidth, ScreenHeight);
            tab.tabBarView.frame = CGRectMake(MenuWidth, ScreenHeight - tab.tabBarView.bounds.size.height, tab.tabBarView.bounds.size.width, tab.tabBarView.bounds.size.height);
        }];
        [self.view bringSubviewToFront:self.menuView];
        //统计显示广告
        [MobClick event:@"iOS_AD_Show_Count"];
    }
    
}

- (void)historyBtnClick {
    //历史记录
    IndexHistoryController *historyVc = [[IndexHistoryController alloc]initWithHistoryCars:self.historyCars];
    
    self.historyVc = historyVc;
    [self.navigationController pushViewController:historyVc animated:YES];
    
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)screeningClick {
    ScreeningController *screeningVc = [[ScreeningController alloc]initWithInfo:self.navBarInfoDict];
    
    [self.navigationController pushViewController:screeningVc animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    
    if (self.historyCars.count == 0) {
        self.historyBtn.enabled = NO;
    } else {
        self.historyBtn.enabled = YES;
    }
}

- (void)carTypeScroll {
    
    [UIView animateWithDuration:1.0 animations:^{
        self.navView.transform = CGAffineTransformMakeTranslation(0, - NavViewHeight);
        self.indexTableView.transform = CGAffineTransformMakeTranslation(0, - NavViewHeight + StatusHeight);
        [self.indexTableView setContentOffset:CGPointMake(0, (self.indexTableView.contentSize.height - CarTypeViewHeight -CTNavBarViewHeight)) animated:NO];
    }];
}


- (void)didChangeInfoDict:(NSDictionary *)navBarInfoDict {
    
    self.navBarInfoDict = navBarInfoDict;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = locations[0];
    
    
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longtitude = location.coordinate.longitude;
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
    [self.geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *pm = [placemarks firstObject];
        self.cityStr = pm.addressDictionary[@"State"];
        self.longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
        self.latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
        
        //将相关的城市数据同步到偏好设置里面
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.cityBtn setTitle:self.cityStr forState:UIControlStateNormal];
//        });
        
        //北京城市ID：1
        
        [[NSUserDefaults standardUserDefaults] setObject:self.longitude forKey:kDefaultCityLongitude];
        [[NSUserDefaults standardUserDefaults] setObject:self.latitude forKey:kDefaultCityLatitude];
        
        
        [self citys];
        
    }];
    
    [self.manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    MyLog(@"error:%@",error);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.contentView.frame.origin.x > 0) {
        self.contentScrollView.scrollEnabled = NO;
    } else {
        self.contentScrollView.scrollEnabled = YES;
    }
}


- (void)indexBtnClick:(IndexNavBarView *)cTNavBarView NavBtn:(CarNavButton *)carNavBtn RemberSliderX:(CGFloat)remberSliderX {
    
    CGFloat time = 0.0;
    if (self.remberTag > carNavBtn.tag) {
        time = (self.remberTag - carNavBtn.tag) * 0.2;
    } else {
        time = (carNavBtn.tag - self.remberTag) * 0.2;
    }
    
    self.remberTag = carNavBtn.tag;
    
    self.rembersliderX = remberSliderX;
    
    self.pageNo = 1;
    
    self.carLevel = [carNavBtn.contentDict[@"levelId"] integerValue];
    
    self.navBarInfoDict = carNavBtn.contentDict;
    
    
    //点击按钮切换内容视图
    [UIView animateWithDuration:time animations:^{
        self.contentScrollView.contentOffset = CGPointMake(carNavBtn.tag * ScreenWidth, 0);
    }];
}

- (void)indexContentScroll:(IndexContentController *)indexTableController isup:(BOOL)isup {
    
    if (indexTableController.tableView.contentOffset.y >= 50) {
        [UIView animateWithDuration:0.4 animations:^{
            self.headView.frame = CGRectMake(0, -105 + 20, ScreenWidth, 105 + 44);
            self.contentScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), ScreenWidth, ScreenHeight - 44 - 20);
        }];
    
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            self.headView.frame = CGRectMake(0, 20, ScreenWidth, 105 + 44);
            self.contentScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), ScreenWidth, ScreenHeight - 44 - 20);
        }];
        
    }
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    
    if (isup == YES) {
        [UIView animateWithDuration:0.3 animations:^{
            tab.tabBarView.frame = CGRectMake(self.contentView.frame.origin.x, ScreenHeight, ScreenWidth, TabBarHeight);
        }];
        
    } else if (isup == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            tab.tabBarView.frame = CGRectMake(self.contentView.frame.origin.x, ScreenHeight - TabBarHeight, ScreenWidth, TabBarHeight);
        }];
    }
}

#pragma mark - UIScrollView代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.indexNavBarView contentViewDidScroll:scrollView];
    
    CGFloat contentX = scrollView.contentOffset.x;
    if (contentX == 0 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[0];
        self.currentVc = indexContentVc;
        self.carLevel = 0;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 1 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[1];
        self.currentVc = indexContentVc;
        self.carLevel = 2;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 2 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[2];
        self.currentVc = indexContentVc;
        self.carLevel = 7;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 3 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[3];
        self.currentVc = indexContentVc;
        self.carLevel = 3;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 4 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[4];
        self.currentVc = indexContentVc;
        self.carLevel = 1;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 5 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[5];
        self.currentVc = indexContentVc;
        self.carLevel = 9;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 6 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[6];
        self.currentVc = indexContentVc;
        self.carLevel = 5;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 7 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[7];
        self.currentVc = indexContentVc;
        self.carLevel = 4;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 8 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[8];
        self.currentVc = indexContentVc;
        self.carLevel = 8;
        [indexContentVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 9 * ScreenWidth) {
        IndexContentController *indexContentVc = self.indexContentVcs[9];
        self.currentVc = indexContentVc;
        self.carLevel = 6;
        [indexContentVc loadDataWithLevel:self.carLevel];
    }
}


- (void)goToCompareVc {
    //push到车型对比界面去
    
    CTCompareController *compareVc = [[CTCompareController alloc]init];
    self.compareVc = compareVc;
    [self.navigationController pushViewController:compareVc animated:NO];
    
//    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
//    [tab.tabBarView btnclick:0];
    
}



@end
