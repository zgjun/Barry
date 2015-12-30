//
//  CompareCarTypeController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-25.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CompareCarTypeController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "CompareCarTypeCell.h"
#import "CSNavBarView.h"
#import "NoHighLightBtn.h"
#import "MBProgressHUD.h"


#define CarTypeGap 10

#define NavHeight 64

#define CSNavBarViewHeight 44

@interface CompareCarTypeController ()<UITableViewDataSource,UITableViewDelegate,CompareCarTypeSelectedDelegate,CSNavBarViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSDictionary *seriesDict;

@property (nonatomic,weak) __block NSArray *navHeads;

@property (nonatomic,strong) __block NSArray *contentData;

@property (nonatomic,strong) CSNavBarView *navBarView;

@property (nonatomic,weak) UIButton *pkBtn;

///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,weak) NoHighLightBtn *indicatorBtn;

@property (nonatomic,strong) NSMutableArray *compareCars;

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,weak) UIButton *compareBtn;

@property (nonatomic,strong) NSArray *selectedCars;

@end

@implementation CompareCarTypeController

- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}


- (NSMutableArray *)compareCars {
    
    _compareCars = [NSMutableArray array];
    
    //从沙盒里面读取历史数据
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //拼接文件名
    
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    
    //先读取之前的历史记录
    
    _compareCars = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    
    
    return _compareCars;
    
}

- (instancetype)initWithSeriesDict:(NSDictionary *)seriesDict {
    if (self = [super init]) {
        self.seriesDict = seriesDict;
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
     
    /*
    self.navigationItem.title = self.seriesDict[@"name"];
    
    
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
    
    /*
    //PK视图
    UIView *pkView = [[UIView alloc]init];
    pkView.frame = CGRectMake(ScreenWidth - 60, 24.5, 60, 35);
    
    UIButton *pkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pkBtn addTarget:self action:@selector(pkBtnClick) forControlEvents:UIControlEventAllTouchEvents];
    self.pkBtn = pkBtn;
    pkBtn.frame = CGRectMake(0, 6, 43, 23);
    [pkBtn setBackgroundImage:[UIImage imageNamed:@"chexun_models_actionbar_pkicon"] forState:UIControlStateNormal];
    pkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [pkView addSubview:pkBtn];
    
    NoHighLightBtn *indicatorBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(35, 0, 18, 18)];
    [indicatorBtn addTarget:self action:@selector(pkBtnClick) forControlEvents:UIControlEventAllTouchEvents];
    self.indicatorBtn = indicatorBtn;
    if (self.compareCars.count == 0) {
        indicatorBtn.hidden = YES;
        
    } else {
        indicatorBtn.hidden = NO;
        [indicatorBtn setTitle:[NSString stringWithFormat:@"%@",@(self.compareCars.count)] forState:UIControlStateNormal];
    }
    indicatorBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [indicatorBtn setBackgroundImage:[UIImage imageNamed:@"chexun_models_actionbar_pkicon_selected"] forState:UIControlStateNormal];
    [pkView addSubview:indicatorBtn];
    
    [navView addSubview:pkView];
     */
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, 20, 150, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text =  self.seriesDict[@"name"];
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 49)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CompareCarCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    
    
    //添加去对比按钮
    UIButton *compareBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, ScreenHeight - 49, ScreenWidth, 49)];
    [compareBtn setBackgroundImage:[UIImage imageNamed:@"chexun_okbutbg"] forState:UIControlStateNormal];
    [compareBtn setBackgroundImage:[UIImage imageNamed:@"checun_tabbg2_selected"] forState:UIControlStateDisabled];
    
    
    if (self.compareCars.count == 0) {
        compareBtn.enabled = NO;
        [compareBtn setTitle:[NSString stringWithFormat:@"请选择车型"] forState:UIControlStateDisabled];
    } else {
        compareBtn.enabled = YES;
        [compareBtn setTitle:[NSString stringWithFormat:@"已选择%@款车型，去对比",@(self.compareCars.count)] forState:UIControlStateNormal];
    }
    [compareBtn addTarget:self action:@selector(pkBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.compareBtn = compareBtn;
    [self.view addSubview:compareBtn];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
}

- (void)getData {
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListBySeriesId.do?seriesId=%@&cityId=%@",self.seriesDict[@"seriesId"],self.cityId];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    __weak CompareCarTypeController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _contentData = responseObject[@"carModelList"];
        
        myself.navHeads = [responseObject[@"displacement"] componentsSeparatedByString:@","];
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
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

- (void)pkBtnClick {
    
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GoToCompareVc" object:nil]];
    
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CompareCarCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    NSDictionary *dict = self.contentData[indexPath.row];
    
    CompareCarTypeCell *contentCell = [[CompareCarTypeCell alloc]init];
    contentCell.delegate = self;
    contentCell.cellDict = dict;
    contentCell.frame = cell.bounds;
    for (int i = 0; i < self.compareCars.count; i++) {
        NSDictionary *beforeDict = self.compareCars[i];
        if ([beforeDict[@"carTypeId"]integerValue] == [dict[@"id"] integerValue]) {
            contentCell.isSelected = 1;
        }
    }
    
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
    return 70;
}




- (void)cSNavBtnClick:(CSNavBarView *)cSNavBarView Displacement:(NSString *)displacement{
    
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListBySeriesId.do?seriesId=%@&cityId=1&displacement=%@",self.seriesDict[@"seriesId"],displacement];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak  CompareCarTypeController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _contentData = responseObject[@"carModelList"];
        
        [myself.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MyLog(@"error:%@",error);
        
    }];
    
}

- (NSArray *)selectedCars {
    
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    //先读取之前的历史记录
    NSArray *cars = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    NSMutableArray *carsTemp = [NSMutableArray array];
    
    
        for (int i = 0; i < cars.count; i++) {
            NSDictionary *dict = cars[i];
            if ([dict[@"compareState"] integerValue] == 1) {
                [carsTemp addObject:dict];
            }
            
        }
    _selectedCars = carsTemp;

    return _selectedCars;
}

#pragma mark - CSContentCellDelegate方法
- (void)compareCarTypeSelectedClick:(CompareCarTypeCell *)contentCell {
    
    
    if (contentCell.isSelected == YES) {
        
        NSMutableArray *compareCarsM =  [NSMutableArray arrayWithArray:self.compareCars];
        NSString *carTypeId = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"id"]];
        NSString *carTypeName = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"name"]];
        NSString *carTypeImage = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"imagePath"]];
        NSString *carTypePrice = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"guidePrice"]];
        NSString *carTypeLowPrice = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"MinPrice"]];
        NSString *carSeriesName = self.seriesDict[@"name"];
        NSString *carSeriesId = self.seriesDict[@"seriesId"];
        
        NSInteger compareState = 0;
        if (self.selectedCars.count < 5) {
            compareState = 1;
        }
        
        NSDictionary *carTypeInfo = @{@"carTypeId":carTypeId,@"carTypeName":carTypeName,@"carTypeImage":carTypeImage,@"carTypePrice":carTypePrice,@"carTypeLowPrice":carTypeLowPrice,@"compareState":@(compareState),@"carSeriesName":carSeriesName,@"carSeriesId":carSeriesId};
        
        [compareCarsM addObject:carTypeInfo];
        
        [self writeNewData:compareCarsM];
        
        self.compareBtn.enabled = YES;
        [self.compareBtn setTitle:[NSString stringWithFormat:@"已选择%@款车型，去对比",@(compareCarsM.count)] forState:UIControlStateNormal];
    } else {
    
        for (int i = 0; i < self.compareCars.count; i++) {
            NSDictionary *dict = self.compareCars[i];
            NSString *carTypeId = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"id"]];
            if ([dict[@"carTypeId"] integerValue] == [carTypeId integerValue] ) {
                NSMutableArray *deleteM = self.compareCars;
                [deleteM removeObject:dict];
                
                if (deleteM.count == 0) {
                    self.compareBtn.enabled = NO;
                    [self.compareBtn setTitle:@"请选择车型" forState:UIControlStateDisabled];
                    //清除文件
                    [self cleanCompareCars];
                    
                } else {
                    self.compareBtn.enabled = YES;
                    [self.compareBtn setTitle:[NSString stringWithFormat:@"已选择%@款车型，去对比",@(deleteM.count)] forState:UIControlStateNormal];
                    
                    //写入新数据
                    [self writeNewData:deleteM];
                }
                break;
            }
        }
    }
    
    
}


- (void)writeNewData:(NSMutableArray *)compareCars {
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    
    if (compareCars.count == 0) {
        [self cleanCompareCars];
    } else {
        [compareCars writeToFile:fileName atomically:YES];
    }
}

- (void)cleanCompareCars {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:@"compareCars.plist"];
    BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
    if (bRet) {
        NSError *err;
        [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
    }
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}

@end
