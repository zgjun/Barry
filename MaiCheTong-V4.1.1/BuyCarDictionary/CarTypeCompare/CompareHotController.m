//
//  CompareHotController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-25.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CompareHotController.h"
#import "CarTypeCellView.h"
#import "AFNetworking.h"
#import "CTNavBarView.h"
#import "CarNavButton.h"
#import "CompareCarTypeController.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#define GapWidth (((ScreenWidth * 0.5) - CarTypeCellWidth) * 0.5)

#define CarTypeCellWidth 130
#define CarTypeCellHeight 135
#define CTNavBarViewHeight 44

@interface CompareHotController ()<UITableViewDataSource,UITableViewDelegate,RPNavBarViewDelegate,CarTypeCellViewDelegate>
@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) __block NSArray *contentData;
@property (nonatomic,strong) NSDictionary *navBarInfoDict;
@property (nonatomic,strong) NSArray *navHeads;


@property (nonatomic,strong) NSString *cityId;


@property (nonatomic,assign) NSInteger pageNo;

@property (nonatomic,assign) NSInteger pageSize;

@property (nonatomic,assign) NSInteger carLevel;


///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,assign) NSInteger remberTag;

@property (nonatomic,assign) CGFloat rembersliderX;

@end

@implementation CompareHotController

- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.view.backgroundColor = MainWhiteColor;
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
    
    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CompareHotCell"];
    
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreStatus)];
    
    
    //初始化相关数据
    self.pageSize = 8;
    self.pageNo = 1;
    //紧凑车型：2
    self.carLevel = 2;
    
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.tableView];
    
    [self.tableView addSubview:self.HUD];
    
    [self.HUD showWhileExecuting:@selector(getData) onTarget:self withObject:nil animated:YES];
}

- (void)loadMoreStatus {
    self.pageNo = self.pageNo + 1;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //获取车系
    NSString *carSeriesUrl = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesInfo.do?pageNo=%@&pageSize=%@&carLevel=%@&cityId=%@",@(self.pageNo),@(self.pageSize),@(self.carLevel),self.cityId];
    
    __weak CompareHotController *mylelf = self;
    [manager GET:carSeriesUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *seriesArr = responseObject[@"seriesList"];
        
        
        NSMutableArray *arrM = [NSMutableArray arrayWithArray:mylelf.contentData];
        
        if (seriesArr.count > 0) {
            
            for (int i = 0; i < seriesArr.count; i++) {
                NSDictionary *dict = seriesArr[i];
                
                [arrM addObject:dict];
            }
            
            mylelf.contentData = arrM;
            [mylelf.tableView reloadData];
            [mylelf.tableView footerEndRefreshing];
            
        } else {
            [mylelf.tableView footerEndRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [mylelf.tableView footerEndRefreshing];
    }];
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //获取车系
    NSString *carSeriesUrl = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesInfo.do?pageNo=%@&pageSize=%@&carLevel=%@&cityId=%@",@(self.pageNo),@(self.pageSize),@(self.carLevel),self.cityId];
    
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CompareHotController *mylelf = self;
    
    [manager GET:carSeriesUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _contentData = responseObject[@"seriesList"];
        
        
        //获取tabNav头
        NSString *headUrl = @"http://api.tool.chexun.com/mobile/buyCarCartypeInfo.do";
        [manager GET:headUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            _navHeads = responseObject;
            
            [mylelf.tableView reloadData];
            
            [mylelf hudWasHidden:mylelf.HUD];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            MyLog(@"error:%@",error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MyLog(@"error:%@",error);
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
    if (self.contentData.count % 2 == 0) {
        return (self.contentData.count * 0.5);
    } else {
        return (self.contentData.count * 0.5) + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CompareHotCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (CarTypeCellView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    CarTypeCellView *leftCellView = [[CarTypeCellView alloc]initWithFrame:CGRectMake(GapWidth, 0, CarTypeCellWidth, CarTypeCellHeight)];
    leftCellView.delegate = self;
    
    CarTypeCellView *rightCellView = [[CarTypeCellView alloc]initWithFrame:CGRectMake((cell.width * 0.5 + GapWidth), 0, CarTypeCellWidth, CarTypeCellHeight)];
    rightCellView.delegate = self;
    
    if (self.contentData.count % 2 != 0 && indexPath.row  == self.contentData.count * 0.5 + 1) {
        [rightCellView removeFromSuperview];
    }
    
    
    NSInteger numCount = self.contentData.count;
    
    NSArray *resultArr = self.contentData;
    
    
    if (indexPath.row == 0) {
        NSDictionary *dict0 = resultArr[indexPath.row];
        leftCellView.dataDict = dict0;
        if (indexPath.row + 1 < numCount) {
            NSDictionary *dict1 = resultArr[indexPath.row + 1];
            rightCellView.dataDict = dict1;
        }
        
    } else {
        NSDictionary *dictN = resultArr[indexPath.row * 2];
        leftCellView.dataDict = dictN;
        if ((indexPath.row * 2 + 1) < numCount) {
            NSDictionary *dictN1 = resultArr[indexPath.row * 2 + 1];
            rightCellView.dataDict = dictN1;
        }
    }
    
    
    [cell.contentView addSubview:leftCellView];
    
    [cell.contentView addSubview:rightCellView];
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CTNavBarViewHeight;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CarTypeCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CTNavBarView *cTNavBarView = [[CTNavBarView alloc]initWithRemberTag:self.remberTag RemberSliderX:self.rembersliderX];
    cTNavBarView.delegate = self;
    
    cTNavBarView.navTittles = self.navHeads;
    return cTNavBarView;
}


- (void)cTNavBtnClick:(CTNavBarView *)cTNavBarView NavBtn:(CarNavButton *)carNavBtn RemberSliderX:(CGFloat)remberSliderX{
    
    self.remberTag = carNavBtn.tag;
    
    self.rembersliderX = remberSliderX;
    
    self.carLevel = [carNavBtn.contentDict[@"levelId"] integerValue];
    
    self.navBarInfoDict = carNavBtn.contentDict;
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    
    [self loadNewData];
    
    
}

- (void)loadNewData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *carSeriesUrl = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesInfo.do?pageNo=%@&pageSize=%@&carLevel=%@&cityId=%@",@(self.pageNo),@(self.pageSize),@(self.carLevel),self.cityId];
    
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CompareHotController *mylelf = self;
    
    [manager GET:carSeriesUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _contentData = responseObject[@"seriesList"];
        
        [mylelf.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:mylelf.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MyLog(@"error:%@",error);
    }];
}


#pragma mark - CarTypeCellView 代理方法
- (void)carTypeCellViewClick:(CarTypeCellView *)carTypeCellView {
    
    NSDictionary *seriesDict = @{@"seriesId":carTypeCellView.dataDict[@"id"],@"name":carTypeCellView.dataDict[@"name"]};
    
    CompareCarTypeController *compareCarTypeVc = [[CompareCarTypeController alloc]initWithSeriesDict:seriesDict];
    
    [self.navigationController pushViewController:compareCarTypeVc animated:YES];
    
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}




@end
