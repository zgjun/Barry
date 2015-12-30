//
//  OtherFourSController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-23.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherFourSController.h"
#import "CityChooseController.h"
#import "AFNetworking.h"
#import "MBProgressHUD+GJ.h"
#import "OtherHeadBtn.h"
#import "OtherFourSCell.h"
#import "CSDealerDetailController.h"
#import "CSActiveController.h"
#import "ChooseBrandController.h"
#import "ChooseSectionController.h"
#import "CTBgView.h"
#import "MJRefresh.h"
#import "HTTPHelper.h"
#import <CoreLocation/CoreLocation.h>
#import "MainTabBarController.h"



@interface OtherFourSController ()<CityChooseControllerDelegate,UITableViewDataSource,UITableViewDelegate,OtherFourSCellDelegate,CTBgViewDelegate,ChooseBrandControllerDelegate,ChooseSectionControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,weak) UIButton *cityBtn;

@property (nonatomic,strong) NSString *cityStr;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,weak) UIView *headView;

@property (nonatomic,strong) NSMutableArray *contentArr;

@property (nonatomic,strong) NSArray *sectionArr;


@property (nonatomic,strong)  ChooseBrandController *chooseBrandVc;

@property (nonatomic,strong) ChooseSectionController *chooseSectionVc;

@property (nonatomic,strong) CTBgView *bgView;

@property (nonatomic,strong) UIView *containerView;

@property (nonatomic,weak) OtherHeadBtn *brandBtn;

@property (nonatomic,weak) OtherHeadBtn *sectionBtn;

@property (nonatomic,assign) NSInteger sortType;

@property (nonatomic,assign) NSInteger pageIndex;

@property (nonatomic,assign) NSInteger pageSize;

@property (nonatomic,assign) NSInteger brandId;

@property (nonatomic,assign) NSInteger sectionId;

@property (nonatomic,strong) NSString *cityId;

//经度
@property (nonatomic,strong) __block NSString *longitude;
//纬度
@property (nonatomic,strong) __block NSString *latitude;

//地理编码
@property(nonatomic, strong) CLGeocoder *geocoder;


@property (nonatomic,strong) CityChooseController *cityVc;

@property (nonatomic,strong) CSDealerDetailController *dealerDetailVc;

@property (nonatomic,weak) CSActiveController *activeVc;

@end

@implementation OtherFourSController

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (NSInteger)sortType {
    if (_sortType == 0) {
        _sortType = 2;
    }
    return _sortType;
}

- (NSString *)longitude {
    _longitude = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityLongitude];
    if (_longitude == nil) {
        _longitude = [NSString stringWithFormat:@"116.33187772"];
    }
    
    return _longitude;
}

- (NSString *)latitude {
    _latitude = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityLatitude];
    if (_latitude == nil) {
        _latitude = [NSString stringWithFormat:@"39.99749624"];
    }
    
    return _latitude;
}

- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}

- (CTBgView *)bgView {
    if (_bgView == nil) {
        _bgView = [[CTBgView alloc]initWithFrame:self.tableView.frame];
        _bgView.delegate = self;
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha =0.5;
    }
    return _bgView;
}

- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame), ScreenWidth,300 )];
        _containerView.backgroundColor = MainBackGroundColor;
        
    }
    return _containerView;
}

- (NSString *)cityStr {
    _cityStr = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    
    if (_cityStr == nil) {
        _cityStr = [NSString stringWithFormat:@"北京"];
    }
    return _cityStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    self.tabBarController.tabBar.hidden = YES;
    self.view.backgroundColor = MainBackGroundColor;
    
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
    
    //设置的城市按钮
    UIButton *cityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cityBtn addTarget:self action:@selector(cityBtnClick:) forControlEvents:UIControlEventTouchDown];
    self.cityBtn = cityBtn;
    cityBtn.frame = CGRectMake(ScreenWidth  - 90, 20, 80, 44);
    cityBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    cityBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    cityBtn.titleLabel.textColor = [UIColor blackColor];
    [cityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [cityBtn setTitle:self.cityStr forState:UIControlStateNormal];
    [navView addSubview:cityBtn];
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, 20, 150, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"附近的4S店";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //创建头
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, 44)];
    self.headView = headView;
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    OtherHeadBtn *brandBtn = [[OtherHeadBtn alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth * 0.5, 44)];
    self.brandBtn = brandBtn;
    [brandBtn setTitleColor:MainBlackColor forState:UIControlStateNormal];
    [brandBtn setTitleColor:MainGoldenColor forState:UIControlStateSelected];
    [brandBtn setContentMode:UIViewContentModeRight];
    brandBtn.titleLabel.contentMode = UIViewContentModeRight;
    [brandBtn addTarget:self action:@selector(brandBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [brandBtn setImage:[UIImage imageNamed:@"chexun_downarrow"] forState:UIControlStateNormal];
    [brandBtn setImage:[UIImage imageNamed:@"chexun_uparrow0"] forState:UIControlStateSelected];
    [brandBtn setTitle:@"品牌" forState:UIControlStateNormal];
    [headView addSubview:brandBtn];
    
    //创建竖线
    UIView *vLine = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth * 0.5, 4, 1.5, 36)];
    vLine.backgroundColor = MainBackGroundColor;
    [headView addSubview:vLine];
    
    OtherHeadBtn *sectionBtn = [[OtherHeadBtn alloc] initWithFrame:CGRectMake(ScreenWidth * 0.5, 0, ScreenWidth * 0.5, 44)];
    self.sectionBtn = sectionBtn;
    [sectionBtn setTitleColor:MainBlackColor forState:UIControlStateNormal];
    [sectionBtn setTitleColor:MainGoldenColor forState:UIControlStateSelected];
    sectionBtn.titleLabel.contentMode = UIViewContentModeRight;
    [sectionBtn setContentMode:UIViewContentModeRight];
    [sectionBtn addTarget:self action:@selector(sectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [sectionBtn setImage:[UIImage imageNamed:@"chexun_downarrow"] forState:UIControlStateNormal];
    [sectionBtn setImage:[UIImage imageNamed:@"chexun_uparrow0"] forState:UIControlStateSelected];
    [sectionBtn setTitle:@"区域" forState:UIControlStateNormal];
    [headView addSubview:sectionBtn];
    
    //下面的分割线
    UIView *bottomLine = [[UIView alloc]init];
     bottomLine.backgroundColor = MainLineGrayColor;
    bottomLine.frame = CGRectMake(0, 44 - 1,ScreenWidth, 1);
    [headView addSubview:bottomLine];
    
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame), ScreenWidth, ScreenHeight - 44 - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"OtherFourSCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    [self pushRefresh];
    //初始化相关数据
    self.pageIndex = 1;
    self.pageSize = 10;
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
}

//添加上拉加载更多
- (void)pushRefresh {
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreStatus)];
    
    // 隐藏状态
    //self.tableView.footer.stateHidden = YES;
    
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=5; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"shuaxin%zd", i]];
        [refreshingImages addObject:image];
    }
    self.tableView.gifFooter.refreshingImages = refreshingImages;
}



- (void)loadMoreStatus {
    self.pageIndex = self.pageIndex + 1;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo3.ashx?sortType=%@&&longitude=%@&latitude=%@&pageIndex=%@&pageSize=%@&cityId=%@&brandID=%@&RegionalID=%@",@(self.sortType),self.longitude,self.latitude,@(self.pageIndex),@(self.pageSize),self.cityId,@(self.brandId),@(self.sectionId)];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    __weak OtherFourSController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *arr = responseObject[@"dealerList"];
        if (arr.count > 0) {
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dict = arr[i];
                
                [myself.contentArr addObject:dict];
            }
            
            [myself.tableView reloadData];
            [myself.tableView.gifFooter endRefreshing];
        } else {
            [myself.tableView.gifFooter endRefreshing];
        }
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        [myself.tableView.gifFooter endRefreshing];
        return;
        
    }];
}

///品牌按钮点击
- (void)brandBtnClick:(OtherHeadBtn *)btn {
    btn.selected = !btn.selected;
    
    if (!self.brandBtn.selected) {
        self.brandBtn.selected = NO;
        self.sectionBtn.selected = NO;
        [self.chooseBrandVc.tableView removeFromSuperview];
        [self.containerView removeFromSuperview];
        [self.bgView removeFromSuperview];
        self.chooseBrandVc = nil;
    } else {
        [self.view addSubview:self.bgView];
        [self.view addSubview:self.containerView];
        self.sectionBtn.selected = NO;
        self.chooseBrandVc = [[ChooseBrandController alloc]init];
        self.chooseBrandVc.delegate = self;
        self.chooseBrandVc.tableView.frame = self.containerView.bounds;
        [self.containerView addSubview:self.chooseBrandVc.tableView];
    }
    
}


///区域按钮点击
- (void)sectionBtnClick:(OtherHeadBtn *)btn {
    btn.selected = !btn.selected;
    
    if (!self.sectionBtn.selected) {
        self.sectionBtn.selected = NO;
        self.brandBtn.selected = NO;
        [self.chooseSectionVc.tableView removeFromSuperview];
        [self.containerView removeFromSuperview];
        [self.bgView removeFromSuperview];
        self.chooseSectionVc = nil;
    } else {
        self.brandBtn.selected = NO;
        [self.view addSubview:self.bgView];
        [self.view addSubview:self.containerView];
        
        self.chooseSectionVc = [[ChooseSectionController alloc]initWithSectionArr:self.sectionArr];
        self.chooseSectionVc.delegate = self;
        self.chooseSectionVc.tableView.frame = self.containerView.bounds;
        
        [self.containerView addSubview:self.chooseSectionVc.tableView];
    }
    
    
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo3.ashx?sortType=%@&&longitude=%@&latitude=%@&pageIndex=%@&pageSize=%@&cityId=%@&brandID=%@&RegionalID=%@",@(self.sortType),self.longitude,self.latitude,@(self.pageIndex),@(self.pageSize),self.cityId,@(self.brandId),@(self.sectionId)];
    
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    
    __weak OtherFourSController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        myself.contentArr = [NSMutableArray arrayWithArray:responseObject[@"dealerList"]];
        myself.sectionArr = responseObject[@"regional"];
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
    self.tabBarController.tabBar.hidden = YES;
}
- (void)cityBtnClick:(UIButton *)btn {
    CityChooseController *cityVc = [[CityChooseController alloc]init];
    self.cityVc = cityVc;
    cityVc.cityDelegate = self;
    
    [self.navigationController pushViewController:cityVc animated:YES];
}
//城市控制器的代理方法
- (void)didCityTableRowClick:(CityChooseController *)cityVc infoDict:(NSDictionary *)infoDict {
    self.sectionId = 0;
    self.brandId = 0;
    [self.cityBtn setTitle:infoDict[@"cityName"] forState:UIControlStateNormal];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.pageIndex = 1;
    [self getData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    tab.tabBarView.hidden = YES;
    
    
    NSString *cityTitle = self.cityBtn.titleLabel.text;
    
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    
    if ([city isEqualToString: cityTitle]  && city != nil) {
        [self.cityBtn setTitle:city forState:UIControlStateNormal];
    } else {
        [self.cityBtn setTitle:cityTitle forState:UIControlStateNormal];
    }
    
}

#pragma mark - talbe datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"OtherFourSCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    OtherFourSCell *foursCell = [[OtherFourSCell alloc]initWithFrame:cell.bounds];
    foursCell.dealerDict = self.contentArr[indexPath.row];
    foursCell.delegate = self;
    
    [cell.contentView addSubview:foursCell];
    
    return cell;
    
}

#pragma mark - table delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dealerDict = self.contentArr[indexPath.row];
    NSString *soldStr = dealerDict[@"BrandList"];
    NSArray *soldArr = [soldStr componentsSeparatedByString:@"、"];
    NSInteger soldNum = soldArr.count - 1;
    if (soldStr.length > 0) {
        if (soldNum <= 4 ) {
            if ([dealerDict[@"NewsID"] integerValue] != 0) {
                return 140 + 30;
            } else {
                return 110 + 30;
            }
        } else if (soldNum > 4 && soldNum <= 8) {
            if ([dealerDict[@"NewsID"] integerValue] != 0) {
                return 140 + 60;
            } else {
                return 110 + 60;
            }
            
        } else if (soldNum > 8) {
            if ([dealerDict[@"NewsID"] integerValue] != 0) {
                return 140 + 90 ;
            } else {
                return 110 + 90;
            }
        } else {
            if ([dealerDict[@"NewsID"] integerValue] != 0) {
                return 140;
            } else {
                return 110;
            }
        }
    } else {
        if ([dealerDict[@"NewsID"] integerValue] != 0) {
            return 140;
        } else {
            return 110;
        }
    }
    
    
}

- (void)activeBtnClick:(NSString *)activeUrl {
    CSActiveController *activeVc = [[CSActiveController alloc]initWithUrlString:activeUrl];
    self.activeVc = activeVc;
    [self.navigationController pushViewController:activeVc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dealerDict = self.contentArr[indexPath.row];
    
    
    if ([dealerDict[@"Latitude"] isEqual:@""] || [dealerDict[@"Longitude"]isEqual:@""]) {
        
        //进行地理编码
        [self gecode:dealerDict];
    } else {
        CSDealerDetailController *dealerDetailVc = [[CSDealerDetailController alloc]initWithDealerDict:dealerDict];
        self.dealerDetailVc = dealerDetailVc;
        [self.navigationController pushViewController:dealerDetailVc animated:YES];
    }
    
//    CSDealerDetailController *dealerDetailVc = [[CSDealerDetailController alloc]initWithDealerDict:dealerDict];
//    
//    [self.navigationController pushViewController:dealerDetailVc animated:YES];
    
}


- (void)gecode:(NSDictionary *)dealerDict {
    
    //地址
    NSString *addressString = [HTTPHelper StringDecode:dealerDict[@"companyAddress"]];
    
    [self.geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        // 地理编码完成就会自动调用
        
        // 有相关信息
        CLPlacemark *pm = [placemarks firstObject];
        // 设置经纬度信息
        CLLocationCoordinate2D coordinate = pm.location.coordinate;
        //        self.latitude = coordinate.latitude;
        //        self.longtitude = coordinate.longitude;
        
        //计算两地的距离
        CLLocation *current = [[CLLocation alloc]initWithLatitude:[self.latitude floatValue] longitude:[self.longitude floatValue]];
        CLLocation *now = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        CGFloat distance = [current distanceFromLocation:now];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dealerDict];
        
        [dict setObject:@(coordinate.latitude) forKey:@"Latitude"];
        [dict setObject:@(coordinate.longitude) forKey:@"Longitude"];
        [dict setObject:@(distance) forKey:@"Distance"];
        
        CSDealerDetailController *dealerDetailVc = [[CSDealerDetailController alloc]initWithDealerDict:dict];
        
        [self.navigationController pushViewController:dealerDetailVc animated:YES];
        
    }];
}


- (void)cTBgViewClick {
    if (self.sectionBtn.selected) {
        self.sectionBtn.selected = NO;
        [self.chooseSectionVc.tableView removeFromSuperview];
        [self.containerView removeFromSuperview];
        [self.bgView removeFromSuperview];
        self.chooseSectionVc = nil;
    }
    
    if (self.brandBtn.selected) {
        self.brandBtn.selected = NO;
        [self.chooseBrandVc.tableView removeFromSuperview];
        [self.containerView removeFromSuperview];
        [self.bgView removeFromSuperview];
        self.chooseBrandVc = nil;
    }
}

- (void)chooseSectionClick:(NSString *)sectionId {
    
    self.sectionId = [sectionId integerValue];
    
    self.sectionBtn.selected = NO;
    [self.chooseSectionVc.tableView removeFromSuperview];
    [self.containerView removeFromSuperview];
    [self.bgView removeFromSuperview];
    self.chooseSectionVc = nil;
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.pageIndex = 1;
    [self getData];
    
}

- (void)chooseBrandClick:(NSString *)brandId {
    
    self.brandId = [brandId integerValue];
    self.brandBtn.selected = NO;
    [self.chooseBrandVc.tableView removeFromSuperview];
    [self.containerView removeFromSuperview];
    [self.bgView removeFromSuperview];
    self.chooseBrandVc = nil;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.pageIndex = 1;
    [self getData];
}

//预加载
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == (self.pageIndex - 1) * self.pageSize + 8) {
        [self loadMoreStatus];
    }
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}

@end
