//
//  OtherCarDetailController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherCarDetailController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "CSNavBarView.h"

#define CSNavBarViewHeight 44


@interface OtherCarDetailController ()<UITableViewDataSource,UITableViewDelegate,CSNavBarViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSString *carSeriesId;
@property (nonatomic,strong) NSString *carSeriesName;
@property (nonatomic,strong) NSString *priceType;

@property (nonatomic,weak) __block NSArray *navHeads;
@property (nonatomic,strong) __block NSArray *contentArr;
@property (nonatomic,strong) CSNavBarView *navBarView;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) NSString *headName;

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,strong) NSMutableArray *compareCars;

@end

@implementation OtherCarDetailController

- (NSMutableArray *)compareCars {
    
    _compareCars = [NSMutableArray array];
    
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    //先读取之前的历史记录
    NSMutableArray *arrM = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    
    for (int i = 0; i < arrM.count; i++) {
        
        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:arrM[i]];
        
        [dictM setValue:@0 forKey:@"compareState"];
        
        [_compareCars addObject:dictM];
    }
    
    return _compareCars;
}

- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}

- (instancetype)initWithCarSeriesId:(NSString *)carSeriesId carSeriesName:(NSString *)carSeriesName {
    if (self = [super init]) {
        self.carSeriesId = carSeriesId;
        self.carSeriesName = carSeriesName;
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
    
    titleLabel.text = @"车型选择";
    
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
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"OtherCarTypeCell"];
    [self.view addSubview:tableView];
    
    self.headName = @"车型";
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.tableView];
    
    [self.tableView addSubview:self.HUD];
    
    [self.HUD showWhileExecuting:@selector(getData) onTarget:self withObject:nil animated:YES];
    
    [MBProgressHUD showHUDAddedTo:self.tableView  animated:YES];
    

    [self getData];
}

- (void)getData {
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListBySeriesId.do?seriesId=%@&cityId=%@",self.carSeriesId,self.cityId];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak OtherCarDetailController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _contentArr = responseObject[@"carModelList"];
        
        myself.navHeads = [responseObject[@"displacement"] componentsSeparatedByString:@","];
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MyLog(@"error:%@",error);
        
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
    static NSString *ID = @"OtherCarTypeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    NSDictionary *dict = self.contentArr[indexPath.row];
    UILabel * carTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, ScreenWidth - 20, 40)];
    NSString *modelName = dict[@"name"];
    NSString *yearName = dict[@"yearName"];
    carTypeLabel.text = [NSString stringWithFormat:@"%@ %@",yearName,modelName];
    carTypeLabel.textAlignment = NSTextAlignmentLeft;
    carTypeLabel.font = [UIFont systemFontOfSize:16];
    carTypeLabel.textColor = MainBlackColor;
    [cell.contentView addSubview:carTypeLabel];
    
    UILabel *carPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(carTypeLabel.frame), ScreenWidth - 20, 20)];
    carPriceLabel.text = [NSString stringWithFormat:@"%.2f万",[dict[@"guidePrice"]floatValue]];
    carPriceLabel.textAlignment = NSTextAlignmentLeft;
    carPriceLabel.font = [UIFont systemFontOfSize:14];
    carPriceLabel.textColor = MainFontGrayColor;
    [cell.contentView addSubview:carPriceLabel];
    
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return self.navBarView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CSNavBarViewHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: self.contentArr[indexPath.row]];
    
    [dict setObject:self.carSeriesName forKey:@"seriesName"];
    [dict setObject:self.carSeriesId forKey:@"seriesId"];

    
    //判断是否已经添加
    for (int i = 0; i < self.compareCars.count; i++) {
        NSDictionary *beforeDict = self.compareCars[i];
        if ([beforeDict[@"carTypeId"] isEqual:dict[@"modelId"]]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                  
                                                            message:@"此车已经添加，请重新选择！"
                                  
                                                           delegate:nil
                                  
                                                  cancelButtonTitle:@"确定"
                                  
                                                  otherButtonTitles:nil];
            
            
            
            [alert show];
            
            return;
        }
    }
    
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OtherCarDetail" object:nil userInfo:dict];
    
    UIViewController *controller = self.navigationController.childViewControllers[1];
    
    [self.navigationController popToViewController:controller animated:YES];
    
}

- (void)cSNavBtnClick:(CSNavBarView *)cSNavBarView Displacement:(NSString *)displacement{
    
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListBySeriesId.do?seriesId=%@&cityId=%@&displacement=%@",self.carSeriesId,self.cityId,displacement];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak OtherCarDetailController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _contentArr = responseObject[@"carModelList"];
        
        [myself.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MyLog(@"error:%@",error);
        
    }];
    
}
- (void)setNavHeads:(NSArray *)navHeads {
    _navHeads = navHeads;
    CSNavBarView *navBarView = [[CSNavBarView alloc]init];
    navBarView.delegate = self;
    self.navBarView = navBarView;
    self.navBarView.navTittles = self.navHeads;
    self.navBarView.frame = CGRectMake(0, 0, ScreenWidth,CSNavBarViewHeight);
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}


@end
