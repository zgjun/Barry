//
//  CSDealerController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-5.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSDealerController.h"
#import "CSDealerCell.h"
#import "CSActiveController.h"
#import "CSDealerDetailController.h"
#import "HTTPHelper.h"
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"
#import "MBProgressHUD+GJ.h"
#import "MJRefresh.h"

@interface CSDealerController ()<CSDealerCellDelegate>

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

@property (nonatomic,strong) CSDealerDetailController *dealerDetailVc;

@property (nonatomic,strong) CSActiveController *activeVc;
@end

@implementation CSDealerController

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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DealerCell"];
    
    
    self.pageNo = 1;
    
    [self getData];
}

- (void)loadMoreStatus {
    self.pageNo = self.pageNo + 1;
    //异步获取数据
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo3.ashx?sortType=2&cityId=%@&SeriesID=%@&pageSize=50&longitude=%@&latitude=%@&pageIndex=%@",self.cityId,self.contentDict[@"seriesId"],self.longitude,self.latitude,@(self.pageNo)];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    __weak CSDealerController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *arr = responseObject[@"dealerList"];
        
        for (int i = 0; i < arr.count; i++) {
            NSDictionary *dict = arr[i];
            [myself.dealerData addObject:dict[@"imagePath"]];
            
        }
        [myself.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }];
}

- (void)getData {
    //异步获取数据
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo3.ashx?sortType=2&cityId=%@&SeriesID=%@&pageSize=50&longitude=%@&latitude=%@&pageIndex=%@",self.cityId,self.contentDict[@"seriesId"],self.longitude,self.latitude,@(self.pageNo)];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    __weak CSDealerController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _dealerData = responseObject[@"dealerList"];
        
        
        if (_dealerData.count == 0) {
            myself.dealerBlock(1);
        }
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView   animated:YES];
        
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
    if (self.dealerData.count >= 2) {
        return 2;
    } else {
        
        return self.dealerData.count;
    }
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
    CSDealerCell *dealerCell = [[CSDealerCell alloc]initWithLineType:0];
    dealerCell.delegate = self;
    dealerCell.frame = cell.bounds;
    dealerCell.dealerDict = dealerDict;
    [cell.contentView addSubview:dealerCell];
    
    return cell;
    
}

#pragma mark - tableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
