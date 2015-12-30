//
//  CSCarTypeController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-5.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSCarTypeController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "CSNavBarView.h"
#import "CSContentCell.h"
#import "CarTypeController.h"
#import "CSHeaderImageView.h"
#import "CSImageShowController.h"
#import "MBProgressHUD+GJ.h"

#define CSNavBarViewHeight 44

@interface CSCarTypeController ()<CSNavBarViewDelegate,CSContentCellDelegate,CSHeaderImageViewDelegate>

@property (nonatomic,weak) UILabel *carTypeLabel;

@property (nonatomic,weak) UILabel *priceLabel;

@property (nonatomic,strong) NSDictionary *contentDict;

@property (nonatomic,strong) __block NSArray *contentData;

@property (nonatomic,strong) __block NSDictionary *allDict;

@property (nonatomic,weak) __block NSArray *navHeads;

@property (nonatomic,weak) CSHeaderImageView *headImage;

@property (nonatomic,strong) CSNavBarView *navBarView;

@property (nonatomic,strong) UIScrollView *contentScrollView;

@property (nonatomic,strong) MBProgressHUD *HUD;

@end

@implementation CSCarTypeController

- (void)setNavHeads:(NSArray *)navHeads {
    _navHeads = navHeads;
    CSNavBarView *navBarView = [[CSNavBarView alloc]init];
    navBarView.delegate = self;
    self.navBarView = navBarView;
    self.navBarView.navTittles = self.navHeads;
    self.navBarView.frame = CGRectMake(0, 0, ScreenWidth,CSNavBarViewHeight);
}

- (instancetype)initWithContentDict:(NSDictionary *)contentDict {
    if (self = [super init]) {
        self.contentDict = contentDict;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CSCarTypeCell"];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //设置表头
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth * 2 / 3)];
    
    //图片
    CSHeaderImageView *headImage = [[CSHeaderImageView alloc]initWithFrame:headView.bounds];
    headImage.delegate = self;
    self.headImage = headImage;
    
    [headView addSubview:headImage];
    
    //车类型
    UILabel *carTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth / 3, 40)];
    carTypeLabel.shadowColor = [UIColor blackColor];
    
    carTypeLabel.textAlignment = NSTextAlignmentCenter;
    carTypeLabel.textColor = MainWhiteColor;
    self.carTypeLabel = carTypeLabel;
    [headView addSubview:carTypeLabel];
    
    //价格区间
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth * 0.5, 0, ScreenWidth * 0.5 - 10, 40)];
    priceLabel.shadowColor = [UIColor blackColor];
    
//    priceLabel.shadowOffset = CGSizeMake(1,1);
    
    priceLabel.textColor = MainWhiteColor;
    priceLabel.textAlignment = NSTextAlignmentRight;
    self.priceLabel = priceLabel;
    [headView addSubview:priceLabel];
    
    
    self.tableView.tableHeaderView = headView;
    
    
    [MBProgressHUD showHUDAddedTo:self.tableView  animated:YES];

    [self getData];

}

- (void)getData {
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListBySeriesId.do?seriesId=%@&cityId=%@",self.contentDict[@"seriesId"],self.contentDict[@"cityId"]];
    
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CSCarTypeController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _contentData = responseObject[@"carModelList"];
            
            myself.navHeads = [responseObject[@"displacement"] componentsSeparatedByString:@","];
            
            myself.allDict = responseObject;
            
            myself.carTypeLabel.text = [NSString stringWithFormat:@"%@",responseObject[@"level"]];
            
            myself.priceLabel.text = [NSString stringWithFormat:@"%@",responseObject[@"guidePrice"]];
            
            [myself.headImage sd_setImageWithURL:[NSURL URLWithString:myself.allDict[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
            [myself.tableView reloadData];
            
            [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
            

        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
}


#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CSCarTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    NSDictionary *dict = self.contentData[indexPath.row];
    
    CSContentCell *contentCell = [[CSContentCell alloc]init];
    contentCell.delegate = self;
    contentCell.cellDict = dict;
    contentCell.frame = cell.bounds;
    
    [cell.contentView addSubview:contentCell];
    
    return cell;
}

#pragma mark - tableView delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.navBarView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CSNavBarViewHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void)cSNavBtnClick:(CSNavBarView *)cSNavBarView Displacement:(NSString *)displacement{
    
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListBySeriesId.do?seriesId=%@&cityId=1&displacement=%@",self.contentDict[@"seriesId"],displacement];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    __weak CSCarTypeController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _contentData = responseObject[@"carModelList"];
        
        [myself.tableView reloadData];
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        

        
    }];
    
}

#pragma mark - CSContentCellDelegate方法
- (void)cSContentCellClick:(CSContentCell *)contentCell {
    NSString *carTypeId = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"id"]];
    NSString *carTypeName = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"name"]];
    NSString *carTypeImage = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"imagePath"]];
    NSString *carTypePrice = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"guidePrice"]];
    NSString *carTypeLowPrice = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"MinPrice"]];
    
    
    NSString *carSeriesId = self.contentDict[@"seriesId"];
    NSString *carSeriesName = self.contentDict[@"seriesName"];
    
    NSDictionary *carTypeInfo = @{@"carSeriesId":carSeriesId,@"carSeriesName":carSeriesName,@"carTypeId":carTypeId,@"carTypeName":carTypeName,@"carTypeImage":carTypeImage,@"carTypePrice":carTypePrice,@"carTypeLowPrice":carTypeLowPrice};
    
    CarTypeController *carTypeVc = [[CarTypeController alloc]initWithCarTypeInfo:carTypeInfo];
    
    [self.navigationController pushViewController:carTypeVc animated:YES];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
