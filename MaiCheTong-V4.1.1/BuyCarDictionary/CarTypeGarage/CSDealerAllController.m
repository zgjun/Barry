//
//  CSDealerAllController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-22.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSDealerAllController.h"
#import "CSDealerCell.h"
#import "CSActiveController.h"
#import "CSDealerDetailController.h"
#import "HTTPHelper.h"
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"
#import "MBProgressHUD+GJ.h"
#import "MJRefresh.h"


@interface CSDealerAllController ()<CSDealerCellDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSDictionary *contentDict;

@property (nonatomic,strong)__block NSMutableArray *dealerData;

///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) NSString *cityId;

//经度
@property (nonatomic,strong) __block NSString *longitude;
//纬度
@property (nonatomic,strong) __block NSString *latitude;

//地理编码
@property(nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic,assign) NSInteger pageNo;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,weak) UIView *navView;

@property (nonatomic,strong) CSDealerDetailController *dealerDetailVc;

@property (nonatomic,strong) CSActiveController *activeVc;

@end

@implementation CSDealerAllController

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
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

- (instancetype)initWithContentDict:(NSDictionary *)contentDict {
    if (self = [super init]) {
        self.contentDict = contentDict;
    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //导航视图
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    self.navView = navView;
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
    
    titleLabel.text = @"经销商";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    //添加表格
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navView.frame), ScreenWidth, ScreenHeight - 64)];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    //注册单元格
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"marketCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:tableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DealerCell"];
    
    
    //添加上拉加载更多
    [self pushRefresh];
    
    self.pageNo = 1;
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
}
- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
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
    self.pageNo = self.pageNo + 1;
    //异步获取数据
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo3.ashx?sortType=2&cityId=%@&SeriesID=%@&pageSize=20&longitude=%@&latitude=%@&pageIndex=%@",self.cityId,self.contentDict[@"seriesId"],self.longitude,self.latitude,@(self.pageNo)];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    __weak CSDealerAllController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *arr = responseObject[@"dealerList"];
        
        if (arr.count > 0) {
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dict = arr[i];
                [myself.dealerData addObject:dict];
                
            }
            [myself.tableView reloadData];
            [myself.tableView.gifFooter endRefreshing];
            
        } else {
            [myself.tableView.gifFooter endRefreshing];
        }
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself.tableView.gifFooter endRefreshing];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }];
}

- (void)getData {
    //异步获取数据
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo3.ashx?sortType=2&cityId=%@&SeriesID=%@&pageSize=20&longitude=%@&latitude=%@&pageIndex=%@",self.cityId,self.contentDict[@"seriesId"],self.longitude,self.latitude,@(self.pageNo)];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    __weak CSDealerAllController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _dealerData = [NSMutableArray arrayWithArray:responseObject[@"dealerList"]];
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }];
}
- (void)hudWasHidden:(MBProgressHUD *)hud {
    
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dealerData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"DealerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    NSDictionary *dealerDict = self.dealerData[indexPath.row];
    
    //添加子控件
    CSDealerCell *dealerCell = [[CSDealerCell alloc]initWithLineType:1];
    dealerCell.delegate = self;
    dealerCell.frame = cell.bounds;
    dealerCell.dealerDict = dealerDict;
    [cell.contentView addSubview:dealerCell];
    
    return cell;
    
}

#pragma mark - tableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSDictionary *dealerDict = self.dealerData[indexPath.row];
    //    if ([dealerDict[@"NewsID"] integerValue] != 0) {
    //        return 150;
    //    } else {
    //        return 110;
    //    }
    return 100;
    
}

- (void)activeBtnClick:(NSString *)activeUrl {
    CSActiveController *activeVc = [[CSActiveController alloc]initWithUrlString:activeUrl];
    self.activeVc = activeVc;
    [self.navigationController pushViewController:activeVc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dealerDict = self.dealerData[indexPath.row];
    
    
    
    if ([dealerDict[@"Latitude"] isEqual:@""] || [dealerDict[@"Longitude"]isEqual:@""]) {
        
        //进行地理编码
        [self gecode:dealerDict];
    } else {
        CSDealerDetailController *dealerDetailVc = [[CSDealerDetailController alloc]initWithDealerDict:dealerDict];
        self.dealerDetailVc = dealerDetailVc;
        [self.navigationController pushViewController:dealerDetailVc animated:YES];
    }
    
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

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
