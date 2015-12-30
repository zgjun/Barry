//
//  CarSeriesController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-5.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarSeriesController.h"
#import "CityChooseController.h"
#import "NoHighLightBtn.h"
#import "CSCarTypeController.h"
#import "CSDealerController.h"
#import "CSMarketController.h"
#import "ParameterController.h"
#import "MainTabBarController.h"
#import "MBProgressHUD+GJ.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

#import "UIImage+Extension.h"
#import "CSContentCell.h"
#import "CSMarketAllController.h"
#import "CSDealerAllController.h"
#import "CarScreenResultController.h"
#import "PriceComponentsController.h"
#import "CSImageShowController.h"

#define NavHeight 64
#define NavViewHeight 49

@interface CarSeriesController ()<UITableViewDataSource,UITableViewDelegate,CSContentCellDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIButton *cityBtn;

@property (nonatomic,strong) NSMutableDictionary *seriesDict;


@property (nonatomic,strong) CSCarTypeController *cSCarTypeVc;

@property (nonatomic,strong) CSDealerController *cSDealerVc;

@property (nonatomic,strong) CSMarketController *cSMarketVc;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,weak) UIView *bgView;

@property (nonatomic,weak) UILabel *titleLabel;

///导航视图
@property (nonatomic,weak) UIView *navView;

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,strong) __block NSArray *contentData;

@property (nonatomic,weak) UIImageView *headImage;

@property (nonatomic,strong) __block NSDictionary *contentDict;

@property (nonatomic,strong) __block NSString *displaceStr;

@property (nonatomic,strong) __block NSMutableArray *displaces;

@property (nonatomic,weak) UIButton *currentBtn;

@property (nonatomic,weak) UIScrollView *contentScroll;

@property (nonatomic,weak) UIView *sliderBar;

@property (nonatomic,weak) UIButton *dealerBtn;

@property (nonatomic,weak) UIButton *marketBtn;

@property (nonatomic,weak) UILabel *carTypeLabel;

@property (nonatomic,strong) PriceComponentsController *priceVc;

@property (nonatomic,strong) CSDealerAllController *dealerVc;

@property (nonatomic,strong) CSMarketAllController *marketVc;

@property (nonatomic,strong) ParameterController *parameterVc;

@property (nonatomic,weak) UIView *noMarketView;

@property (nonatomic,weak) UIView *noDealerView;

@property (nonatomic,weak) UIView *spliteLine;

@property (nonatomic,assign) __block NSInteger isMarketZero;

@property (nonatomic,assign) __block NSInteger isDealerZero;

@property (nonatomic,weak) UIView *dealerFooter;

@property (nonatomic,weak) UIView *markFooter;
@end

@implementation CarSeriesController

- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}

- (CSMarketController *)cSMarketVc {
    if (_cSMarketVc == nil) {
        NSDictionary *contentDict = @{@"seriesId":self.seriesDict[@"id"],
                                      @"cityId":self.cityId};
        
        _cSMarketVc = [[CSMarketController alloc]initWithContentDict:contentDict];
        [self addChildViewController:_cSMarketVc];
    }
    return _cSMarketVc;
}

- (CSDealerController *)cSDealerVc {
    if (_cSDealerVc == nil) {
        NSDictionary *contentDict = @{@"seriesId":self.seriesDict[@"id"],
                                      @"cityId":self.cityId};
        
        _cSDealerVc = [[CSDealerController alloc]initWithContentDict:contentDict];
        
        [self addChildViewController:_cSDealerVc];
    }
    return _cSDealerVc;
}


- (CSCarTypeController *)cSCarTypeVc {
    if (_cSCarTypeVc == nil) {
        NSDictionary *contentDict = @{@"seriesId":self.seriesDict[@"id"],
                                      @"seriesName":self.seriesDict[@"name"],
                                      @"seriesImg":self.seriesDict[@"imgPath"],
                                      @"cityId":self.cityId};
        
        _cSCarTypeVc = [[CSCarTypeController alloc]initWithContentDict:contentDict];
    }
    return _cSCarTypeVc;
}

- (instancetype)initWithSeriesDict:(NSDictionary *)seriesDict {
    if (self = [super init]) {
        self.seriesDict = [NSMutableDictionary dictionaryWithDictionary:seriesDict];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;
    
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
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
    
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    //写进历史记录
    
    [self writeToHistory];
    
    
    //创建子视图
    [self createChildViews];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
    
    
    
}

- (void)writeToHistory {
    //在显示完成后，写进历史记录
    //确定写入的路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"seriesHistory.plist"];
    
    
    //先读取之前的历史记录
    NSMutableArray *historyArr = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    
    if (historyArr.count == 0) {
        historyArr = [NSMutableArray arrayWithObject:self.seriesDict];
    } else {
        //去重
        for (int i = 0; i < historyArr.count; i++) {
            NSDictionary *dict = historyArr[i];
            if ([self.seriesDict[@"id"] isEqual:dict[@"id"]]) {
                [historyArr removeObjectAtIndex:i];
            }
        }
        [historyArr insertObject:self.seriesDict atIndex:0];
        //只保留10条数据
        if (historyArr.count > 10) {
            [historyArr removeLastObject];
        }
    }
    
    [historyArr writeToFile:fileName atomically:YES];
}

- (void)getData {
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesPage.do?seriesId=%@&cityId=%@",self.seriesDict[@"id"],self.cityId];

    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CarSeriesController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _contentData = responseObject[@"carModelList"];
        
        _contentDict = responseObject;
        
        myself.carTypeLabel.text = responseObject[@"level"];
        
        [myself.seriesDict setObject:responseObject[@"imagePath"] forKey:@"imgPath"];
        
        [myself.headImage sd_setImageWithURL:[NSURL URLWithString:responseObject[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load0"]];
        
        
        myself.displaceStr = responseObject[@"displacement"];
        myself.displaces = [NSMutableArray arrayWithArray:[myself.displaceStr componentsSeparatedByString:@","]];
        [myself.displaces removeLastObject];
        
        //把上面的品牌数组，变成二维数组
        NSMutableArray *sections = [NSMutableArray array];
        for (int i = 0; i < myself.displaces.count; i++) {
            
            NSNumber *displace = myself.displaces[i];
            NSMutableArray *cells = [NSMutableArray array];
            for (int j = 0; j < _contentData.count; j++) {
                
                NSDictionary *displaceLetter = _contentData[j];
                if ([displace floatValue] == [displaceLetter[@"displacement"] floatValue]) {
                    
                    [cells addObject:displaceLetter];
                }
            }
            
            if (cells.count > 0) {
                [sections addObject:cells];
            }
        }
        
        _contentData = sections;
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }];
}


///配置单按钮
- (void)configurationBtnClick {
    if (self.seriesDict == nil ||
        self.seriesDict.count == 0 ||
        self.seriesDict[@"id"] == nil ||
        self.seriesDict[@"imgPath"] == nil ||
        self.seriesDict[@"name"] == nil
        ) {
        
        return;
    }
    
    NSDictionary *dict = @{@"carSeriesId":self.seriesDict[@"id"],
                           @"carSeriesImg":self.seriesDict[@"imgPath"],
                           @"carSeriesName":self.seriesDict[@"name"]};
    
    ParameterController *parameterVc = [[ParameterController alloc]initWithCarSeriesDict:dict];
    self.parameterVc = parameterVc;
    [self.navigationController pushViewController:parameterVc animated:YES];
    
}

- (void)createChildViews {
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    UIImageView *headImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, (ScreenWidth / 3) * 2)];
    
    headImage.userInteractionEnabled = YES;
    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headTap)];
    [headImage addGestureRecognizer:tap];
    
    self.headImage = headImage;
    self.tableView.tableHeaderView = headImage;
    
    //车系相关信息
    UIImageView *carDetailView = [[UIImageView alloc]initWithImage:[UIImage resizableImageWithName:@"chexun_tabbarbg"]];
    carDetailView.frame = CGRectMake(0, (ScreenWidth / 3) * 2 - 35, ScreenWidth, 35);
    [headImage addSubview:carDetailView];
    
    
    UILabel *carSeriesLabel = [[UILabel alloc]init];
    carSeriesLabel.font = [UIFont systemFontOfSize:14];
    carSeriesLabel.textColor = MainWhiteColor;
    [carDetailView addSubview:carSeriesLabel];
    
    
    NSString *carSeriesStr = [NSString stringWithFormat:@"%@",self.seriesDict[@"name"]];
    
    CGSize carSeriesMaxSize = CGSizeMake(150, 40);
    
    NSDictionary *carSeriesAttrs = @{NSFontAttributeName : carSeriesLabel.font};
    CGSize carSeriesSize = [carSeriesStr boundingRectWithSize:carSeriesMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:carSeriesAttrs context:nil].size;
    carSeriesLabel.text = carSeriesStr;
    carSeriesLabel.frame = CGRectMake(5, 0, carSeriesSize.width, 35);
    
    
    UILabel *carTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(carSeriesLabel.frame) + 10, 0, 70, 35)];
    self.carTypeLabel = carTypeLabel;
    carTypeLabel.font = [UIFont systemFontOfSize:12];
    carTypeLabel.textColor = MainFontGrayColor;
    [carDetailView addSubview:carTypeLabel];
    
    //品牌的图标
    UIImageView *brandBgImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 50 - 65, (ScreenWidth / 3) * 2 - 50 * 0.5, 50, 50)];
    brandBgImage.image = [UIImage imageNamed:@"chexun_series_logobg"];

    [headImage addSubview:brandBgImage];
    
    
    UIImageView *iconImage = [[UIImageView alloc]init];
    [iconImage sd_setImageWithURL:[NSURL URLWithString:self.seriesDict[@"brandLogo"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    iconImage.frame = CGRectMake(3, 3, 44, 44);
    [brandBgImage addSubview:iconImage];
    iconImage.layer.cornerRadius = 22;
    iconImage.layer.masksToBounds = YES;
    
    //导航视图
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    navView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navView];
    
    //导航视图的背景视图
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    self.bgView = bgView;
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = 0.0;
    [navView addSubview:bgView];
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 22, 40, 40)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"chexun_backarrow_white"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    //标题视图
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 230) * 0.5, 20, 230, 44)];
    self.titleLabel = titleLabel;
    titleLabel.alpha = 0.0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.text = self.seriesDict[@"name"];
    [navView addSubview:titleLabel];
    
    //配置单按钮
    UIButton *configurationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [configurationBtn addTarget:self action:@selector(configurationBtnClick) forControlEvents:UIControlEventTouchDown];
    configurationBtn.frame = CGRectMake(ScreenWidth - 50, 22, 40, 40);
    
    configurationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [configurationBtn setBackgroundImage:[UIImage imageNamed:@"chexun_canshuicon_white"] forState:UIControlStateNormal];
    [navView addSubview:configurationBtn];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    self.spliteLine = spliteLine;
    spliteLine.alpha = 0.0;
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
}

- (void)headTap {
    CSImageShowController *imageShowVc = [[CSImageShowController alloc]initWithTitle:self.seriesDict[@"name"] seriesId:self.seriesDict[@"id"]];
    [self.navigationController pushViewController:imageShowVc animated:YES];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark table datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contentData.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        NSArray *arr = self.contentData[section - 1];
        return arr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        UIView *tabBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        tabBar.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:tabBar];
        //添加两个按钮
        UIButton *marketBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
        self.marketBtn = marketBtn;
        marketBtn.tag = 0;
        [marketBtn setTitle:@"行情" forState:UIControlStateNormal];
        [marketBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [marketBtn setTitleColor:MainGoldenColor forState:UIControlStateSelected];
        [marketBtn addTarget:self action:@selector(barBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.currentBtn == nil) {
            [self barBtnClick:marketBtn];
        }
        [tabBar addSubview:marketBtn];
        
        UIButton *dealerBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, 0, 80, 44)];
        self.dealerBtn = dealerBtn;
        dealerBtn.tag = 1;
        [dealerBtn setTitle:@"经销商" forState:UIControlStateNormal];
        [dealerBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [dealerBtn setTitleColor:MainGoldenColor forState:UIControlStateSelected];
        [dealerBtn addTarget:self action:@selector(barBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [tabBar addSubview:dealerBtn];
        
        //下面的分割线
        UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 44 - 1, ScreenWidth, 1)];
        bottomLine.backgroundColor = MainLineGrayColor;
        [tabBar addSubview:bottomLine];
        //滑块
        UIView *sliderBar = [[UIView alloc]initWithFrame:CGRectMake(0, 44 - 2, 80, 2)];
        self.sliderBar = sliderBar;
        sliderBar.backgroundColor = MainGoldenColor;
        [tabBar addSubview:sliderBar];
        
        
        UIScrollView *contentScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tabBar.frame), ScreenWidth, 2 * 100 + 40)];
        contentScroll.delegate = self;
        self.contentScroll = contentScroll;
        contentScroll.bounces = NO;
        contentScroll.showsHorizontalScrollIndicator = NO;
        contentScroll.pagingEnabled = YES;
        contentScroll.contentSize = CGSizeMake(ScreenWidth * 2, 0);
        contentScroll.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:contentScroll];
        
        self.cSMarketVc.tableView.frame = CGRectMake(0, 0, ScreenWidth, 2 * 100);
        self.cSMarketVc.tableView.bounces = NO;
        
        
        
        __weak CarSeriesController *mySelf = self;
        
        self.cSMarketVc.marketBlock = ^(NSInteger isMarketZero) {
            mySelf.isMarketZero = isMarketZero;
            if (mySelf.isMarketZero == 1 && mySelf.isDealerZero == 1) {
                mySelf.cSMarketVc.tableView.hidden = YES;
                mySelf.markFooter.hidden = YES;
                mySelf.noMarketView.hidden = NO;
                mySelf.cSDealerVc.tableView.hidden = YES;
                mySelf.dealerFooter.hidden = YES;
                mySelf.noDealerView.hidden = NO;
//                [mySelf.tableView reloadData];
            } else if (mySelf.isMarketZero == 1 && mySelf.isDealerZero != 1) {
                [mySelf barBtnClick:mySelf.dealerBtn];
                mySelf.cSMarketVc.tableView.hidden = YES;
                mySelf.markFooter.hidden = YES;
                mySelf.noMarketView.hidden = NO;
            }
        };

        [contentScroll addSubview:self.cSMarketVc.tableView];
        UIView *markFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 200, ScreenWidth, 40)];
        self.markFooter = markFooter;
        [contentScroll addSubview:markFooter];
        
        UIButton *markFootBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 5,  ScreenWidth, 30)];
        markFootBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        markFootBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        markFootBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [markFootBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [markFootBtn setTitle:@"查看更多的行情" forState:UIControlStateNormal];
        [markFooter addSubview:markFootBtn];
        UIImageView *markIndicator = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 24,16, 5, 8)];
        markIndicator.image = [UIImage imageNamed:@"chexun_liftarrow"];
        [markFootBtn addTarget:self action:@selector(markFootBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [markFooter addSubview:markIndicator];
        
        
        //没有行情数据
        UIView *noMarketView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 240)];
        noMarketView.hidden = YES;
        self.noMarketView = noMarketView;
        noMarketView.backgroundColor = [UIColor clearColor];
        [contentScroll addSubview:noMarketView];
        UIImageView *noMarketImage = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 35) * 0.5, (140 - 38) * 0.5, 35, 38)];
        noMarketImage.image = [UIImage imageNamed:@"chexun_tanhaoicon"];
        [noMarketView addSubview:noMarketImage];
        UILabel *noMarketLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, CGRectGetMaxY(noMarketImage.frame) + 5, 150, 30)];
        noMarketLabel.textAlignment = NSTextAlignmentCenter;
        noMarketLabel.font = [UIFont systemFontOfSize:14];
        noMarketLabel.textColor = MainFontGrayColor;
        noMarketLabel.text = @"暂时没有行情数据";
        [noMarketView addSubview:noMarketLabel];
        
        //没有行情的时候
        if (self.isMarketZero == 1) {
            mySelf.cSMarketVc.tableView.hidden = YES;
            mySelf.markFooter.hidden = YES;
            mySelf.noMarketView.hidden = NO;
        }
        
        self.cSDealerVc.tableView.frame = CGRectMake(ScreenWidth, 0, ScreenWidth, 2 * 100);
        self.cSDealerVc.tableView.bounces = NO;
        
        self.cSDealerVc.dealerBlock = ^(NSInteger isDearlerZero) {
            mySelf.isDealerZero = isDearlerZero;
            if (mySelf.isMarketZero == 1 && mySelf.isDealerZero == 1) {
                mySelf.cSMarketVc.tableView.hidden = YES;
                mySelf.markFooter.hidden = YES;
                mySelf.noMarketView.hidden = NO;
                mySelf.cSDealerVc.tableView.hidden = YES;
                mySelf.dealerFooter.hidden = YES;
                mySelf.noDealerView.hidden = NO;
            } else if (mySelf.isMarketZero != 1 && mySelf.isDealerZero == 1) {
                [mySelf barBtnClick:mySelf.marketBtn];
                mySelf.cSDealerVc.tableView.hidden = YES;
                mySelf.dealerFooter.hidden = YES;
                mySelf.noDealerView.hidden = NO;
            }
        };

        
        
        
        [contentScroll addSubview:self.cSDealerVc.tableView];
        UIView *dealerFooter = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth, 200, ScreenWidth, 40)];
        self.dealerFooter = dealerFooter;
        [contentScroll addSubview:dealerFooter];
        UIButton *dealerFootBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 5,  ScreenWidth, 30)];
        dealerFootBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        dealerFootBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        dealerFootBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [dealerFootBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [dealerFootBtn setTitle:@"查看更多的经销商" forState:UIControlStateNormal];
        [dealerFooter addSubview:dealerFootBtn];
        UIImageView *dealIndicator = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 24,16, 5, 8)];
        dealIndicator.image = [UIImage imageNamed:@"chexun_liftarrow"];
        [dealerFootBtn addTarget:self action:@selector(dealerFootBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [dealerFooter addSubview:dealIndicator];
        
        
        
        //没有经销商数据
        UIView *noDealerView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, 240)];
        self.noDealerView = noDealerView;
        noDealerView.hidden = YES;
        noDealerView.backgroundColor = [UIColor clearColor];
        [contentScroll addSubview:noDealerView];
        UIImageView *noDealerImage = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 35) * 0.5, (140 - 38) * 0.5, 35, 38)];
        noDealerImage.image = [UIImage imageNamed:@"chexun_tanhaoicon"];
        [noDealerView addSubview:noDealerImage];
        UILabel *noDealerLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, CGRectGetMaxY(noDealerImage.frame) + 5, 150, 30)];
        noDealerLabel.textAlignment = NSTextAlignmentCenter;
        noDealerLabel.font = [UIFont systemFontOfSize:14];
        noDealerLabel.textColor = MainFontGrayColor;
        noDealerLabel.text = @"暂时没有经销商数据";
        [noDealerView addSubview:noDealerLabel];
        
        //没有经销商的时候
        if (self.isDealerZero == 1) {
            mySelf.cSDealerVc.tableView.hidden = YES;
            mySelf.dealerFooter.hidden = YES;
            mySelf.noDealerView.hidden = NO;
        }
        
        
        cell.backgroundColor = MainBackGroundColor;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *ID = @"ContentCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        CSContentCell *contentCell;
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            contentCell = [[CSContentCell alloc]init];
            contentCell.frame = CGRectMake(0, 0, ScreenWidth, 109);
            contentCell.delegate = self;
            [cell.contentView addSubview:contentCell];
        }
        
        
        contentCell = (CSContentCell *)cell.contentView.subviews[0];
        
        NSArray *arr = self.contentData[indexPath.section - 1];
        NSDictionary *dict = arr[indexPath.row];
        
        contentCell.cellDict = dict;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }
}

- (void)markFootBtnClick {
    NSDictionary *contentDict = @{@"seriesId":self.seriesDict[@"id"],
                                  
                                  @"cityId":self.cityId};
    
    
    CSMarketAllController *marketVc = [[CSMarketAllController alloc]initWithContentDict:contentDict];
    self.marketVc = marketVc;
    [self.navigationController pushViewController:marketVc animated:YES];
}
- (void)dealerFootBtnClick {
    NSDictionary *contentDict = @{@"seriesId":self.seriesDict[@"id"],
                                  @"cityId":self.cityId};
    
    CSDealerAllController *dealerVc = [[CSDealerAllController alloc]initWithContentDict:contentDict];
    self.dealerVc = dealerVc;
    [self.navigationController pushViewController:dealerVc animated:YES];
}

- (void)barBtnClick:(UIButton *)btn {
    if (btn == self.currentBtn) return;
//    btn.selected = YES;
//    self.currentBtn.selected = NO;
//    self.currentBtn = btn;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentScroll.contentOffset = CGPointMake(btn.tag *ScreenWidth, 0);
        
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([[scrollView class] isSubclassOfClass:[UITableView class]]) {
        
        CGFloat alpha = 0.0;
        alpha = scrollView.contentOffset.y * 0.007;
        alpha = alpha > 1.0 ? 1.0 : alpha;
        alpha = alpha < 0.0 ? 0.0 : alpha;
        self.bgView.alpha = alpha;
        self.spliteLine.alpha = alpha;
        self.titleLabel.alpha = alpha;
    } else {
        if (scrollView.contentOffset.x <= 0) {
            self.sliderBar.frame = CGRectMake(0, self.sliderBar.y, self.sliderBar.width,  self.sliderBar.height);
        } else {
            self.sliderBar.frame = CGRectMake(scrollView.contentOffset.x / ScreenWidth * 80, self.sliderBar.y, self.sliderBar.width,  self.sliderBar.height);
        }
        
        
        if (scrollView.contentOffset.x / ScreenWidth == 1) {
            self.dealerBtn.selected = YES;
            self.currentBtn.selected = NO;
            self.currentBtn = self.dealerBtn;
        } else if (scrollView.contentOffset.x / ScreenWidth == 0) {
            self.marketBtn.selected = YES;
            self.currentBtn.selected = NO;
            self.currentBtn = self.marketBtn;
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else if(section == 1) {
        
        return 44 + 30;
        
    } else {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44 + 2 * 100 + 40 + 15;
    } else {
        return 29 + 80;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return nil;
        
    } else if (section == 1) {
        UIView *secView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        secView.backgroundColor = [UIColor whiteColor];
        
        
        UIButton *carTypeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 5,  ScreenWidth, 30)];
        carTypeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        carTypeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        carTypeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [carTypeBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [carTypeBtn setTitle:@"在售车款" forState:UIControlStateNormal];
        [secView addSubview:carTypeBtn];
        UIImageView *carTypeIndicator = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 24,18, 5, 8)];
        carTypeIndicator.image = [UIImage imageNamed:@"chexun_liftarrow"];
        [carTypeBtn addTarget:self action:@selector(carTypeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [secView addSubview:carTypeIndicator];
        
        //中间的分割线
        UIView *centerLine = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(carTypeBtn.frame), ScreenWidth, 1)];
        centerLine.backgroundColor = MainLineGrayColor;
        [secView addSubview:centerLine];
        
        
        //前面的小圆点
        UIView *dotView = [[UIView alloc]initWithFrame:CGRectMake(10 , CGRectGetMaxY(carTypeBtn.frame) + 16, 8, 8)];
        dotView.backgroundColor = MainGoldenColor;
        dotView.layer.cornerRadius = 4;
        dotView.clipsToBounds = YES;
        [secView addSubview:dotView];
        
        UILabel *displaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(dotView.frame) + 5, CGRectGetMaxY(carTypeBtn.frame) + 5, 100, 30)];
        displaceLabel.textColor = MainFontGrayColor;
        displaceLabel.backgroundColor = [UIColor clearColor];
        displaceLabel.contentMode = UIViewContentModeLeft;
        displaceLabel.font = [UIFont systemFontOfSize:14];
        displaceLabel.text = [NSString stringWithFormat:@"%@",self.displaces[section - 1]];
        [secView addSubview:displaceLabel];
        
        
        //分割线
        NSString *backgroudpath = [[NSBundle mainBundle] pathForResource:@"chexun_dotted-line" ofType:@"png"];
        UIView *bottomLine = [[UIView alloc]init];
        
        UIImage  *backgroudImage = [UIImage imageWithContentsOfFile:backgroudpath];
        bottomLine.backgroundColor=[UIColor colorWithPatternImage:backgroudImage] ;
        bottomLine.frame = CGRectMake(0, 44 + 30 - 1, ScreenWidth, 1);
        [secView addSubview:bottomLine];
        
        
        return secView;
    } else {
        UIView *secView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        secView.backgroundColor = [UIColor whiteColor];
        //前面的小圆点
        UIView *dotView = [[UIView alloc]initWithFrame:CGRectMake(10 ,10, 8, 8)];
        dotView.backgroundColor = MainGoldenColor;
        dotView.layer.cornerRadius = 4;
        dotView.clipsToBounds = YES;
        [secView addSubview:dotView];

        
        UILabel *displaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(dotView.frame) + 5, 0, 100, 30)];
        displaceLabel.textColor = MainFontGrayColor;
        displaceLabel.backgroundColor = [UIColor clearColor];
        displaceLabel.contentMode = UIViewContentModeLeft;
        displaceLabel.font = [UIFont systemFontOfSize:14];
        displaceLabel.text = [NSString stringWithFormat:@"%@",self.displaces[section - 1]];
        [secView addSubview:displaceLabel];
        
        //分割线
        NSString *backgroudpath = [[NSBundle mainBundle] pathForResource:@"chexun_dotted-line" ofType:@"png"];
        UIView *bottomLine = [[UIView alloc]init];
        
        UIImage  *backgroudImage = [UIImage imageWithContentsOfFile:backgroudpath];
        bottomLine.backgroundColor=[UIColor colorWithPatternImage:backgroudImage] ;
        bottomLine.frame = CGRectMake(0, 30 - 1, ScreenWidth, 1);
        [secView addSubview:bottomLine];
        
        return secView;
    }
    
}

- (void)carTypeBtnClick {
    CarScreenResultController *carResultVc = [[CarScreenResultController alloc]initWithDisplaces:self.displaces cityId:self.cityId seriesDict:self.seriesDict];
    [self.navigationController pushViewController:carResultVc animated:YES];
}

#pragma mark - CSContentCellDelegate方法
- (void)cSContentCellClick:(CSContentCell *)contentCell {
    NSString *carTypeId = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"id"]];
    NSString *carTypeName = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"name"]];
    NSString *carTypeImage = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"imagePath"]];
    NSString *carTypePrice = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"guidePrice"]];
    NSString *carTypeLowPrice = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"MinPrice"]];
    
    
    
    NSString *carSeriesId = self.seriesDict[@"id"];
    NSString *carSeriesName = self.seriesDict[@"name"];
    
    NSDictionary *carTypeInfo = @{@"carSeriesId":carSeriesId,@"carSeriesName":carSeriesName,@"carTypeId":carTypeId,@"carTypeName":carTypeName,@"carTypeImage":carTypeImage,@"carTypePrice":carTypePrice,@"carTypeLowPrice":carTypeLowPrice,@"yearName":contentCell.cellDict[@"yearName"]};
    
    PriceComponentsController *priceVc = [[PriceComponentsController alloc]initWithPriceDict:carTypeInfo];
//    self.priceVc = priceVc;
    [self.navigationController pushViewController:priceVc animated:YES];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}




@end
