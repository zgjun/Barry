//
//  CarTypeController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-6.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarTypeController.h"
#import "ParameterController.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "CTContentCell.h"
#import "PriceComponentsController.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "UIImage+Extension.h"
#import "CSDealerDetailController.h"
#import "QueryLowPriceController.h"
#import "OnlyBookController.h"


#define CarTypeGap 10

#define NavHeight 64

@interface CarTypeController ()<UITableViewDataSource,UITableViewDelegate,CTContentCellDelegate>

@property (nonatomic,weak) UIImageView *headerIcon;
@property (nonatomic,weak) UILabel *carTypeLabel;
@property (nonatomic,weak) UILabel *guidePriceLabel;
@property (nonatomic,weak) UIButton *lowBtn;

@property (nonatomic,strong) NSDictionary *carTypeInfo;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) __block NSMutableArray *dealerData;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,assign) NSInteger pageNo;

@property (nonatomic,assign) NSInteger pageSize;

//经度

@property (nonatomic,strong) __block NSString *longitude;

//纬度

@property (nonatomic,strong) __block NSString *latitude;



@end

@implementation CarTypeController

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

- (instancetype)initWithCarTypeInfo:(NSDictionary *)carTypeInfo {
    if (self = [super init]) {
        self.carTypeInfo = carTypeInfo;
        
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //在显示完成后，写进历史记录
    //确定写入的路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"typeHistory.plist"];
    
    
    //先读取之前的历史记录
    NSMutableArray *historyArr = [[NSMutableArray alloc]initWithContentsOfFile:fileName];    
    
    if (historyArr.count == 0) {
        historyArr = [NSMutableArray arrayWithObject:self.carTypeInfo];
    } else {
        //去重
        for (int i = 0; i < historyArr.count; i++) {
            NSDictionary *dict = historyArr[i];
            if ([self.carTypeInfo[@"carTypeId"] isEqual:dict[@"carTypeId"]]) {
                [historyArr removeObjectAtIndex:i];
            }
        }
        [historyArr insertObject:self.carTypeInfo atIndex:0];
        
        if (historyArr.count > 50) {
            [historyArr removeLastObject];
        }
    }
    
    [historyArr writeToFile:fileName atomically:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.carTypeInfo[@"carSeriesName"];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -20;
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_home_backarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, backItem];
    
    //设置配置单按钮
    UIButton *configurationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [configurationBtn addTarget:self action:@selector(configurationBtnClick) forControlEvents:UIControlEventTouchDown];
    configurationBtn.frame = CGRectMake(0, 0, 60, 44);
    configurationBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    configurationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    configurationBtn.titleLabel.textColor = [UIColor blackColor];
    [configurationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [configurationBtn setTitle:@"配置单" forState:UIControlStateNormal];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:configurationBtn];
    
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -10;
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer1, rightBtn];
    
    self.view.backgroundColor = MainWhiteColor;
    
    [self createChildViews];
    
    self.pageNo = 1;
    
    self.pageSize = 10;
    
}


- (void)loadMoreStatus {
    
    self.pageNo = self.pageNo + 1;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    //获取车系
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo2.ashx?sortType=2&cityId=%@&longitude=%@&latitude=%@&SeriesID=%@&pageSize=%@&pageIndex=%@",self.cityId,self.longitude,self.latitude,self.carTypeInfo[@"carSeriesId"],@(self.pageSize),@(self.pageNo)];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *seriesArr = responseObject;
        
        NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.dealerData];
        
        if (seriesArr.count > 0) {
            
            for (int i = 0; i < seriesArr.count; i++) {
                NSDictionary *dict = seriesArr[i];
                
                [arrM addObject:dict];
            }
            
            self.dealerData = arrM;
            
            [self.tableView reloadData];
            
            [self.tableView footerEndRefreshing];
        } else {
            [self.tableView footerEndRefreshing];
        }
        
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self.tableView footerEndRefreshing];
        
        MyLog(@"error:%@",error);
        
    }];
}


- (void)getData {
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo2.ashx?sortType=2&cityId=%@&longitude=%@&latitude=%@&SeriesID=%@&pageSize=%@&pageIndex=%@",self.cityId,self.longitude,self.latitude,self.carTypeInfo[@"carSeriesId"],@(self.pageSize),@(self.pageNo)];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _dealerData = [NSMutableArray arrayWithArray:responseObject];
            
            [self.tableView reloadData];
        });
        
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MyLog(@"error:%@",error);
        
    }];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}


//配置单按钮
- (void)configurationBtnClick {
    
    NSDictionary *dict = @{@"carSeriesId":self.carTypeInfo[@"carSeriesId"],
                           @"carTypeId":self.carTypeInfo[@"carTypeId"],
                           @"carSeriesImg":self.carTypeInfo[@"carTypeImage"],
                           @"carSeriesName":self.carTypeInfo[@"carSeriesName"],
                           };
    ParameterController *parameterVc = [[ParameterController alloc]initWithCarTypeDict:dict];
    
    [self.navigationController pushViewController:parameterVc animated:YES];
    
}

- (void)createChildViews {
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height + NavHeight)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //表格注册单元格
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CarTypeCell"];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    
    //添加下拉加载更多
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreStatus)];
    
    //表头
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.4 * ScreenWidth)];
    headerView.backgroundColor = MainWhiteColor;
    tableView.tableHeaderView = headerView;
    UIImageView *headerIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, ScreenWidth * 0.3, ScreenWidth * 0.2)];
    [headerIcon sd_setImageWithURL:[NSURL URLWithString:self.carTypeInfo[@"carTypeImage"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    self.headerIcon = headerIcon;
    [headerView addSubview:headerIcon];
    
    UILabel *carTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(headerIcon.frame) + CarTypeGap, CarTypeGap, ScreenWidth * 0.7, 30)];
    carTypeLabel.font = [UIFont systemFontOfSize:16];
    carTypeLabel.textColor = MainBlackColor;
    carTypeLabel.text = self.carTypeInfo[@"carTypeName"];
    self.carTypeLabel = carTypeLabel;
    [headerView addSubview:carTypeLabel];
    
    UILabel *guidePriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(headerIcon.frame) + CarTypeGap, CGRectGetMaxY(carTypeLabel.frame), ScreenWidth * 0.7, 30)];
    guidePriceLabel.textColor = MainFontGrayColor;
    guidePriceLabel.font = [UIFont systemFontOfSize:14];
    
    guidePriceLabel.text = [NSString stringWithFormat:@"指导价：%.2f万元",[self.carTypeInfo[@"carTypePrice"] floatValue]];
    self.guidePriceLabel = guidePriceLabel;
    [headerView addSubview:guidePriceLabel];
    
    
    UIButton *lowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lowBtn.frame = CGRectMake(CarTypeGap,CGRectGetMaxY(headerIcon.frame) + CarTypeGap, ScreenWidth - 2 * CarTypeGap, 0.2 * ScreenWidth - 3 * CarTypeGap);
    
    if ([self.carTypeInfo[@"carTypeLowPrice"] floatValue] == 0) {
        [lowBtn setTitle:[NSString stringWithFormat:@"全国最低价：%.2f万元",[self.carTypeInfo[@"carTypePrice"] floatValue]] forState:UIControlStateNormal];
    } else {
        [lowBtn setTitle:[NSString stringWithFormat:@"全国最低价：%.2f万元",[self.carTypeInfo[@"carTypeLowPrice"] floatValue]] forState:UIControlStateNormal];
    }
    self.lowBtn = lowBtn;
    [lowBtn addTarget:self action:@selector(lowBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [lowBtn setBackgroundImage:[UIImage imageNamed:@"chexun_models_lowpricebut_bg"] forState:UIControlStateNormal];
    [lowBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_models_desablebut_navbar"] forState:UIControlStateDisabled];
    
    if ([self.carTypeInfo[@"carTypePrice"] floatValue] == 0) {
        lowBtn.enabled = NO;
    } else {
        lowBtn.enabled = YES;
    }
    [headerView addSubview:lowBtn];
    
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self getData];
    
}

- (void)lowBtnClick {
    PriceComponentsController *priceComVc = [[PriceComponentsController alloc]initWithPriceDict:self.carTypeInfo];
    
    [self.navigationController pushViewController:priceComVc animated:YES];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dealerData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CarTypeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    if (indexPath.row != 0) {
        //添加分割线
        UIView *spliteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.width, 10)];
        spliteView.backgroundColor = MainBackGroundColor;
        [cell.contentView addSubview:spliteView];
        CTContentCell *contentCell = [[CTContentCell alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(spliteView.frame), ScreenWidth, 150)];
        contentCell.delegate = self;
        contentCell.dealerDict = self.dealerData[indexPath.row];
        
        
        [cell.contentView addSubview:contentCell];
        
    } else {
        
        CTContentCell *contentCell = [[CTContentCell alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 150)];
        contentCell.delegate = self;
        contentCell.dealerDict = self.dealerData[indexPath.row];
        [cell.contentView addSubview:contentCell];
    }
    
    UIView *bottomLine = [[UIView alloc]init];
     bottomLine.backgroundColor = MainLineGrayColor;
    bottomLine.frame = CGRectMake(0, cell.height - 1,ScreenWidth, 1);
    [cell.contentView addSubview:bottomLine];
    return cell;
}

#pragma mark - tableView delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    headerView.backgroundColor = MainBackGroundColor;
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, 30)];
    headerLabel.backgroundColor = MainBackGroundColor;
    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.text = @"经销商";
    [headerView addSubview:headerLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 150;
    } else {
        return 160;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dealerDict = self.dealerData[indexPath.row];
    
    
    CSDealerDetailController *dealerDetailVc = [[CSDealerDetailController alloc]initWithDealerDict:dealerDict];
    
    [self.navigationController pushViewController:dealerDetailVc animated:YES];
}

#pragma mark - contentCell delegate
- (void)cTContentLowPriceClick:(NSDictionary *)dealerDict {
    QueryLowPriceController *queryVc = [[QueryLowPriceController alloc]initWithDealerId:dealerDict[@"dealerId"]];
    [self.navigationController pushViewController:queryVc animated:YES];
}

- (void)cTContentPhoneClick:(NSDictionary *)dealerDict {
    UIWebView*callWebview =[[UIWebView alloc] init];
    
    
    NSMutableString *tel = [NSMutableString stringWithFormat:@"%@",dealerDict[@"salePhone"]];
    
    NSRange range = [tel rangeOfString:@"或"];
    
    if (range.location > 0 && range.location < tel.length) {
        tel = (NSMutableString *)[tel substringToIndex:range.location];
    }
    
    NSString *telUrl = [NSString stringWithFormat:@"tel:%@",tel];
    
    
    NSURL *telURL =[NSURL URLWithString:telUrl];// 貌似tel:// 或者 tel: 都行
    
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    
    //记得添加到view上
    
    [self.view addSubview:callWebview];
}

- (void)cTContentTryDriveClick:(NSDictionary *)dealerDict {
    OnlyBookController *onlyBookVc = [[OnlyBookController alloc]initWithDealerId:dealerDict[@"dealerId"] dealerName:dealerDict[@"dealerShortName"]];
    [self.navigationController pushViewController:onlyBookVc animated:YES];
}
@end
