//
//  LoveCarController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-17.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "LoveCarController.h"
#import "HistoryCell.h"
#import "CarSeriesController.h"


@interface LoveCarController ()<UITableViewDataSource,UITableViewDelegate,HistoryCellDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSArray *loveCars;

@property (nonatomic,weak) UITableView *tableView;

@end

@implementation LoveCarController

- (instancetype)initWithLoveCars:(NSArray *)loveCars {
    if (self = [super init]) {
        self.loveCars = loveCars;
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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, 20, 150, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"您可能喜欢的车型";
    
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LoveCarCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = MainBackGroundColor;
    
    /*
    
    //设置标题
    self.navigationItem.title = @"您可能喜欢的车型";
    
    //返回按钮
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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
}

- (void)doBack {
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.loveCars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"LoveCarCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    HistoryCell *historyCell = [[HistoryCell alloc]init];
    historyCell.frame = cell.bounds;
    historyCell.delegate = self;
    historyCell.historyCellDict = self.loveCars[indexPath.row];
    
    [cell.contentView addSubview:historyCell];
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)historyCellClick:(HistoryCell *)historyCell {
    
    NSDictionary *dictList = historyCell.historyCellDict;
    
    NSString *hq = @"";
    if (dictList[@"hq"] != nil) {
        hq = dictList[@"hq"];
    }
    
    
    NSDictionary *carSeriesDict = @{@"id":dictList[@"id"],
                                    @"hq":hq,
                                    @"imgPath":dictList[@"imgPath"],
                                    @"hqurl":dictList[@"hqurl"],
                                    @"guidePrice":dictList[@"guidePrice"],
                                    @"name":dictList[@"name"],
                                    };
    
    
    CarSeriesController *carSeriesVc = [[CarSeriesController alloc]initWithSeriesDict:carSeriesDict];
    
    [self.navigationController pushViewController:carSeriesVc animated:YES];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
