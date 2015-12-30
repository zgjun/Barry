//
//  IndexHistoryController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "IndexHistoryController.h"
#import "HistoryCell.h"
#import "CarSeriesController.h"
#import "MainTabBarController.h"

#import "MBProgressHUD+GJ.h"
#import "AFNetworking.h"

@interface IndexHistoryController ()<UITableViewDelegate,UITableViewDataSource,HistoryCellDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSArray *historySeriesArr;

@property (nonatomic,strong) NSString *historyCars;

@property (nonatomic,weak) UIButton *cleanBtn;
@property (nonatomic,strong) NSString *cityId;

///大家正看的车型(假数据)
@property (nonatomic,strong) __block NSArray *seeingArr;
@end

@implementation IndexHistoryController

- (instancetype)initWithHistoryCars:(NSArray *)historyCars {
    if (self = [super init]) {
        self.historySeriesArr = historyCars;
    }
    return self;
}

- (NSArray *)historySeriesArr {
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"seriesHistory.plist"];
    
    
    //先读取之前的历史记录
    _historySeriesArr = [[NSArray alloc]initWithContentsOfFile:fileName];
    NSMutableString *strM = [NSMutableString string];
    
    if (_historySeriesArr.count > 0) {
        
        for (int i = 0; i < _historySeriesArr.count; i++) {
            NSDictionary *dict = _historySeriesArr[i];
            [strM appendString:[NSString stringWithFormat:@"%@,",dict[@"id"]]];
        }
        
        [strM deleteCharactersInRange:NSMakeRange(strM.length - 1, 1)];
        
        self.historyCars = strM;
    }
    
    
//    MyLog(@"_historySeriesArr==%@",_historySeriesArr);
    
    return _historySeriesArr;
}


- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}


- (NSArray *)seeingArr {
    
    if (_seeingArr == nil) {
        if (self.historySeriesArr.count >= 2) {
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSString *seeingCarUrl = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarRecommend.do?seriesIds=%@&cityId=%@",self.historyCars,self.cityId];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            __weak IndexHistoryController *myself = self;
            
            //获取大家正在看的车型
            [manager GET:seeingCarUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                _seeingArr = responseObject;
                
                [myself.tableView reloadData];
                [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
                [MBProgressHUD showError:@"数据加载异常"];
                return;
            }];
        }
    }
    return _seeingArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
        
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
    
    //清空按钮
    UIButton *cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cleanBtn addTarget:self action:@selector(cleanClick:) forControlEvents:UIControlEventTouchDown];
    self.cleanBtn = cleanBtn;
    cleanBtn.frame = CGRectMake(ScreenWidth - 50, 20, 44, 44);
    cleanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    cleanBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    cleanBtn.titleLabel.textColor = [UIColor blackColor];
    [cleanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cleanBtn setTitle:@"清空" forState:UIControlStateNormal];
    [navView addSubview:cleanBtn];
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, 20, 150, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"我浏览过的车型";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    self.navigationController.navigationBarHidden = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HistorySeriesCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = MainBackGroundColor;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    tab.tabBarView.hidden = YES;
}

- (void)doBack {
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

- (void)cleanClick:(UIButton *)cleanBtn {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:@"seriesHistory.plist"];
    BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
    if (bRet) {
        //
        NSError *err;
        [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
        self.historyCars = nil;
        cleanBtn.enabled = NO;
        [self.tableView reloadData];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.historySeriesArr.count >= 2) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.historySeriesArr.count;
    } else if (section == 1) {
        return self.seeingArr.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"HistorySeriesCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HistoryCell *historyCell;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        historyCell = (HistoryCell *)cell.contentView.subviews[0];
    
    } else {
        historyCell = [[HistoryCell alloc]init];
        historyCell.frame = cell.bounds;
        historyCell.delegate = self;
        [cell.contentView addSubview:historyCell];
    }
    NSDictionary *dict;
    if (self.historySeriesArr.count >= 2 && indexPath.section == 1) {
        dict = self.seeingArr[indexPath.row];
    } else {
        dict = self.historySeriesArr[indexPath.row];
    }    
    historyCell.historyCellDict = dict;
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.historySeriesArr.count >= 2 && section == 1) {
        UIView *secView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        secView.backgroundColor = MainBackGroundColor;
        
        UILabel *secLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 30)];
        secLabel.font = [UIFont systemFontOfSize:14];
        secLabel.text = @"您可能喜欢的车型";
        [secView addSubview:secLabel];
        return secView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.historySeriesArr.count >= 2 && section == 1) {
        return 30;
    } else {
        return 0;
    }
}

- (void)historyCellClick:(HistoryCell *)historyCell {
    NSDictionary *dictList = historyCell.historyCellDict;
    NSString *hq = [NSString stringWithFormat:@""];
    NSString *imgPath =[NSString stringWithFormat:@""];
    NSString *hqurl = [NSString stringWithFormat:@""];
    NSString *brandLogo = [NSString stringWithFormat:@""];
    NSString *brandName =[NSString stringWithFormat:@""];
    
    if (dictList[@"hq"] != nil ) {
        hq = dictList[@"hq"];
    }
    
    if (dictList[@"imgPath"] != nil) {
        imgPath = dictList[@"imgPath"];
    }
    
    if (dictList[@"hqurl"] != nil ) {
        hqurl = dictList[@"hqurl"];
    }
    
    if (dictList[@"brandLogo"] != nil) {
        brandLogo = dictList[@"brandLogo"];
    }
    if (dictList[@"brandName"] != nil ) {
        brandName = dictList[@"brandName"];
    }
    
    NSDictionary *carSeriesDict = @{@"id":dictList[@"id"],
                                    @"hq":hq,
                                    @"imgPath":imgPath,
                                    @"hqurl":hqurl,
                                    @"guidePrice":dictList[@"guidePrice"],
                                    @"name":dictList[@"name"],
                                    @"brandLogo":brandLogo,
                                    @"brandName":brandName
                                    };
    
    
    CarSeriesController *carSeriesVc = [[CarSeriesController alloc]initWithSeriesDict:carSeriesDict];
    
    [self.navigationController pushViewController:carSeriesVc animated:YES];
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
