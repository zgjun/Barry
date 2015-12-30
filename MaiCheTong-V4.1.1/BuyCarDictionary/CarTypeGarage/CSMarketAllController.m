//
//  CSMarketAllController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-22.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSMarketAllController.h"
#import "AFNetworking.h"
#import "CSMarketCell.h"
#import "MBProgressHUD+GJ.h"
#import "CSMarketDetailController.h"


@interface CSMarketAllController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) NSDictionary *contentDict;

@property (nonatomic,strong)__block NSArray *marketData;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,weak) UIView *navView;

@property (nonatomic,strong) CSMarketDetailController *marketDetailVc;
@end

@implementation CSMarketAllController

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
    
    titleLabel.text = @"行情";
    
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
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
}
- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)getData {
    //异步获取数据
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarHq.do?cityId=%@&seriesId=%@",self.cityId,self.contentDict[@"seriesId"]] ;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CSMarketAllController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _marketData = responseObject;
        
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.marketData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"marketCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    NSDictionary *dict = self.marketData[indexPath.row];
    
    CSMarketCell *marketCell = [[CSMarketCell alloc]initWithLineType:1];
    marketCell.frame = cell.bounds;
    marketCell.marketDict = dict;
    [cell.contentView addSubview:marketCell];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (200 / 3);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.marketData[indexPath.row];
    CSMarketDetailController *marketDetailVc = [[CSMarketDetailController alloc]initWithContentDict:dict];
    self.marketDetailVc = marketDetailVc;
    [self.navigationController pushViewController:marketDetailVc animated:YES];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
