//
//  CompareBrandDetailController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-25.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CompareBrandDetailController.h"
#import "NoHighLightBtn.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "CompareCarTypeController.h"
#import "MBProgressHUD.h"


#define TableHeadHeight 44
#define SectionHeadHeight 30

@interface CompareBrandDetailController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) __block NSDictionary *carSeriesDetail;

@property (nonatomic,strong) __block NSArray *carSeries;

///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) CompareCarTypeController *carTypeVc;

@end

@implementation CompareBrandDetailController

- (instancetype)initWithBrandInfo:(NSDictionary *)brandInfo {
    if (self = [super init]) {
        self.brandInfo = brandInfo;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, TableHeadHeight)];
    headView.backgroundColor = MainWhiteColor;
    
    [self.view addSubview:headView];
    
    UIImageView *brandImage = [[UIImageView alloc]init];
    
    //品牌图标
    [brandImage sd_setImageWithURL:self.brandInfo[@"imagePath"] placeholderImage:[UIImage imageNamed:@"chexun_closeicon_gray"]];
    
    //设置图片居中显示，按比例缩小
    brandImage.contentMode =  UIViewContentModeScaleAspectFit;
    brandImage.frame = CGRectMake(0, 0, 0.3 * ScreenWidth, TableHeadHeight);
    [headView addSubview:brandImage];
    
    //品牌名称
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(brandImage.frame), 0, 0.5 * ScreenWidth, TableHeadHeight)];
    nameLabel.text = self.brandInfo[@"name"];
    [headView addSubview:nameLabel];
    
    //关闭按钮
    NoHighLightBtn *closeBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(ScreenWidth - 44, 0, 44, TableHeadHeight)];
    [closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    [closeBtn setImage:[UIImage imageNamed:@"chexun_closeicon_gray"] forState:UIControlStateNormal];
    [headView addSubview:closeBtn];
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame), ScreenWidth, ScreenHeight - headView.height - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ComBrandDetailCell"];
    
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    
    [self getData];
    
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarBrandDetail.do?brandId=%@",self.brandInfo[@"id"]];
    __weak CompareBrandDetailController *myself = self;
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
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
    //通知代理，移除蒙板
    
    
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
    
    static NSString *ID = @"ComBrandDetailCell";
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
    iconView.frame = CGRectMake(0, 0, 0.3 * ScreenWidth, 0.25 * ScreenWidth);
    [cell.contentView addSubview:iconView];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.frame = CGRectMake(0.4 * ScreenWidth, 0.25 * ScreenWidth * 0.1, 0.5 * ScreenWidth , 0.25 * ScreenWidth * 0.4);
    nameLabel.textColor = MainBlackColor;
    nameLabel.text = dictList[@"name"];
    [cell.contentView addSubview:nameLabel];
    
    UILabel *priceLabel = [[UILabel alloc]init];
    priceLabel.font = [UIFont systemFontOfSize:15];
    priceLabel.frame = CGRectMake(0.4 * ScreenWidth, 0.25 * ScreenWidth * 0.5, 0.4 * ScreenWidth , 0.25 * ScreenWidth * 0.4);
    priceLabel.textColor = MainFontGrayColor;
    priceLabel.text = dictList[@"guidePrice"];
    [cell.contentView addSubview:priceLabel];
    
    
    UIImageView *arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_sale"]];
    arrowImage.contentMode = UIViewContentModeCenter;
    arrowImage.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame), 0.25 * ScreenWidth * 0.5 + (0.25 * ScreenWidth * 0.4 - 15) * 0.5, 20, 15);
    [cell.contentView addSubview:arrowImage];
    
    
    UILabel *reducePriceLabel = [[UILabel alloc]init];
    reducePriceLabel.textColor = [UIColor redColor];
    reducePriceLabel.font = [UIFont systemFontOfSize:13];
    reducePriceLabel.frame = CGRectMake(CGRectGetMaxX(arrowImage.frame), 0.25 * ScreenWidth * 0.5 + (0.25 * ScreenWidth * 0.4 - 15) * 0.5, 50, 15);
    reducePriceLabel.text = dictList[@"hq"];
    [cell.contentView addSubview:reducePriceLabel];
    
    
    NSString *str = [NSString stringWithFormat:@"%@",dictList[@"hq"]];
    
    //判断字典里面返回的为空值
    
    if (str.length <= 0 || str == nil || str == NULL || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || dictList[@"hq"] == nil) {
        
        arrowImage.hidden = YES;
        reducePriceLabel.hidden = YES;
    }
    
    //添加一根表格的分割线
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
    return 0.25 * ScreenWidth;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = self.carSeriesDetail[@"companyList"];
    NSDictionary *dict = arr[indexPath.section];
    NSArray *arrList = dict[@"seriesList"];
    NSDictionary *dictList = arrList[indexPath.row];
    
    NSDictionary *seriesDict = @{@"seriesId":dictList[@"id"],@"name":dictList[@"name"]};
    
    CompareCarTypeController *carTypeVc = [[CompareCarTypeController alloc]initWithSeriesDict:seriesDict];
    self.carTypeVc = carTypeVc;
    [self.navigationController pushViewController:carTypeVc animated:YES];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
