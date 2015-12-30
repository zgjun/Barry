//
//  CarTypeHistoryController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarTypeHistoryController.h"
#import "CanBuyCell.h"


@interface CarTypeHistoryController ()<CanBuyCellDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSArray *historyCars;

@property (nonatomic,weak) UIButton *cleanBtn;

@property (nonatomic,strong) NSMutableArray *compareCars;

@property (nonatomic,weak) UITableView *tableView;

@end

@implementation CarTypeHistoryController

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

- (instancetype)initWithHistoryCars:(NSArray *)historyCars {
    if (self = [super init]) {
        self.historyCars = historyCars;
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
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HistoryCarCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = MainBackGroundColor;
    
    /*
    //设置标题
    self.navigationItem.title = @"我浏览过的车型";
    
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
    
    
    //清空按钮
    UIButton *cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cleanBtn addTarget:self action:@selector(cleanClick:) forControlEvents:UIControlEventTouchDown];
    self.cleanBtn = cleanBtn;
    cleanBtn.frame = CGRectMake(0, 0, 50, 44);
    cleanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    cleanBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [cleanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cleanBtn setTitle:@"清空" forState:UIControlStateNormal];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:cleanBtn];
    
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -10;
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer1, rightBtn];
     */
    
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)cleanClick:(UIButton *)cleanBtn {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:@"typeHistory.plist"];
    BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
    if (bRet) {
        NSError *err;
        [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
        self.historyCars = nil;
        cleanBtn.enabled = NO;
        [self.tableView reloadData];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyCars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"HistoryCarCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    CanBuyCell *canBuyCell = [[CanBuyCell alloc]initWithSelectCount:self.compareCars.count];
    canBuyCell.frame = cell.bounds;
    canBuyCell.canBuyDict = self.historyCars[indexPath.row];
    canBuyCell.delegate = self;
    
    for (int i = 0; i < self.compareCars.count; i++) {
        NSDictionary *beforeDict = self.compareCars[i];
        if ([beforeDict[@"carTypeId"] isEqual:canBuyCell.canBuyDict[@"carTypeId"]]) {
            canBuyCell.isSelected = 1;
        }
    }
    
    [cell.contentView addSubview:canBuyCell];
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71;
}

#pragma mark - canBuyDelegate
- (void)canBuyCellClick:(CanBuyCell *)canBuyCell {
    if (canBuyCell.isSelected == 1) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:canBuyCell.canBuyDict];
        
        [dict setObject:@0 forKey:@"compareState"];
        
        NSMutableArray *compareCarsM = [NSMutableArray arrayWithArray:self.compareCars];
        
        [compareCarsM addObject:dict];
        
        [self writeNewData:compareCarsM];
        
    } else {
        for (int i = 0; i < self.compareCars.count; i++) {
            NSDictionary *dict = self.compareCars[i];
            NSDictionary *dictCell = canBuyCell.canBuyDict;
            if ([dict[@"carTypeId"] isEqual:dictCell[@"carTypeId"]]) {
                NSMutableArray *deleteM = self.compareCars;
                [deleteM removeObject:dict];
                [self writeNewData:deleteM];
                break;
            }
        }
    }
    [self.tableView reloadData];
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
