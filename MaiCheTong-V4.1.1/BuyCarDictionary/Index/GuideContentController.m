//
//  GuideContentController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-17.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "GuideContentController.h"
#import "GuideContentCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD+GJ.h"
#import "MJRefresh.h"
#import "GuideDetailController.h"
#define TabBarHeight 49

@interface GuideContentController ()

@property (nonatomic,assign) CGFloat upDistance;

@property (nonatomic,assign) NSInteger type;

@property (nonatomic,assign) NSInteger pageNo;

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,strong) GuideDetailController *guideDetailVc;

///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;
@end

@implementation GuideContentController

- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.showsVerticalScrollIndicator = YES;
    
    self.tableView.backgroundColor = MainBackGroundColor;
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self pushRefresh];
    
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
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarGetGuideNews.do?&pageNo=%@&pageSize=%@&type=%@",@(self.pageNo),@20,@(self.type)];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak GuideContentController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *contentData = responseObject;
        NSMutableArray *arrM = [NSMutableArray arrayWithArray:myself.contentArr];
        
        if (contentData.count > 0) {
            
            for (int i = 0; i < contentData.count; i++) {
                NSDictionary *dict = contentData[i];
                
                [arrM addObject:dict];
            }
            
            myself.contentArr = arrM;
            
            [myself.tableView reloadData];
            [myself.tableView.gifFooter endRefreshing];
            
        } else {
            [myself.tableView.gifFooter endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [myself.tableView.gifFooter endRefreshing];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
    
}


- (void)loadDataWithType:(NSInteger)type {
    
    self.type = type;
    
    self.pageNo = 1;
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData:type];
    
    
}

- (void)getData:(NSInteger)type {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarGetGuideNews.do?&pageNo=%@&pageSize=%@&type=%@",@(self.pageNo),@20,@(type)];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    __weak GuideContentController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        myself.contentArr = [NSMutableArray arrayWithArray:responseObject];
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
}

#pragma mark - UITableView数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    GuideContentCell *rpView;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]init];
        rpView = [[GuideContentCell alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
        
        [cell.contentView addSubview:rpView];
    } else {
        rpView = cell.contentView.subviews[0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    rpView.contentDict = self.contentArr[indexPath.section];
    
    return cell;
}

#pragma mark - UITableView代理方法

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.contentArr[indexPath.section];
    
    GuideDetailController *guideDetailVc = [[GuideDetailController alloc]initWithContentDict:dict];
    self.guideDetailVc = guideDetailVc;
    [self.navigationController pushViewController:guideDetailVc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == (self.pageNo - 1) * 20 + 15) {
        [self loadMoreStatus];
    }
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
