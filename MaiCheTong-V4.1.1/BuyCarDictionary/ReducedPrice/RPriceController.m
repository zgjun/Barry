//
//  RPriceController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "RPriceController.h"
#import "RPNavBarView.h"
#import "CarNavButton.h"
#import "CityChooseController.h"
#import "RPriceContentController.h"
#import "AFNetworking.h"
#import "MainTabBarController.h"


#define NavBtnNum 4
#define NavBtnWidth (ScreenWidth / (NavBtnNum + 0.5))

#define RPNavBarViewHeight 44

#define NavHeight 64

#define ContentScrollHeight (ScreenHeight - NavHeight - RPNavBarViewHeight)

@interface RPriceController ()<RPNavBarViewDelegate,UIScrollViewDelegate,CityChooseControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) RPNavBarView *navBarView;

@property (nonatomic,weak) UIScrollView *contentScrollView;

@property (nonatomic,strong) NSArray *navHeads;

@property (nonatomic,weak) UIButton *cityBtn;

@property (nonatomic,strong) NSMutableArray *RPriceVcs;

@property (nonatomic,strong) RPriceContentController *currentVc;

@property (nonatomic,strong) NSString *cityStr;

@property (nonatomic,strong) NSString *carLevel;

@property (nonatomic,strong) CityChooseController *cityVc;

@end

@implementation RPriceController

- (NSString *)cityStr {
    _cityStr = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    
    if (_cityStr == nil) {
        _cityStr = [NSString stringWithFormat:@"北京"];
    }
    return _cityStr;
}

- (NSMutableArray *)RPriceVcs {
    if (_RPriceVcs == nil) {
        _RPriceVcs = [NSMutableArray array];
    }
    return _RPriceVcs;
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
    
    //禁用autolayout
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
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
    titleLabel.text = @"降价";
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];

    
    //创建头视图
    RPNavBarView *navBarView = [[RPNavBarView alloc]init];
    
    navBarView.delegate = self;
    
    navBarView.navTittles = self.navHeads;
    
    
    self.navBarView = navBarView;
    self.navBarView.frame = CGRectMake(0, CGRectGetMaxY(navView.frame), ScreenWidth,RPNavBarViewHeight);
    [self.view addSubview:navBarView];
    
    //创建内容视图
    UIScrollView *contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NavHeight + RPNavBarViewHeight, ScreenWidth, ContentScrollHeight)];
    self.contentScrollView = contentScrollView;
    
    contentScrollView.contentSize = CGSizeMake(self.navHeads.count * ScreenWidth, 0);
    contentScrollView.bounces = NO;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.pagingEnabled = YES;
    contentScrollView.delegate = self;
    for (int i = 0; i < self.navHeads.count; i++) {
        RPriceContentController *RPriceVc = [[RPriceContentController alloc]init];
        RPriceVc.navTittles = self.navHeads;
        RPriceVc.tableView.tag = i + 1;
        RPriceVc.tableView.frame = CGRectMake(i * ScreenWidth, 0, ScreenWidth, ContentScrollHeight);
        [contentScrollView addSubview:RPriceVc.tableView];
        [self addChildViewController:RPriceVc];
        
        //添加到数组
        [self.RPriceVcs addObject:RPriceVc];
    }
    
    [self.view addSubview:contentScrollView];
    
    RPriceContentController *RPriceVc = self.RPriceVcs[0];
    
    self.currentVc = RPriceVc;
    
    
    //紧凑型车的carLevel是2
    [RPriceVc loadDataWithLevel:@"2"];
    
    self.carLevel = [NSString stringWithFormat:@"2"];

}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;
    
    NSString *cityTitle = self.cityBtn.titleLabel.text;
    
    
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    
    if (![city isEqualToString: cityTitle] && city != nil) {
        
        [self.cityBtn setTitle:city forState:UIControlStateNormal];
        
    } else {
        [self.cityBtn setTitle:cityTitle forState:UIControlStateNormal];
    }
    
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
    
    [self.currentVc.tableView reloadData];
    
    [self.currentVc loadDataWithLevel:self.carLevel];
}


- (NSArray *)navHeads {
    if (_navHeads == nil) {
        NSString *urlStr = @"http://api.tool.chexun.com/mobile/buyCarCartypeInfo.do";
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        
        if (data == nil) {
            _navHeads = @[@{@"levelId":@1,@"name":@"小型车",@"sort":@4},
                          @{@"levelId":@2,@"name":@"紧凑型车",@"sort":@1},
                          @{@"levelId":@3,@"name":@"中型车",@"sort":@3},
                          @{@"levelId":@4,@"name":@"中大型车",@"sort":@7},
                          @{@"levelId":@5,@"name":@"豪华车",@"sort":@6},
                          @{@"levelId":@6,@"name":@"MPV",@"sort":@9},
                          @{@"levelId":@7,@"name":@"SUV",@"sort":@2},
                          @{@"levelId":@8,@"name":@"跑车",@"sort":@8},
                          @{@"levelId":@9,@"name":@"微型车",@"sort":@5},
                          ];
        } else {
            NSError *error;
            
            _navHeads = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
        }
        
        
    }
    return _navHeads;
}
#pragma mark - UIScrollView代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.navBarView contentViewDidScroll:scrollView];
    
    CGFloat contentX = scrollView.contentOffset.x;
    if (contentX == 0 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[0];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"2"];
        [rPriceVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 1 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[1];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"7"];
        [rPriceVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 2 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[2];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"3"];
        [rPriceVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 3 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[3];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"1"];
        [rPriceVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 4 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[4];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"9"];
        [rPriceVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 5 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[5];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"5"];
        [rPriceVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 6 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[6];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"4"];
        [rPriceVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 7 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[7];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"8"];
        [rPriceVc loadDataWithLevel:self.carLevel];
    } else if (contentX == 8 * ScreenWidth) {
        RPriceContentController *rPriceVc = self.RPriceVcs[8];
        self.currentVc = rPriceVc;
        self.carLevel = [NSString stringWithFormat:@"6"];
        [rPriceVc loadDataWithLevel:self.carLevel ];
    }
    
}

#pragma mark - RPNavBarView代理方法

- (void)rPNavBtnClick:(RPNavBarView *)rPNavBarView NavBtn:(CarNavButton *)carNavBtn {
    
    //异步加载数据
//    [self loadTableData:carNavBtn];
    
    //点击按钮切换内容视图
    [UIView animateWithDuration:0.5 animations:^{
        self.contentScrollView.contentOffset = CGPointMake((carNavBtn.tag - 1) * ScreenWidth, 0);
    }];
    
}

//- (void)loadTableData:(CarNavButton *)carNavBtn {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    NSString *urlStr = @"http://api.tool.chexun.com/mobile/buyCarCutPrice.do?carLevel=7&pageNo=2&pageSize=20&cityId=1";
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        RPriceContentController *rpVc = self.RPriceVcs[carNavBtn.tag - 1];
//        rpVc.contentArr = responseObject;
//        [rpVc.tableView reloadData];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        MyLog(@"%@",error);
//        
//    }];
//}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}

@end
