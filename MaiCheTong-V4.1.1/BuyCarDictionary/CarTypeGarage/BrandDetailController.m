//
//  BrandDetailController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-19.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "BrandDetailController.h"
#import "NoHighLightBtn.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "CarSeriesController.h"
#import "MBProgressHUD.h"
#import "MainTabBarController.h"


#define TableHeadHeight 44
#define SectionHeadHeight 30
#define Ratio 0.2
#define RatioW 0.3

#define GapW 4

@interface BrandDetailController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) __block NSDictionary *carSeriesDetail;

@property (nonatomic,strong) __block NSArray *carSeries;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) CarSeriesController *carSeriesVc;
@end

@implementation BrandDetailController

- (instancetype)initWithBrandInfo:(NSDictionary *)brandInfo {
    if (self = [super init]) {
        self.brandInfo = brandInfo;
        
    }
    return self;
}

- (NSArray *)carSeries {
    if (_carSeries == nil) {
        
    }
    return _carSeries;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    tab.tabBarView.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *upClearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight * 0.3)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeClick)];
    [upClearView addGestureRecognizer:tap];
    upClearView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:upClearView];
    
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(upClearView.frame), ScreenWidth, TableHeadHeight)];
    headView.backgroundColor = MainWhiteColor;
    
    [self.view addSubview:headView];
    
    //品牌的图标
    UIImageView *brandBgImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, -25, 50, 50)];
    brandBgImage.image = [UIImage imageNamed:@"chexun_series_logobg"];
    
    [headView addSubview:brandBgImage];
    
    
    UIImageView *iconImage = [[UIImageView alloc]init];
    [iconImage sd_setImageWithURL:[NSURL URLWithString:self.brandInfo[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    iconImage.frame = CGRectMake(2, 2, 44, 44);
    iconImage.layer.cornerRadius = 22;
    iconImage.layer.masksToBounds = YES;
    [brandBgImage addSubview:iconImage];
    

    
    /*
    
    UIImageView *brandImage = [[UIImageView alloc]init];
    
    //品牌图标
    [brandImage sd_setImageWithURL:self.brandInfo[@"imagePath"] placeholderImage:[UIImage imageNamed:@"load0.png"]];
    
    //设置图片居中显示，按比例缩小
    brandImage.contentMode =  UIViewContentModeScaleAspectFit;
    brandImage.frame = CGRectMake(0, 0, 0.3 * ScreenWidth, TableHeadHeight);
    [headView addSubview:brandImage];
     */
    
    //品牌名称
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(brandBgImage.frame) + 20, 0, 0.5 * ScreenWidth, TableHeadHeight)];
    nameLabel.text = self.brandInfo[@"name"];
    [headView addSubview:nameLabel];
    
    //关闭按钮
    NoHighLightBtn *closeBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(ScreenWidth - 44, 0, 44, TableHeadHeight)];
    [closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    [closeBtn setImage:[UIImage imageNamed:@"chexun_closeicon_gray"] forState:UIControlStateNormal];
    [headView addSubview:closeBtn];
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame), ScreenWidth, ScreenHeight - headView.height - 64 - ScreenHeight * 0.3)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"BrandDetailCell"];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
}

- (void)getData {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarBrandDetail.do?brandId=%@",self.brandInfo[@"id"]];
    __weak BrandDetailController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        myself.carSeriesDetail = responseObject;
        myself.carSeries = responseObject[@"companyList"];
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        MyLog(@"error:%@",error);
    }];
}

//关闭按钮的点击事件
- (void)closeClick {
    
    if ([self.delegate respondsToSelector:@selector(closeClick)]) {
        [self.delegate closeClick];
    }
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
    self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *arr = self.carSeriesDetail[@"companyList"];
    NSDictionary *dict = arr[section];
    NSArray *arrList = dict[@"seriesList"];
    return arrList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.carSeries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"BrandDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger subviewsCount = cell.contentView.subviews.count;
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    NSArray *arr = self.carSeriesDetail[@"companyList"];
    NSDictionary *dict = arr[indexPath.section];
    NSArray *arrList = dict[@"seriesList"];
    NSDictionary *dictList = arrList[indexPath.row];
    UIImageView *iconView = [[UIImageView alloc]init];
    [iconView sd_setImageWithURL:[NSURL URLWithString:dictList[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    iconView.frame = CGRectMake(0, 0, RatioW * ScreenWidth, Ratio * ScreenWidth);
    [cell.contentView addSubview:iconView];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.frame = CGRectMake(RatioW * ScreenWidth + GapW, Ratio * ScreenWidth * 0.1, 0.5 * ScreenWidth , 0.25 * ScreenWidth * 0.4);
    nameLabel.textColor = MainBlackColor;
    nameLabel.text = dictList[@"name"];
    [cell.contentView addSubview:nameLabel];
    
    UILabel *priceLabel = [[UILabel alloc]init];
    priceLabel.font = [UIFont systemFontOfSize:15];
    priceLabel.frame = CGRectMake(RatioW * ScreenWidth + GapW, Ratio * ScreenWidth * 0.5, 0.4 * ScreenWidth , Ratio * ScreenWidth * 0.4);
    priceLabel.textColor = MainFontGrayColor;
    priceLabel.text = dictList[@"guidePrice"];
    [cell.contentView addSubview:priceLabel];
    
    
    UIImageView *arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_sale"]];
    arrowImage.contentMode = UIViewContentModeCenter;
    arrowImage.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame), Ratio * ScreenWidth * 0.5 + (Ratio * ScreenWidth * 0.4 - 15) * 0.5, 20, 15);
    [cell.contentView addSubview:arrowImage];
    
    
    UILabel *reducePriceLabel = [[UILabel alloc]init];
    reducePriceLabel.textColor = [UIColor redColor];
    reducePriceLabel.font = [UIFont systemFontOfSize:12];
    reducePriceLabel.frame = CGRectMake(CGRectGetMaxX(arrowImage.frame), Ratio * ScreenWidth * 0.5 + (Ratio * ScreenWidth * 0.4 - 15) * 0.5, 50, 15);
    reducePriceLabel.text = dictList[@"hq"];
    [cell.contentView addSubview:reducePriceLabel];
    
    
    NSString *str = [NSString stringWithFormat:@"%@",dictList[@"hq"]];
    
    //判断字典里面返回的为空值
    
    if (str.length <= 0 || str == nil || str == NULL || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || dictList[@"hq"] == nil) {
        
        arrowImage.hidden = YES;
        reducePriceLabel.hidden = YES;
    }
    
    //添加一根表格的分割线
//    UIImageView *spliteLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, cell.height - 1, cell.width, 1)];
//    spliteLine.image = [UIImage imageNamed:@"chexun_home_divider"];
//    [cell.contentView addSubview:spliteLine];
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, cell.height - 1, cell.width, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    
    [cell.contentView addSubview:spliteLine];

    
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *arr = self.carSeriesDetail[@"companyList"];
    NSDictionary *dict = arr[section];
    
    UIView *secHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, SectionHeadHeight)];
    secHeadView.backgroundColor = MainBackGroundColor;
    
    UILabel *secHeadLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, SectionHeadHeight)];
    secHeadLabel.text = dict[@"companyName"];
    
    [secHeadView addSubview:secHeadLabel];
    
    return secHeadView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SectionHeadHeight;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Ratio * ScreenWidth;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = self.carSeriesDetail[@"companyList"];
    NSDictionary *dict = arr[indexPath.section];
    NSArray *arrList = dict[@"seriesList"];
    NSDictionary *dictList = arrList[indexPath.row];
    NSString *hq = @"";
    if (dictList[@"hq"] != nil) {
        hq = dictList[@"hq"];
    }
    
    NSDictionary *carSeriesDict = @{@"id":dictList[@"id"],
                                    @"hq":hq,
                                    @"imgPath":dictList[@"imagePath"],
                                    @"hqurl":dictList[@"hqurl"],
                                    @"english":dictList[@"english"],
                                    @"guidePrice":dictList[@"guidePrice"],
                                    @"name":dictList[@"name"],
                                    @"active":dictList[@"active"],
                                    @"brandLogo":self.brandInfo[@"imagePath"]
                                    };
    
    CarSeriesController *carSeriesVc = [[CarSeriesController alloc]initWithSeriesDict:carSeriesDict];
    self.carSeriesVc = carSeriesVc;
    [self.navigationController pushViewController:carSeriesVc animated:YES];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
