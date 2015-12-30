//
//  ScreeningResultController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-24.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "ScreeningResultController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "ScreeningResultCell.h"
#import "CarSeriesController.h"
#import "MBProgressHUD+GJ.h"
#import "MJRefresh.h"

#import "MainTabBarController.h"

#define ScreenIconHeight 70
#define ScreenIconWidth 100
#define GapHeight 10
#define GapWidth 15

@interface ScreeningResultController ()<ScreeningResultCellDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSString  *parameter;

@property (nonatomic,strong) __block NSMutableArray *data;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,assign) NSInteger pageNo;

@end

@implementation ScreeningResultController

- (instancetype)initWithCondition:(NSDictionary *)conditionDict {
    if (self = [super init]) {
        NSMutableString *parameter = [NSMutableString string];
        NSString *actionType = @"2";
        [parameter appendFormat:@"actionType=%@",actionType];
        
        if (![conditionDict[@"type"] isEqual:@"-1"]) {
            [parameter appendFormat:@"&levelId=%@",conditionDict[@"type"]];
        }
        if (![conditionDict[@"price"] isEqual:@"-1"]) {
            [parameter appendFormat:@"&priceId=%@",conditionDict[@"price"]];
        }
        if (![conditionDict[@"output"] isEqual:@"-1"]) {
            [parameter appendFormat:@"&displacementId=%@",conditionDict[@"output"]];
        }
        if (![conditionDict[@"changespeed"] isEqual:@"-1"]) {
            [parameter appendFormat:@"&speedBoxId=%@",conditionDict[@"changespeed"]];
        }
        if (![conditionDict[@"attribute"] isEqual:@"-1"]) {
            [parameter appendFormat:@"&companyTypeId=%@",conditionDict[@"attribute"]];
        }
        self.parameter = parameter;
    }
    return self;
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



- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"筛选结果";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    
    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ScreeningResultCell"];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tabBarController.tabBar.hidden = YES;
    
    [self pushRefresh];
    
    self.pageNo = 1;
    
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self carTypeWithParameter:self.parameter];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;

    
    
}

- (void)loadMoreStatus {
    self.pageNo = self.pageNo + 1;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //获取车系
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesListByCondition.do?%@&pageNo=%@",self.parameter,@(self.pageNo)];
    
    __weak ScreeningResultController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *seriesArr = responseObject[@"seriesList"];
        
        
        NSMutableArray *arrM = [NSMutableArray arrayWithArray:myself.data];
        
        if (seriesArr.count > 0) {
            
            for (int i = 0; i < seriesArr.count; i++) {
                NSDictionary *dict = seriesArr[i];
                
                [arrM addObject:dict];
            }
            
            myself.data = arrM;
            [myself.tableView.gifFooter endRefreshing];
            [myself.tableView reloadData];
            
            
        } else {
            [myself.tableView.gifFooter endRefreshing];
        }
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [myself.tableView.gifFooter endRefreshing];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)carTypeWithParameter:(NSString *)parameter {
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesListByCondition.do?%@",parameter];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak ScreeningResultController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *carList = responseObject;
        
        myself.data = [NSMutableArray arrayWithArray:carList[@"seriesList"]];
        
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }];
    
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"ScreeningResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    NSDictionary *dict = self.data[indexPath.row];
    
    ScreeningResultCell *resultCell = [[ScreeningResultCell alloc]initWithFrame:cell.bounds];
    resultCell.delegate = self;
    resultCell.screeningResultDict = dict;
    [cell.contentView addSubview:resultCell];
    
    //添加子视图
    UIImageView *screeningIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenIconWidth, ScreenIconHeight)];
    [screeningIcon sd_setImageWithURL:[NSURL URLWithString:dict[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    [resultCell addSubview:screeningIcon];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(screeningIcon.frame) + GapWidth, GapHeight, 150, ScreenIconHeight * 0.4 - GapHeight)];
    nameLabel.text = dict[@"name"];
    nameLabel.textColor = MainBlackColor;
    nameLabel.font = [UIFont systemFontOfSize:16];
    [resultCell addSubview:nameLabel];
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(screeningIcon.frame) + GapWidth, ScreenIconHeight * 0.4 + GapHeight, 110, ScreenIconHeight * 0.4 - GapHeight)];
    priceLabel.textColor = MainBlackColor;
    priceLabel.font = [UIFont systemFontOfSize:12];
    priceLabel.text = dict[@"guidePrice"];
    [resultCell addSubview:priceLabel];
    
    if ([dict[@"hq"] floatValue] != 0) {
        
        //降价view
        UIView *reducePriceView = [[UIView alloc]init];
        reducePriceView.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame), ScreenIconHeight * 0.4 + GapHeight, 80 , 20);
        [resultCell addSubview:reducePriceView];
        
        UIImageView *arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_sale"]];
        arrowImage.frame = CGRectMake(0, 0, 20 , 20);
        arrowImage.contentMode = UIViewContentModeCenter;
        
        [reducePriceView addSubview:arrowImage];
        UILabel *reducePriceLabel = [[UILabel alloc]init];
        reducePriceLabel.frame = CGRectMake(20, 0, 70 , 20);
        reducePriceLabel.font = [UIFont systemFontOfSize:12];
        reducePriceLabel.textColor = MainFontRedColor;
        reducePriceLabel.text = dict[@"hq"];
        [reducePriceView addSubview:reducePriceLabel];
    }
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, cell.height - 1, ScreenWidth, 1)];
    bottomLine.backgroundColor = MainBackGroundColor;
    [resultCell addSubview:bottomLine];
    
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return ScreenIconHeight;
}

- (void)screeningResultCellClick:(ScreeningResultCell *)resultCell {
    CGFloat hq = 0;
    if (!resultCell.screeningResultDict[@"hq"]) {
        hq = [resultCell.screeningResultDict[@"hq"] floatValue];
    }
    NSDictionary *carSeriesDict = @{@"id":resultCell.screeningResultDict[@"id"],
                                    @"hq":@(hq),
                                    @"imgPath":resultCell.screeningResultDict[@"imagePath"],
                                    @"hqurl":resultCell.screeningResultDict[@"hqurl"],
                                    @"english":resultCell.screeningResultDict[@"english"],
                                    @"guidePrice":resultCell.screeningResultDict[@"guidePrice"],
                                    @"name":resultCell.screeningResultDict[@"name"],
                                    @"active":resultCell.screeningResultDict[@"active"],
                                    };
    
    CarSeriesController *carSeriesVc = [[CarSeriesController alloc]initWithSeriesDict:carSeriesDict];
    [self.navigationController pushViewController:carSeriesVc animated:YES];
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}


@end
