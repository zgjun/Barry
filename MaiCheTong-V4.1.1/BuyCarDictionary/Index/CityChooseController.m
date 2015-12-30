//
//  CityChooseController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-17.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "CityChooseController.h"
#import "AFNetworking.h"
#import "MBProgressHUD+GJ.h"


#define IndexHeight 30
#define RowHeight 44

#define CarBrandIndexWidth 40

@interface CityChooseController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic,strong) __block NSArray *cityArrays;

@property (nonatomic,strong) __block NSArray *hotCityArrays;


@property (nonatomic,strong) __block NSArray *letters;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,weak) UITableView *tableView;


@property (nonatomic,weak) UITableView *lettersTableView;

@end

@implementation CityChooseController

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
    
    
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
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
    
    titleLabel.text = @"城市";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    /*
    
    self.navigationItem.title = @"城市";
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth - CarBrandIndexWidth, ScreenHeight + 49)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
    
    //自定义表头
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, RowHeight)];
    UILabel *locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, RowHeight)];
    
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:kGPRSCityNameKey];
    if (city == nil) {
        locationLabel.text = @"北京";
    } else {
        locationLabel.text = city;
     }
    [headView addSubview:locationLabel];
    
    UILabel *GPRSLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 0, 200, RowHeight)];
    GPRSLabel.text = @"GPRS定位";
    [headView addSubview:GPRSLabel];
    
    self.tableView.tableHeaderView = headView;
    
    
    //设置返回按钮
    
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
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth - CarBrandIndexWidth, ScreenHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
    
    //自定义表头
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, RowHeight)];
    UILabel *locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, RowHeight)];
    
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:kGPRSCityNameKey];
    if (city == nil) {
        locationLabel.text = @"北京";
    } else {
        locationLabel.text = city;
    }
    [headView addSubview:locationLabel];
    
    UILabel *GPRSLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 0, 200, RowHeight)];
    GPRSLabel.text = @"GPRS定位";
    [headView addSubview:GPRSLabel];
    
    self.tableView.tableHeaderView = headView;
    
    
    //表格注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CityChooseCell"];
    //设置self.tableView.tag = 0;
    self.tableView.tag = 0;
    
    
    [MBProgressHUD showHUDAddedTo: self.tableView animated:YES];
    
    UITableView *lettersTableView = [[UITableView alloc]initWithFrame:CGRectMake(ScreenWidth - CarBrandIndexWidth, 100, CarBrandIndexWidth, ScreenHeight - 100 - 64)];
    lettersTableView.showsVerticalScrollIndicator = NO;
    self.lettersTableView = lettersTableView;
    lettersTableView.tag = 1;
    lettersTableView.dataSource = self;
    lettersTableView.delegate = self;
    [lettersTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LettersCell"];
    lettersTableView.backgroundColor = [UIColor clearColor];
    lettersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:lettersTableView];
    
    
    [self getCityData];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
//     self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
}

/** 获取城市数据 */
- (void)getCityData {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = @"http://dealer.chexun.com/api/GetCityInfo.ashx?Hot=1";
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    __weak CityChooseController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *cityDict = responseObject;
        
        myself.cityArrays = cityDict[@"general"];
        myself.hotCityArrays = cityDict[@"hotcity"];
        myself.letters = [cityDict[@"Letter"] componentsSeparatedByString:@","];
        
        
        //把上面的品牌数组，变成二维数组
        NSMutableArray *sections = [NSMutableArray array];
        for (int i = 1; i < myself.letters.count; i++) {
            
            NSString *letter = myself.letters[i];
            NSMutableArray *cells = [NSMutableArray array];
            for (int j = 0; j < myself.cityArrays.count; j++) {
                
                NSDictionary *dictLetter = myself.cityArrays[j];
                if ([letter isEqualToString: dictLetter[@"Letter"]]) {
                    
                    [cells addObject:dictLetter];
                }
            }
            
            [sections addObject:cells];
        }
        
        myself.cityArrays = sections;
        
        [myself.tableView reloadData];
        [myself.lettersTableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView  animated:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView  animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        

    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        
        if (section == 0) {
            return self.hotCityArrays.count;
        } else {
            NSArray *arr = self.cityArrays[section - 1];
            return arr.count;
        }
    } else {
        return self.letters.count;
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == 0) {
        
        return self.letters.count;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 0) {
        
        static NSString *ID = @"CityChooseCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section == 0) {
            NSDictionary *dict = self.hotCityArrays[indexPath.row];
            cell.textLabel.text = dict[@"cityName"];
        } else {
            NSArray *citySection = self.cityArrays[indexPath.section - 1];
            NSDictionary *dict = citySection[indexPath.row];
            cell.textLabel.text = dict[@"cityName"];
        }
        
        return cell;
    } else {
        static NSString *LetterID = @"LettersCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LetterID forIndexPath:indexPath];
        
        cell.contentView.backgroundColor = MainBackGroundColor;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSInteger subviewsCount = cell.contentView.subviews.count;
        
        if (subviewsCount > 0) {
            //在这里只能用上面的forin,而不能用下面的for循环
            
            for (UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
        
        UILabel *letterLabel = [[UILabel alloc]initWithFrame:cell.bounds];
        letterLabel.backgroundColor = [UIColor clearColor];
        letterLabel.textAlignment = NSTextAlignmentCenter;
        letterLabel.font = [UIFont systemFontOfSize:16];
        letterLabel.text = self.letters[indexPath.row];
        [cell.contentView addSubview:letterLabel];
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
    
}


#pragma mark - tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        
        return IndexHeight;
    } else {
        return 0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return RowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView.tag == 0) {
        UIView *letterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, IndexHeight)];
        
        letterView.backgroundColor = MainBackGroundColor;
        
        UILabel *letterLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, ScreenWidth - 10, IndexHeight)];
        if (section == 0) {
            letterLabel.text = @"热门城市";
        } else {
            letterLabel.text = self.letters[section];
        }
        
        [letterView addSubview:letterLabel];
        
        return letterView;
    } else {
        return nil;
    }
    

}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return self.letters;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {
        NSDictionary *cityDict;
        if ([self.cityDelegate respondsToSelector:@selector(didCityTableRowClick:infoDict:)] && indexPath.section == 0) {
            cityDict = self.hotCityArrays[indexPath.row];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:cityDict[@"cityId"] forKey:kDefaultCityIDKey];
            [[NSUserDefaults standardUserDefaults] setObject:cityDict[@"cityName"] forKey:kDefaultCityNameKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.cityDelegate didCityTableRowClick:self infoDict:self.hotCityArrays[indexPath.row]];
        } else {
            cityDict = self.cityArrays[indexPath.section - 1][indexPath.row];
            
            [[NSUserDefaults standardUserDefaults] setObject:cityDict[@"cityId"] forKey:kDefaultCityIDKey];
            [[NSUserDefaults standardUserDefaults] setObject:cityDict[@"cityName"] forKey:kDefaultCityNameKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.cityDelegate didCityTableRowClick:self infoDict:self.cityArrays[indexPath.section - 1][indexPath.row]];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:indexPath.row];
        [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}


@end
