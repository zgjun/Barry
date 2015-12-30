//
//  CSMarkeyController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSMarketController.h"
#import "AFNetworking.h"
#import "CSMarketCell.h"
#import "MBProgressHUD+GJ.h"
#import "CSMarketDetailController.h"

@interface CSMarketController ()
@property (nonatomic,strong) NSDictionary *contentDict;

@property (nonatomic,strong)__block NSArray *marketData;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,strong) CSMarketDetailController *marketDetailVc;
@end

@implementation CSMarketController

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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"marketCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getData];
}

- (void)getData {
    //异步获取数据
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarHq.do?cityId=%@&seriesId=%@",self.cityId,self.contentDict[@"seriesId"]] ;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CSMarketController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _marketData = responseObject;
        
        
        if (_marketData.count == 0) {
            myself.marketBlock(1);
        }
        
        
        [myself.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    if (self.marketData.count >= 3) {
        return 3;
    } else {
        return self.marketData.count;
    }
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
    
    CSMarketCell *marketCell = [[CSMarketCell alloc]initWithLineType:0];
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
