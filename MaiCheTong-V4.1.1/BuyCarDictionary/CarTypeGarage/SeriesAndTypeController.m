//
//  CarSeriesChooseController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "SeriesAndTypeController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"


@interface SeriesAndTypeController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSString *dealerId;

@property (nonatomic,strong) NSString *carSeriesId;
@property (nonatomic,strong) NSString *priceType;

@property (nonatomic,strong) NSArray *contentArr;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) NSString *headName;

@end

@implementation SeriesAndTypeController

- (instancetype)initWithDealerId:(NSString *)dealerId {
    if (self = [super init]) {
        self.dealerId = dealerId;
    }
    return self;
}

- (instancetype)initWithDealerId:(NSString *)dealerId carSeriesId:(NSString *)carSeriesId priceType:(NSString *)priceType {
    if (self = [super init]) {
        self.dealerId = dealerId;
        self.carSeriesId = carSeriesId;
        self.priceType = priceType;
    }
    return self;
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
    
    
    
//    if (self.carSeriesId) {
//        self.navigationItem.title = @"车型选择";
//    } else {
//        self.navigationItem.title = @"车系选择";
//    }
    
    
    self.view.backgroundColor = MainBackGroundColor;
    
    /*
    
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
     */
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
    
    
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.showsVerticalScrollIndicator = NO;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"SeriesAndTypeCell"];
    [self.view addSubview:tableView];
    
    //初始相关数据
    if (self.carSeriesId) {
        self.headName = @"车型";
        titleLabel.text = @"车型选择";
    } else {
        self.headName = @"车系";
        titleLabel.text = @"车系选择";
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self getData];
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr;
    
    
    if (self.carSeriesId) {
        urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/Api/GetModelByDealersIDAndSeriesIDHandler.ashx?DealersID=%@&SeriesID=%@",self.dealerId,self.carSeriesId];
        
    } else {
        urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealerDownSeriesInfo.ashx?dealerId=%@",self.dealerId];
    }
    
    __weak SeriesAndTypeController *myself = self;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        myself.contentArr = responseObject;
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        MyLog(@"%@",error);
        
    }];
}
- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"SeriesAndTypeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    NSDictionary *dict = self.contentArr[indexPath.row];
    if ([self.priceType isEqualToString:@"hasPrice"]) {
        UILabel * carTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, ScreenWidth - 20, 40)];
        NSString *modelName = dict[@"modelName"];
        NSString *yearName = dict[@"yearName"];
        carTypeLabel.text = [NSString stringWithFormat:@"%@ %@",yearName,modelName];
        carTypeLabel.textAlignment = NSTextAlignmentLeft;
        carTypeLabel.font = [UIFont systemFontOfSize:16];
        carTypeLabel.textColor = MainFontGrayColor;
        [cell.contentView addSubview:carTypeLabel];
        
        UILabel *carPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(carTypeLabel.frame), ScreenWidth - 20, 20)];
        carPriceLabel.text = [NSString stringWithFormat:@"%.2f万",[dict[@"guidePrice"] floatValue]];
        carPriceLabel.textAlignment = NSTextAlignmentLeft;
        carPriceLabel.font = [UIFont systemFontOfSize:14];
        carPriceLabel.textColor = MainFontGrayColor;
        [cell.contentView addSubview:carPriceLabel];
    } else if ([self.priceType isEqualToString:@"noPrice"]) {
        UILabel * carTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, ScreenWidth - 20, 40)];
        NSString *modelName = dict[@"modelName"];
        NSString *yearName = dict[@"yearName"];
        carTypeLabel.text = [NSString stringWithFormat:@"%@ %@",yearName,modelName];
        carTypeLabel.textAlignment = NSTextAlignmentLeft;
        carTypeLabel.font = [UIFont systemFontOfSize:16];
        carTypeLabel.textColor = MainFontGrayColor;
        [cell.contentView addSubview:carTypeLabel];
    } else {
        UILabel * carSeriesLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, ScreenWidth - 20, 40)];
        carSeriesLabel.text = dict[@"seriesName"];
        carSeriesLabel.textAlignment = NSTextAlignmentLeft;
        carSeriesLabel.font = [UIFont systemFontOfSize:16];
        carSeriesLabel.textColor = MainFontGrayColor;
        [cell.contentView addSubview:carSeriesLabel];
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.priceType isEqualToString:@"hasPrice"]) {
        return 60;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *secHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    secHeadView.backgroundColor = MainBackGroundColor;
    
    UILabel *secHeadLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, 30)];
    [secHeadView addSubview:secHeadLabel];
    
    secHeadLabel.text = self.headName;
    
    return secHeadView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = self.contentArr[indexPath.row];
    
    
    if ([self.delegate respondsToSelector:@selector(seriesAndTypeSelected:)]) {
        [self.delegate seriesAndTypeSelected:dict];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}


@end
