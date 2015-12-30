//
//  ScreeningController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-15.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "ScreeningController.h"
#import "ScreeningView.h"
#import "NoHighLightBtn.h"
#import "ScreeningResultController.h"
#import "MBProgressHUD+GJ.h"
#import "AFNetworking.h"
#import "MainTabBarController.h"

#define ResultBtnHeight 50

@interface ScreeningController ()<UITableViewDelegate,UITableViewDataSource,ScreeningViewDelegate,UIGestureRecognizerDelegate>
/** 结果按钮 */
@property (nonatomic,weak) NoHighLightBtn *resultBtn;

@property (nonatomic,strong) NSArray *buttonsStatic;
@property (nonatomic,strong) NSArray *priceStatic;
@property (nonatomic,strong) NSArray *typeStatic;
@property (nonatomic,strong) NSArray *outputStatic;
@property (nonatomic,strong) NSArray *changespeedStatic;
@property (nonatomic,strong) NSArray *attributeStatic;

@property (nonatomic,strong) __block  NSArray *price;
@property (nonatomic,strong) __block  NSArray *type;
@property (nonatomic,strong) __block  NSArray *output;
@property (nonatomic,strong) __block  NSArray *changespeed;
@property (nonatomic,strong) __block  NSArray *attribute;
@property (nonatomic,strong) __block  NSArray *buttons;

@property (nonatomic,strong) NSArray *headTitles;

@property (nonatomic,weak) UITableView *tableView;


@property (nonatomic,strong) NSDictionary *btnInfo;

@property (nonatomic,strong) NSMutableDictionary *selectedDictM;

@property (nonatomic,strong) __block NSArray *conditions;

@property (nonatomic,strong) __block NSDictionary *allDataDict;


///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@end

@implementation ScreeningController


- (instancetype)initWithInfo:(NSDictionary *)btnInfo {
    if (self = [super init]) {
        if (btnInfo == nil || [btnInfo[@"levelId"] integerValue] == 0) {
            btnInfo = @{@"levelId":@"2",@"name":@"紧凑型车"};
        }
        self.btnInfo = btnInfo;
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [super viewDidLoad];
    
    
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
    
    //设置右边的重置按钮
    UIButton *newSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [newSelectBtn addTarget:self action:@selector(newSelect) forControlEvents:UIControlEventTouchDown];
    
    newSelectBtn.frame = CGRectMake(ScreenWidth - 44 - 5, 20, 44, 44);
    [newSelectBtn setTitle:@"重置" forState:UIControlStateNormal];
    newSelectBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [newSelectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [navView addSubview:newSelectBtn];
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"筛选";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    NSDictionary *dict = @{@"price":@"-1",@"type":self.btnInfo[@"levelId"],@"output":@"-1",@"changespeed":@"-1",@"attribute":@"-1"};
    
    self.selectedDictM = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    //创建一个表格
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 50)];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    //添加一个结果视图
    UIView *resultView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 50, ScreenWidth, ResultBtnHeight)];
    resultView.backgroundColor = MainWhiteColor;
    [self.view addSubview:resultView];
    
    //添加一个结果按钮
    NoHighLightBtn *resultBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(0, 5, ScreenWidth, ResultBtnHeight)];
    self.resultBtn = resultBtn;
    
    NSString *btnTitle = [NSString stringWithFormat:@"正在查询，请稍后..."];
    NSString *btnTitleDis = [NSString stringWithFormat:@"查询失败"];
    [self.resultBtn setTitle:btnTitle forState:UIControlStateNormal];
    [self.resultBtn setTitle:btnTitleDis forState:UIControlStateDisabled];
    resultBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    
    [resultBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    
    [resultBtn setBackgroundImage:[UIImage imageNamed:@"chexun_okbutbg"] forState:UIControlStateNormal];
    [resultBtn setBackgroundImage:[UIImage imageNamed:@"checun_tabbg2_selected"] forState:UIControlStateDisabled];
    
    [resultView addSubview:resultBtn];
    
    self.navigationItem.title = @"筛选";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ScreeningCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    //车系类别，价格，排量，变速箱，属性
    
    self.headTitles = @[@"车系类别",@"价格",@"排量",@"变速箱",@"属性"];
    
    //取消未知这一项@{@"typeId":@"1",@"typeName":@"未知"},
    self.priceStatic = @[@{@"typeId":@"-1",@"typeName":@"不限"},
                         @{@"typeId":@"2",@"typeName":@"8万元以下"},
                         @{@"typeId":@"3",@"typeName":@"8-12万"},
                         @{@"typeId":@"4",@"typeName":@"12-18万"},
                         @{@"typeId":@"5",@"typeName":@"18-25万"},
                         @{@"typeId":@"6",@"typeName":@"25-40万"},
                         @{@"typeId":@"7",@"typeName":@"40-80万"},
                         @{@"typeId":@"8",@"typeName":@"80万以上"}];
    
    self.typeStatic = @[@{@"typeId":@"1",@"typeName":@"小型车"},
                        @{@"typeId":@"2",@"typeName":@"紧凑型车"},
                        @{@"typeId":@"3",@"typeName":@"中型车"},
                        @{@"typeId":@"4",@"typeName":@"中大型车"},
                        @{@"typeId":@"5",@"typeName":@"豪华车"},
                        @{@"typeId":@"6",@"typeName":@"MPV"},
                        @{@"typeId":@"7",@"typeName":@"SUV"},
                        @{@"typeId":@"8",@"typeName":@"跑车"},
                        @{@"typeId":@"9",@"typeName":@"微型车"},
                        @{@"typeId":@"10",@"typeName":@"概念车"},
                        @{@"typeId":@"11",@"typeName":@"皮卡"},
                        @{@"typeId":@"12",@"typeName":@"客车"},
                        @{@"typeId":@"100020",@"typeName":@"微面"}];
    
    self.outputStatic = @[@{@"typeId":@"-1",@"typeName":@"不限"},
                         @{@"typeId":@"1",@"typeName":@"1.6L以下"},
                         @{@"typeId":@"2",@"typeName":@"1.6-2.0L"},
                         @{@"typeId":@"3",@"typeName":@"2.1-2.5L"},
                         @{@"typeId":@"4",@"typeName":@"2.6-3.0L"},
                         @{@"typeId":@"5",@"typeName":@"3.0L以上"}];
    
    self.changespeedStatic = @[@{@"typeId":@"-1",@"typeName":@"不限"},
                          @{@"typeId":@"1",@"typeName":@"自动"},
                          @{@"typeId":@"2",@"typeName":@"手动"}];
    
    self.attributeStatic = @[@{@"typeId":@"-1",@"typeName":@"不限"},
                             @{@"typeId":@"0",@"typeName":@"进口"},
                             @{@"typeId":@"1",@"typeName":@"自主"},
                             @{@"typeId":@"2",@"typeName":@"合资"}];
    
    
    self.buttonsStatic = @[self.typeStatic,self.priceStatic,self.outputStatic,self.changespeedStatic,self.attributeStatic];
    
}

/** 重置按钮的点击事件 */
- (void)newSelect {
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if ([self.selectedDictM[@"price"] integerValue] == -1
        && [self.selectedDictM[@"type"] integerValue] == -1
        && [self.selectedDictM[@"output"] integerValue] == -1
        && [self.selectedDictM[@"changespeed"] integerValue] == -1
        && [self.selectedDictM[@"attribute"] integerValue] == -1) {
        return;
    }
    
    NSDictionary *dict = @{@"price":@"-1",@"type":@"-1",@"output":@"-1",@"changespeed":@"-1",@"attribute":@"-1"};
    
    self.selectedDictM = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [self.tableView reloadData];
    
//    [MBProgressHUD hideAllHUDsForView:self.view  animated:YES];
    
    NSString *btnTitle = [NSString stringWithFormat:@"已有%@款车型",self.allDataDict[@"count"]];
    
    [self.resultBtn setTitle:btnTitle forState:UIControlStateNormal];
}

- (void)setSelectedDictM:(NSMutableDictionary *)selectedDictM {
    _selectedDictM = selectedDictM;
    
    
    NSMutableString *parameter = [NSMutableString string];
    NSString *actionType = @"1";
    [parameter appendFormat:@"actionType=%@",actionType];
    
    if (![selectedDictM[@"type"] isEqual:@"-1"]) {
        [parameter appendFormat:@"&levelId=%@",selectedDictM[@"type"]];
    }
    if (![selectedDictM[@"price"] isEqual:@"-1"]) {
        [parameter appendFormat:@"&priceId=%@",selectedDictM[@"price"]];
    }
    if (![selectedDictM[@"output"] isEqual:@"-1"]) {
        [parameter appendFormat:@"&displacementId=%@",selectedDictM[@"output"]];
    }
    if (![selectedDictM[@"changespeed"] isEqual:@"-1"]) {
        [parameter appendFormat:@"&speedBoxId=%@",selectedDictM[@"changespeed"]];
    }
    if (![selectedDictM[@"attribute"] isEqual:@"-1"]) {
        [parameter appendFormat:@"&companyTypeId=%@",selectedDictM[@"attribute"]];
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [self buttonShowWithParameter:parameter];
    
}

- (void)buttonShowWithParameter:(NSString *)parameter {
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarSeriesListByCondition.do?%@",parameter];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak ScreeningController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = responseObject;
        
        if (responseDict != nil) {
            
            myself.allDataDict = responseDict;
            
            NSInteger countArr = [myself.allDataDict[@"count"] integerValue];
            if (countArr == 0) {
                myself.resultBtn.enabled = NO;
            } else {
                myself.resultBtn.enabled = YES;
                NSString *btnTitle = [NSString stringWithFormat:@"已有%@款车型",myself.allDataDict[@"count"]];
                [myself.resultBtn setTitle:btnTitle forState:UIControlStateNormal];
            }
            
            NSArray *arr = responseDict[@"conditions"];
            
            NSMutableArray *resultM = [NSMutableArray array];
            NSArray *keys = @[@"price",@"level",@"displacement",@"speedBox",@"companyType"];
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dict  = arr[i];
                NSString *key = keys[i];
                NSArray *result = [dict[key] componentsSeparatedByString:@","];
                [resultM  addObject:result];
            }
            
            myself.conditions = resultM;
        }
        
        [myself.tableView reloadData];
        
        
        
        [MBProgressHUD hideAllHUDsForView:myself.navigationController.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.navigationController.view animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }];
    
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)sureClick {
    
    ScreeningResultController *screeningResultVc = [[ScreeningResultController alloc]initWithCondition:self.selectedDictM];
    
    [self.navigationController pushViewController:screeningResultVc animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.headTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"ScreeningCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (ScreeningView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ScreeningView *screeningView = [[ScreeningView alloc]init];
    screeningView.delegate = self;
    screeningView.frame = CGRectMake(0, UpDownGap, cell.width, cell.height - 2 * UpDownGap);
    screeningView.sectionValue = indexPath.section;
    
    
    if (indexPath.section == 0) {
        screeningView.carTypeStr = self.btnInfo[@"name"];
        
        
    }
    
    if (indexPath.section == 0) {
        screeningView.selectedTypeId = self.selectedDictM[@"type"];
        if (self.conditions != nil) {
            
            screeningView.selectedArr = self.conditions[1];
        }
    } else if (indexPath.section == 1) {
        screeningView.selectedTypeId = self.selectedDictM[@"price"];
        if (self.conditions != nil) {
            
            screeningView.selectedArr = self.conditions[0];
        }
    }else if (indexPath.section == 2) {
        screeningView.selectedTypeId = self.selectedDictM[@"output"];
        if (self.conditions != nil) {
            
            screeningView.selectedArr = self.conditions[2];
        }
    }else if (indexPath.section == 3) {
        screeningView.selectedTypeId = self.selectedDictM[@"changespeed"];
        if (self.conditions != nil) {
            
            screeningView.selectedArr = self.conditions[3];
        }
    }else if (indexPath.section == 4) {
        screeningView.selectedTypeId = self.selectedDictM[@"attribute"];
        if (self.conditions != nil) {
            
            screeningView.selectedArr = self.conditions[4];
        }
    }
    
    screeningView.buttonInfo = self.buttonsStatic[indexPath.section];

    cell.selected = NO;
    
    [cell.contentView addSubview:screeningView];
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    NSArray *buttonNum = self.buttonsStatic[indexPath.section];
    
    NSInteger count = buttonNum.count;
    NSInteger modValue = count % ButtonNum;
    NSInteger row = count / ButtonNum;
    
    CGFloat cellHeight = 0;
    if (modValue == 0) {
        cellHeight = row * BtnHeight + (row - 1) * CenterGap +  2 * UpDownGap;
    } else {
        cellHeight = (row + 1) * BtnHeight + row * CenterGap +  2 * UpDownGap;
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 25)];
    view.backgroundColor = MainBackGroundColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, view.width, view.height)];
    label.font = [UIFont systemFontOfSize:14];
    
    label.text = self.headTitles[section];
    
    [view addSubview:label];
    
    return view;
}

- (void)screeningViewBtnClick:(NSString *)selectedId SectionValue:(NSInteger)sectionValue {
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [self.resultBtn setTitle:@"正在查询，请稍后..." forState:UIControlStateNormal];
    
    NSMutableDictionary *selectedM = [NSMutableDictionary dictionaryWithDictionary:self.selectedDictM];
    
    switch (sectionValue) {
        case 0: {//车系级别level
            selectedM[@"type"] = selectedId;
            break;
        }
        case 1: {//价格price
            selectedM[@"price"] = selectedId;
            break;
        }
        case 2: {//排量output
            selectedM[@"output"] = selectedId;
            break;
        }
        case 3: {//变速箱changespeed
            selectedM[@"changespeed"] = selectedId;
            break;
        }
        case 4: {//属性attribute
            selectedM[@"attribute"] = selectedId;
            break;
        }
        default:
            break;
    }
    self.selectedDictM = selectedM;
    
    [self.tableView reloadData];
    
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSInteger countArr = [self.allDataDict[@"count"] integerValue];
    if (countArr == 0) {
        self.resultBtn.enabled = NO;
    } else {
        self.resultBtn.enabled = YES;
        NSString *btnTitle = [NSString stringWithFormat:@"已有%@款车型",self.allDataDict[@"count"]];
        [self.resultBtn setTitle:btnTitle forState:UIControlStateNormal];
    }
    
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
