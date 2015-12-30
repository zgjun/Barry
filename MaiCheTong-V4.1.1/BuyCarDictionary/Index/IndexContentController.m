//
//  IndexContentController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "IndexContentController.h"
#import "IndexContentCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD+GJ.h"
#import "CarSeriesController.h"
#import "MJRefresh.h"

#define GapHeight 10
#define GapWidth (((ScreenWidth * 0.5) - CarTypeCellWidth) * 0.5)
#define CarTypeCellWidth (ScreenWidth * 0.5)
#define CarTypeCellHeight (100 + 3 * 3 + 25 + 25 * 3)

@interface IndexContentController ()<IndexContentCellDelegate>

@property (nonatomic,strong) __block NSMutableArray *contentData;

@property (nonatomic,assign) CGFloat upDistance;

@property (nonatomic,strong) NSString *cityId;


@property (nonatomic,assign) NSInteger pageNo;

@property (nonatomic,assign) NSInteger pageSize;

@property (nonatomic,assign) NSInteger carLevel;

@property (nonatomic,strong) CarSeriesController *carSeriesVc;

@property (nonatomic,weak) UIView *superView;

@end

@implementation IndexContentController

- (instancetype)initWithCarLevel:(NSInteger)carLevel SuperView:(UIView *)superView{
    if (self = [super init]) {
        self.carLevel = carLevel;
        self.superView = superView;
    }
    return self;
}

- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self pullRefresh];
    [self pushRefresh];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    //初始化相关数据
    self.pageSize = 24;
    self.pageNo = 1;
}

//添加下拉刷新
- (void)pullRefresh {
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    [self.tableView addGifHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 隐藏时间
//    self.tableView.header.updatedTimeHidden = YES;
//    
//    // 隐藏状态
//    self.tableView.header.stateHidden = YES;
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=5; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"shuaxin%zd", i]];
        [idleImages addObject:image];
    }
    [self.tableView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
    
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=5; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"shuaxin%zd", i]];
        [refreshingImages addObject:image];
    }
    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
    
    
    
}
//添加上拉加载更多
- (void)pushRefresh {
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
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

- (void)loadNewData {
    self.pageNo = 1;
    
    [self getData:self.carLevel];
    
}

- (void)loadMoreData {
    self.pageNo = self.pageNo + 1;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak IndexContentController *myself = self;
    
    if (self.carLevel == 0) {
        NSString *carSeriesUrl = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarGetHqNews.do?pageNo=%@&pageSize=%@&cityId=%@",@(self.pageNo),@(self.pageSize),self.cityId];
        [manager GET:carSeriesUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSArray *seriesArr = responseObject;
            
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:_contentData];
            
            if (seriesArr.count > 0) {
                
                for (int i = 0; i < seriesArr.count; i++) {
                    NSDictionary *dict = seriesArr[i];
                    
                    [arrM addObject:dict];
                }
                
                _contentData = arrM;
                
                [myself.tableView reloadData];
                
                [myself.tableView.gifFooter endRefreshing];
                
            } else {
                [myself.tableView.gifFooter endRefreshing];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [myself.tableView.gifFooter endRefreshing];
            return;
        }];
    } else {
        //获取热门车系
        NSString *carSeriesUrl = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesInfo.do?pageNo=%@&pageSize=%@&carLevel=%@&cityId=%@",@(self.pageNo),@(self.pageSize),@(self.carLevel),self.cityId];
        
        [manager GET:carSeriesUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *seriesArr = responseObject[@"seriesList"];
            
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:_contentData];
            
            if (seriesArr.count > 0) {
                
                for (int i = 0; i < seriesArr.count; i++) {
                    NSDictionary *dict = seriesArr[i];
                    
                    [arrM addObject:dict];
                }
                
                _contentData = arrM;
                
                [myself.tableView reloadData];
                
                [myself.tableView.gifFooter endRefreshing];
                
            } else {
                [myself.tableView.gifFooter endRefreshing];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [myself.tableView.gifFooter endRefreshing];
            return;
        }];
    }
}



- (void)loadDataWithLevel:(NSInteger)carLevel {
    
    self.carLevel = carLevel;
    
    self.pageNo = 1;
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self getData:carLevel];
    
    
}

- (void)getData:(NSInteger)carLevel {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
   __weak IndexContentController *myself = self;
    if (carLevel == 0) {
        NSString *carSeriesUrl = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarGetHqNews.do?pageNo=%@&pageSize=%@&cityId=%@",@(self.pageNo),@(self.pageSize),self.cityId];
        [manager GET:carSeriesUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            _contentData = [NSMutableArray arrayWithArray:responseObject];
            [myself.tableView reloadData];
            
            [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
            [myself.tableView.gifHeader endRefreshing];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
            [MBProgressHUD showError:@"数据加载异常"];
            [myself.tableView.gifHeader endRefreshing];
            return;
        }];
    } else {
        //获取热门车系
        NSString *carSeriesUrl = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesInfo.do?pageNo=%@&pageSize=%@&carLevel=%@&cityId=%@",@(myself.pageNo),@(myself.pageSize),@(myself.carLevel),myself.cityId];
        
        [manager GET:carSeriesUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            _contentData = [NSMutableArray arrayWithArray:responseObject[@"seriesList"]];
            [myself.tableView reloadData];
            [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
            [myself.tableView.gifHeader endRefreshing];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
            [MBProgressHUD showError:@"数据加载异常"];
            [myself.tableView.gifHeader endRefreshing];
            return;
        }];
    }
    
}


#pragma mark - table datasource
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
    static NSString *TabID = @"tableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TabID];
    
    IndexContentCell *leftCellView;
    IndexContentCell *rightCellView;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        leftCellView = [[IndexContentCell alloc]initWithFrame:CGRectMake(GapWidth, 0, CarTypeCellWidth, CarTypeCellHeight)];
        leftCellView.delegate = self;
        [cell.contentView addSubview:leftCellView];
        
        rightCellView = [[IndexContentCell alloc]initWithFrame:CGRectMake((ScreenWidth * 0.5 + GapWidth), 0, CarTypeCellWidth, CarTypeCellHeight)];
        rightCellView.delegate = self;
        
        [cell.contentView addSubview:rightCellView];
    } else {
        NSInteger subviewsCount = cell.contentView.subviews.count;
        if (subviewsCount > 1) {
            leftCellView = cell.contentView.subviews[0];
            
            rightCellView = cell.contentView.subviews[1];
        } else {
            leftCellView = cell.contentView.subviews[0];
            
            rightCellView = [[IndexContentCell alloc]initWithFrame:CGRectMake((ScreenWidth * 0.5 + GapWidth), 0, CarTypeCellWidth, CarTypeCellHeight)];
            rightCellView.delegate = self;
            [cell.contentView addSubview:rightCellView];
        }
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
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CarTypeCellHeight;
    
}


#pragma mark - table delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView

{
    
    self.upDistance = scrollView.contentOffset.y;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([self.mydelegate respondsToSelector:@selector(indexContentScroll:isup:)]) {
        
        if (scrollView.contentOffset.y - self.upDistance > 0) {
            [self.mydelegate indexContentScroll:self isup:YES];
        } else if (scrollView.contentOffset.y - self.upDistance <= 0) {
            [self.mydelegate indexContentScroll:self isup:NO];
        }
    }
}

#pragma mark - indexcontentcell delegate
- (void)carTypeCellViewClick:(IndexContentCell *)carTypeCellView {
    if (carTypeCellView.dataDict == nil) {
        return;
    }
    NSString *brandLogo = carTypeCellView.dataDict[@"brandLogo"] != NULL ? carTypeCellView.dataDict[@"brandLogo"] : carTypeCellView.dataDict[@"brandImagePath"];
    NSString *brandName = carTypeCellView.dataDict[@"brandName"] != NULL ? carTypeCellView.dataDict[@"brandName"] : @"未知";
    NSString *english = carTypeCellView.dataDict[@"english"] != NULL ? carTypeCellView.dataDict[@"english"] : @"weizhi";
    NSString *hqurl = carTypeCellView.dataDict[@"hqurl"] != NULL ? carTypeCellView.dataDict[@"hqurl"] : carTypeCellView.dataDict[@"url"];
    NSString *carSeriesId = carTypeCellView.dataDict[@"id"] != NULL ? carTypeCellView.dataDict[@"id"] : carTypeCellView.dataDict[@"seriesId"];
    NSString *imgPath = carTypeCellView.dataDict[@"imgPath"] != NULL ? carTypeCellView.dataDict[@"imgPath"] : carTypeCellView.dataDict[@"imagePath"];
    NSString *name = carTypeCellView.dataDict[@"name"] != NULL ? carTypeCellView.dataDict[@"name"] : carTypeCellView.dataDict[@"seriesName"];
    
    NSDictionary *dataDict = @{@"brandId":carTypeCellView.dataDict[@"brandId"],
                               @"brandLogo":brandLogo,
                               @"brandName":brandName,
                                @"english":english,
                               @"guidePrice":carTypeCellView.dataDict[@"guidePrice"],
                                @"hq":carTypeCellView.dataDict[@"hq"],
                                @"hqurl":hqurl,
                                @"id":carSeriesId,
                                @"imgPath":imgPath,
                                @"name":name
                                };
    
    CarSeriesController *carSeriesVc = [[CarSeriesController alloc]initWithSeriesDict:dataDict];
    self.carSeriesVc = carSeriesVc;
    [self.navigationController pushViewController:carSeriesVc animated:YES];
}

//预加载
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == (self.pageNo - 1) * 10 + 8) {
        [self loadMoreData];
    }
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
