//
//  CTSearchController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-19.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CTSearchController.h"
#import "AFNetworking.h"
#import "CarSeriesController.h"
#import "HTTPHelper.h"
#import "MainTabBarController.h"
#import "MBProgressHUD+GJ.h"


#import "SearchCell.h"
#define SearchViewHeight 30

@interface CTSearchController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIButton *cancelBtn;

@property (nonatomic,weak) UIView *searchView;

@property (nonatomic,weak) UIImageView *searchImage;

@property (nonatomic,weak) UITextField *searchText;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *searchData;

@property (nonatomic,strong) NSMutableArray *historyData;

@property (nonatomic,assign) NSInteger indicator;

@end

@implementation CTSearchController

- (NSMutableArray *)historyData {
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"searchHistory.plist"];
    //先读取之前的历史记录
    NSArray *fileData = [[NSArray alloc]initWithContentsOfFile:fileName];
    
    if (fileData == nil) {
        _historyData = [NSMutableArray array];
    } else {
        _historyData = [NSMutableArray arrayWithArray:fileData];
    }
    return _historyData;
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.navigationController.viewControllers.count == 1){
        //关闭主界面的右滑返回
        return NO;
    } else {
        return YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    //设置指示器
    self.indicator = 0;
    self.view.backgroundColor = MainWhiteColor;
    
    [self.navigationItem setHidesBackButton:YES];
    
    //搜索视图
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(20, 25, ScreenWidth - 75, SearchViewHeight)];
    self.searchView = searchView;
    searchView.layer.cornerRadius = 3;
    searchView.backgroundColor = MainBackGroundColor;
    [self.view addSubview:searchView];
    
    
    UIImageView *searchImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_searchicon"]];
    self.searchImage = searchImage;
    searchImage.frame = CGRectMake(0, 0, SearchViewHeight, SearchViewHeight);
    
    [searchView addSubview:searchImage];
    
    //搜索文本框
    UITextField *searchText = [[UITextField alloc]initWithFrame:CGRectMake(30, 0, ScreenWidth - 100, SearchViewHeight)];
    searchText.delegate = self;
    searchText.font = [UIFont systemFontOfSize:16];
    searchText.keyboardType = UIKeyboardTypeDefault;
//    searchText.returnKeyType = UIReturnKeyNext;
    searchText.returnKeyType = UIReturnKeySearch;
    searchText.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //添加事件
    [searchText addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    self.searchText = searchText;
    [searchView addSubview:searchText];
    
    //设置右边的取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchDown];
    self.cancelBtn = cancelBtn;
    cancelBtn.frame = CGRectMake(CGRectGetMaxX(searchView.frame), 25, 50, SearchViewHeight);
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    cancelBtn.titleLabel.textColor = [UIColor blackColor];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.view addSubview:cancelBtn];
    
    
    //创建内容表格
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame) + 10, ScreenWidth, ScreenHeight - SearchViewHeight - 30)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //获得焦点
    [self.searchText becomeFirstResponder];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;
}

- (void)textChanged:(UITextField *)textField {
    if ([(NSString *)textField.text isEqualToString:@""]) {
        self.indicator = 0;
        [self.tableView reloadData];
    } else {
        self.indicator = 1;
        
        [self searchContentData:(NSString *)textField.text];
    }
}

- (void)cancelBtnClick {
    [self.searchText resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
//    [self writeToPlist:textField];
    
    //退出键盘
    [textField endEditing:YES];
    
    return YES;
}

///写入文件里面
- (void)writeToPlist:(NSDictionary *)searchDict {
    
    //确定写入的路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"searchHistory.plist"];
    
    
    
    //先读取之前的历史记录
    
    NSMutableArray *searchArr = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    /*
    
    NSString *contentName = textField.text;
    //去除字符串两边的空格
    contentName = [contentName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //去空
    if (contentName.length == 0) {
        return;
    }
    NSDictionary *searchDict = @{@"name":textField.text};
     */
    
    if (searchArr.count == 0) {
        
        searchArr = [NSMutableArray arrayWithObject:searchDict];
        
    } else {
        
        //去重
        
        for (int i = 0; i < searchArr.count; i++) {
            
            NSDictionary *dict = searchArr[i];
            
            if ([searchDict[@"id"] isEqual:dict[@"id"]]) {
                
                [searchArr removeObjectAtIndex:i];
                
            }
            
        }
        
        [searchArr insertObject:searchDict atIndex:0];
        
        if (searchArr.count > 10) {
            
            [searchArr removeLastObject];
            
        }
    }
    
    [searchArr writeToFile:fileName atomically:YES];
}

- (void)searchContentData:(NSString *)textData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *str = [HTTPHelper StringEncode:textData];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarIntelSearch.do?pageNo=1&pageSize=10&wd=%@",[HTTPHelper StringEncode:str]];
    
//    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CTSearchController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        myself.searchData = [NSMutableArray arrayWithArray:responseObject];
        
        [myself.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MyLog(@"%@",error);
    }];
}

#pragma mark - tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.indicator == 0) {
        return self.historyData.count;
    } else {
        
        return self.searchData.count;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger subs = cell.contentView.subviews.count;
    SearchCell *searchCell;
    if (subs > 0) {
        searchCell = (SearchCell *)cell.contentView.subviews[0];
    } else {
        searchCell = [[SearchCell alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        [cell.contentView addSubview:searchCell];
    }
    
    
    
    if (self.indicator == 0) {
        NSDictionary *dict = self.historyData[indexPath.row];
        searchCell.contentDict = dict;
    } else {
        NSDictionary *dict = self.searchData[indexPath.row];
        searchCell.contentDict = dict;
    }
    return cell;
}

#pragma mark - tableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([(NSString *)self.searchText.text isEqualToString:@""]) {
        
        [self.searchText endEditing:YES];
        //跳转到车系详情页
        NSDictionary *dict = self.historyData[indexPath.row];
        
        //把搜索条件写进文件里面
        [self writeToPlist:dict];
        
        CarSeriesController *carSeriesVc = [[CarSeriesController alloc]initWithSeriesDict:dict];
        
        [self.navigationController pushViewController:carSeriesVc animated:YES];
        
    } else {
        
        [self.searchText endEditing:YES];
        //跳转到车系详情页
        NSDictionary *dict = self.searchData[indexPath.row];
        
        NSDictionary *carSeriesDict = @{@"id":dict[@"id"],
                                        @"guidePrice":dict[@"guidePrice"],
                                        @"name":dict[@"name"],
                                        @"brandLogo":dict[@"brandImagePath"],
                                        @"brandId":dict[@"brandId"],
                                        @"brandName":dict[@"brandName"],
                                        @"imgPath":dict[@"imgPath"]
                                        };
        
        //把搜索条件写进文件里面
        [self writeToPlist:carSeriesDict];
        
        CarSeriesController *carSeriesVc = [[CarSeriesController alloc]initWithSeriesDict:carSeriesDict];
        
        [self.navigationController pushViewController:carSeriesVc animated:YES];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.indicator == 0) {
        UIView *secView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        secView.backgroundColor = MainBackGroundColor;
        
        UILabel *secLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 30)];
        secLabel.font = [UIFont systemFontOfSize:14];
        secLabel.text = @"最近搜索";
        [secView addSubview:secLabel];
        return secView;

    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.indicator == 0) {
        return 30;
    } else {
        return 0;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (self.indicator == 0 && self.historyData.count) {
        
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerTap)];
        [footerView addGestureRecognizer:tap];
        footerView.backgroundColor = MainWhiteColor;
        
        UILabel *clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 40)];
        clearLabel.textAlignment = NSTextAlignmentLeft;
        clearLabel.backgroundColor = [UIColor clearColor];
        clearLabel.text = @"清空历史记录";
        clearLabel.font = [UIFont systemFontOfSize:16];
        [footerView addSubview:clearLabel];
        
        UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 39, ScreenWidth, 1)];
        spliteLine.backgroundColor = MainLineGrayColor;
        [footerView addSubview:spliteLine];
        
        return footerView;
    } else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.indicator == 0 && self.historyData.count > 0) {
        return 30;
    } else {
        return 0;
    }
}

- (void)footerTap {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清空历史" message:@"您确定要清空历史记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清空", nil];
    alert.delegate = self;
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        //取消
        
    } else if (buttonIndex == 1) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:@"searchHistory.plist"];
        BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
        if (bRet) {
            //
            NSError *err;
            [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
            self.historyData = nil;
            [MBProgressHUD showSuccess:@"清空历史记录成功"];
            [self.tableView reloadData];
            
        } else {
            [MBProgressHUD showSuccess:@"清空历史记录失败"];
        }
        
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchText resignFirstResponder];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
