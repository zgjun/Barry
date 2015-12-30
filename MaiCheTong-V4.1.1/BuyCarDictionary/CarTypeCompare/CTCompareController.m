//
//  CTCompareController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "CTCompareController.h"
#import "NoHighLightBtn.h"
#import "CompareCell.h"
#import "CanBuyCell.h"
#import "CarTypeHistoryController.h"
#import "CTCompareResultController.h"
#import "UIImage+Extension.h"
#import "MainTabBarController.h"
#import "MBProgressHUD+GJ.h"

#import "CompareBrandController.h"
#import "WXApi.h"
#import "UINavigationController+YRBackGesture.h"

#define CanBuyHeight 20

#define CompareBtnHeight 51
#define NavHeight 64
#define ShowNumViewHeight 49
#define TableHeight (ScreenHeight - CompareBtnHeight - ShowNumViewHeight - 64 - ShowGap)
#define ShowGap 10
#define CompareBtnWidth 130

@interface CTCompareController ()<UITableViewDataSource,UITableViewDelegate,CompareCellDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>
{
    enum WXScene _scene;
}
@property (nonatomic,weak) UIButton *historyBtn;

@property (nonatomic,weak) UIButton *compareResultBtn;

@property (nonatomic,weak) UIButton *editBtn;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *compareCars;

@property (nonatomic,assign) NSInteger editState;

///显示数字
@property (nonatomic,weak) UILabel *showNumLabel1;

@property (nonatomic,strong) NSMutableArray *prepareCars;

@property (nonatomic,strong) NSArray *historyCars;

@property (nonatomic,weak) NoHighLightBtn *compareBtn;

@property (nonatomic,weak) UIButton *friendHelpBtn;

@property (nonatomic,strong) CarTypeHistoryController *carTypeVc;

@property (nonatomic,strong) CTCompareResultController *ctCompareVc;

@property (nonatomic,strong) CompareBrandController *compareBrandVc;

@property (nonatomic,strong) NSMutableArray *compareCarIds;

@property (nonatomic,weak) UIView *noDataView;

@end

@implementation CTCompareController

- (NSMutableArray *)compareCarIds {
    
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    NSArray *arr = [[NSArray alloc]initWithContentsOfFile:fileName];
    
    _compareCarIds = [NSMutableArray array];
    for (int i = 0; i < arr.count; i++) {
        NSDictionary *dict = arr[i];
        if ([dict[@"compareState"] integerValue] == 1) {
            [_compareCarIds addObject:dict[@"carTypeId"]];
        }
    }
    
    return _compareCarIds;
}

- (NSArray *)historyCars {
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"typeHistory.plist"];
    //先读取之前的历史记录
    _historyCars = [[NSArray alloc]initWithContentsOfFile:fileName];
    return _historyCars;
}

- (NSMutableArray *)prepareCars {
    _prepareCars = [NSMutableArray array];
    
    for (int i = 0; i < self.compareCars.count; i++) {
        NSDictionary *prepareDict = self.compareCars[i];
        if ([prepareDict[@"compareState"] integerValue] == 1) {
            [_prepareCars addObject:prepareDict];
        }
    }
    
    return _prepareCars;
}

- (NSMutableArray *)compareCars {
    _compareCars = [NSMutableArray array];
    
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    //先读取之前的历史记录
    _compareCars = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    
//    for (int i = 0; i < arrM.count; i++) {
//        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:arrM[i]];
//        [dictM setValue:@0 forKey:@"compareState"];
//        [_compareCars addObject:dictM];
//    }
    return _compareCars;
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
    
    self.navigationController.enableBackGesture = NO;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    
    self.editState = 0;
    
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
    titleLabel.text = @"车型对比";
    [navView addSubview:titleLabel];
    
    
    UIButton *historyBtn = [[UIButton alloc]init];
    self.historyBtn = historyBtn;
    if (self.historyCars.count == 0) {
        historyBtn.enabled = NO;
    } else {
        historyBtn.enabled = YES;
    }
    historyBtn.frame = CGRectMake(ScreenWidth - 44, 20, 44, 44);
    [historyBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_historyicon_black"] forState:UIControlStateNormal];
    
    [historyBtn addTarget:self action:@selector(historyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:historyBtn];
    
    
    //对比按钮
    NoHighLightBtn *compareBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(navView.frame), ScreenWidth, CompareBtnHeight)];
    self.compareBtn = compareBtn;
    [compareBtn setImage:[UIImage imageNamed:@"chexun_addicon"] forState:UIControlStateNormal];
    [compareBtn addTarget:self action:@selector(compareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    compareBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [compareBtn setTitle:@"添加对比" forState:UIControlStateNormal];
    [compareBtn setTitleColor:MainWhiteColor forState:UIControlStateNormal];
    [compareBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_okbutbg"] forState:UIControlStateNormal];
    [self.view addSubview:compareBtn];
    
    [self createChildViews];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)compareBtnClick {
    CompareBrandController *compareBrandVc = [[CompareBrandController alloc]init];
    self.compareBrandVc = compareBrandVc;
    [self.navigationController pushViewController:compareBrandVc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;
    
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
    
    if (self.historyCars.count == 0) {
        self.historyBtn.enabled = NO;
    } else {
        self.historyBtn.enabled = YES;
    }
    
    self.showNumLabel1.text = [NSString stringWithFormat:@"%@",@(self.prepareCars.count)];
    
    if (self.prepareCars.count < 2) {
        self.compareResultBtn.enabled = NO;
    } else {
        self.compareResultBtn.enabled = YES;
    }
    
    if (self.compareCars.count > 0) {
        self.tableView.hidden = NO;
        self.noDataView.hidden = YES;
    } else {
        self.tableView.hidden = YES;
        self.noDataView.hidden = NO;
    }
    
    [self.tableView reloadData];
}

- (void)editBtnClick:(UIButton *)editBtn {
    
    if (editBtn.selected) {
        self.tableView.editing = NO;
    } else {
        
        self.tableView.editing = YES;
    }
    
    editBtn.selected = !editBtn.selected;
    
}

- (void)historyBtnClick:(UIButton *)historyBtn {
    //创建一个历史记录视图
    CarTypeHistoryController *carTypeVc = [[CarTypeHistoryController alloc]initWithHistoryCars:self.historyCars];
    self.carTypeVc = carTypeVc;
    [self.navigationController pushViewController:carTypeVc animated:YES];
    
}

- (void)createChildViews {
    
    //添加无数据视图
    UIView *noDataView = [[UIView alloc]initWithFrame:CGRectMake((ScreenWidth - 100) * 0.5, (TableHeight - 110) * 0.5, 100, 110)];
    self.noDataView = noDataView;
    noDataView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:noDataView];
    UIImageView *noDataImage = [[UIImageView alloc] initWithFrame:CGRectMake((100 - 72) * 0.5, 0, 72, 73)];
    noDataImage.image = [UIImage imageNamed:@"chexun_other_addicon"];
    [noDataView addSubview:noDataImage];
    UILabel *noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(noDataImage.frame) + 7, 100, 30)];
    noDataLabel.font = [UIFont systemFontOfSize:16];
    noDataLabel.text = @"请您添加车型";
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.textColor = MainLineGrayColor;
    [noDataView addSubview:noDataLabel];
    
    //添加表格
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.compareBtn.frame) + ShowGap, ScreenWidth, TableHeight)];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    //注册单元格
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CTCompareCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
//    self.tableView.editing = YES;
    [self.view addSubview:tableView];
    
    
    if (self.compareCars.count > 0) {
        self.tableView.hidden = NO;
        self.noDataView.hidden = YES;
    } else {
        self.tableView.hidden = YES;
        self.noDataView.hidden = NO;
    }
    
    //添加显示view
    UIImageView *showNumView = [[UIImageView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(tableView.frame), ScreenWidth, ShowNumViewHeight)];
    showNumView.userInteractionEnabled = YES;
    showNumView.image = [UIImage resizableImageWithName:@"chexun_navbarbg"];
    [self.view addSubview:showNumView];
    
    
    UILabel *showNumLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(ShowGap, ShowGap, 10, ShowNumViewHeight - ShowGap * 2)];
    
    self.showNumLabel1 = showNumLabel1;
    showNumLabel1.textAlignment = NSTextAlignmentCenter;
    showNumLabel1.textColor = MainGoldenColor;
    showNumLabel1.font = [UIFont systemFontOfSize:16];
    showNumLabel1.text = [NSString stringWithFormat:@"%@",@(self.prepareCars.count)];
    
    [showNumView addSubview:showNumLabel1];
    
    
    UILabel *showNumLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(showNumLabel1.frame), ShowGap, 10, ShowNumViewHeight - ShowGap * 2)];
    showNumLabel2.textColor = MainGoldenColor;
    showNumLabel2.font = [UIFont systemFontOfSize:16];
    showNumLabel2.textAlignment = NSTextAlignmentCenter;
    showNumLabel2.text = @"/";
    
    [showNumView addSubview:showNumLabel2];
    
    
    UILabel *showNumLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(showNumLabel2.frame), ShowGap, 10, ShowNumViewHeight - ShowGap * 2)];
    showNumLabel3.textColor = MainGoldenColor;
    showNumLabel3.font = [UIFont systemFontOfSize:16];
    showNumLabel3.textAlignment = NSTextAlignmentCenter;
    showNumLabel3.text = @"5";
    
    [showNumView addSubview:showNumLabel3];
    
    
    UIButton *compareResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    compareResultBtn.frame = CGRectMake( (ScreenWidth - CompareBtnWidth) * 0.5 - 30, ShowGap * 0.5, CompareBtnWidth, ShowNumViewHeight - ShowGap);
    
    if (self.prepareCars.count >= 2) {
        compareResultBtn.enabled = YES;
    } else {
        compareResultBtn.enabled = NO;
    }
    [compareResultBtn setTitleColor:MainWhiteColor forState:UIControlStateNormal];
    [compareResultBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_button1"] forState:UIControlStateNormal];
    [compareResultBtn setBackgroundImage:[UIImage resizableImageWithName:@"checun_tabbg2_selected"] forState:UIControlStateDisabled];
    
    self.compareResultBtn = compareResultBtn;
    [compareResultBtn setTitle:@"开始对比" forState:UIControlStateNormal];
    [compareResultBtn addTarget:self action:@selector(compareResultClick) forControlEvents:UIControlEventTouchUpInside];
    compareResultBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [showNumView addSubview:compareResultBtn];
    
    
    UIButton *friendHelpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendHelpBtn.frame = CGRectMake( ScreenWidth - 90 - ShowGap, ShowGap * 0.5, 90, ShowNumViewHeight - ShowGap);
    [friendHelpBtn setTitleColor:MainGoldenColor forState:UIControlStateNormal];
//    if (self.prepareCars.count >= 2) {
//        friendHelpBtn.enabled = YES;
//    } else {
//        friendHelpBtn.enabled = NO;
//    }
    
    [friendHelpBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_button2"] forState:UIControlStateNormal];
//    [friendHelpBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_button2"] forState:UIControlStateDisabled];
    friendHelpBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.friendHelpBtn = friendHelpBtn;
    [friendHelpBtn setTitle:@"朋友帮选车" forState:UIControlStateNormal];
    [friendHelpBtn addTarget:self action:@selector(friendHelpBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [showNumView addSubview:friendHelpBtn];
    
}

- (void)friendHelpBtnClick {
    
    if (self.compareCarIds.count == 0) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                              
                                                        message:@"没有分享的车型"
                              
                                                       delegate:nil
                              
                                              cancelButtonTitle:@"确定"
                              
                                              otherButtonTitles:nil];
        
        
        
        [alert show];
        
        return;
        
    }
    
    //http://3g.chexun.com/app/modelshare.aspx?modelIds=115360,115361,115366,115365&os=ios
    
    if (self.compareCarIds.count > 0) {
        //弹出actionsheet进行选择分享到哪
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"分享"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"分享给朋友", @"分享到朋友圈",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
        
    } else {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请选择对比车型！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        return;
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//分享给朋友
        _scene = WXSceneSession;
        [self shareCompareType:buttonIndex];
    }else if (buttonIndex == 1) {//分享到朋友圈
        _scene = WXSceneTimeline;
        [self shareCompareType:buttonIndex];
    }
}

/*
 朋友帮选车：
 1、微信好友
 标题文案：选择性障碍了，亲快帮我选一辆
 图标：第一个车系图标图片
 内容文案：车系+车型名称1，车系+车型名称2，车系+车型名称3...
 2、微信朋友圈
 文案：我要买车，可我选择性障碍了，亲们快帮我挑挑吧？车系+车型名称1，车系+车型名称2
 */
- (void)shareCompareType:(NSInteger)type {
    NSMutableString *urlStrM = [NSMutableString stringWithFormat:@"?modelIds="];
    NSMutableString *carStrsM = [NSMutableString string];
    for (int i = 0; i < self.compareCarIds.count; i++) {
        NSDictionary *dict = self.compareCars[i];
        if (i == self.compareCarIds.count - 1) {
            [urlStrM appendString:[NSString stringWithFormat:@"%@",self.compareCarIds[i]]];
            [carStrsM appendString:[NSString stringWithFormat:@"%@ %@ ！",dict[@"carSeriesName"],dict[@"carTypeName"]]];
        } else {
            [urlStrM appendString:[NSString stringWithFormat:@"%@,",self.compareCarIds[i]]];
            
            [carStrsM appendString:[NSString stringWithFormat:@"%@ %@,",dict[@"carSeriesName"],dict[@"carTypeName"]]];
        }
    }
    
    
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"http://3g.chexun.com/app/modelshare.aspx%@&os=ios",urlStrM];
    
    if (type == 0) {
        message.title = @"选择性障碍了，亲快帮我选一辆";
        message.description = [NSString stringWithFormat:@"%@",carStrsM];;
        [message setThumbImage:[UIImage imageNamed:@"shareIcon"]];
    } else {
        message.title = [NSString stringWithFormat:@"我要买车，可我选择性障碍了，亲们快帮我挑挑吧？%@",carStrsM];
        [message setThumbImage:[UIImage imageNamed:@"shareIcon"]];
    }
    
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    [WXApi sendReq:req];
}


- (void)compareResultClick {
    NSMutableString *screenCondition = [NSMutableString stringWithFormat:@"?modelIds="];
    NSMutableArray *arrM = [NSMutableArray array];
    NSMutableArray *carsM = [NSMutableArray array];
    for (int i = 0; i < self.prepareCars.count; i++) {
        NSDictionary *prepareDict = self.prepareCars[i];
        [screenCondition appendString:[NSString stringWithFormat:@"%@,",prepareDict[@"carTypeId"]]];
        
        [arrM addObject:prepareDict[@"carTypeId"]];
        [carsM addObject:prepareDict];
    }
    [screenCondition deleteCharactersInRange:NSMakeRange(screenCondition.length - 1, 1)];
    
    
    CTCompareResultController *ctCompareVc = [[CTCompareResultController alloc]initWithCarTypeArrs:carsM CarTypeIds:screenCondition];
    self.ctCompareVc = ctCompareVc;
    [self.navigationController pushViewController:ctCompareVc animated:YES];
    
    
}



#pragma mark - tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.compareCars.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CTCompareCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    CompareCell *compareCell = [[CompareCell alloc]initWithSelectCount:self.prepareCars.count];
    
    compareCell.delegate = self;
    
    compareCell.tag = indexPath.row;
    
    compareCell.frame = CGRectMake(0, 0, ScreenWidth, 71);
    
    NSDictionary *dict = self.compareCars[indexPath.row];
    
    compareCell.compareDict = dict;
    
    compareCell.isSelected = [dict[@"compareState"] integerValue];
    
    
    [cell.contentView addSubview:compareCell];
    
    
    return cell;
}

#pragma mark - tableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71;
}



#pragma mark - compareDelegate
- (void)compareCellClick:(CompareCell *)compareCell {
    
    NSDictionary *compareDict = compareCell.compareDict;
    NSMutableArray *compareArrM = self.compareCars;
    
    
    for (int i = 0; i < compareArrM.count; i++) {
        NSMutableDictionary *dict = compareArrM[i];
        if ([compareDict[@"carTypeId"] integerValue] == [dict[@"carTypeId"] integerValue]) {
            [dict setObject:@(compareCell.isSelected) forKey:@"compareState"];
            [self writeNewData:compareArrM];
            break;
        }
    }
    
    [self.tableView reloadData];
    
    if (self.prepareCars.count < 2) {
        self.compareResultBtn.enabled = NO;
//        self.friendHelpBtn.enabled = NO;
    } else {
        self.compareResultBtn.enabled = YES;
//        self.friendHelpBtn.enabled = YES;
    }
    
    self.showNumLabel1.text = [NSString stringWithFormat:@"%@",@(self.prepareCars.count)];
    
}


//返回编辑状态的style
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//完成编辑的触发事件
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *compareCarArrM = [NSMutableArray arrayWithArray:self.compareCars];
        NSDictionary *dict = compareCarArrM[indexPath.row];
        
        for (int i = 0; i < self.prepareCars.count; i++) {
            NSDictionary *prepareDict = self.prepareCars[i];
            
            if ([dict[@"carTypeId"] isEqual:prepareDict[@"carTypeId"]]) {
                [self.prepareCars removeObject:prepareDict];
                
                
                break;
            }
        }
        
        [compareCarArrM removeObjectAtIndex: indexPath.row];
        
        [self writeNewData:compareCarArrM];
        
        self.showNumLabel1.text = [NSString stringWithFormat:@"%@",@(self.prepareCars.count)];
        
        
        if (self.prepareCars.count < 2) {
            self.compareResultBtn.enabled = NO;
//            self.friendHelpBtn.enabled = NO;
        } else {
            self.compareResultBtn.enabled = YES;
//            self.friendHelpBtn.enabled = YES;
        }
        
        if (self.compareCars.count > 0) {
            self.tableView.hidden = NO;
            self.noDataView.hidden = YES;
        } else {
            self.tableView.hidden = YES;
            self.noDataView.hidden = NO;
        }
        
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
        
        [tableView reloadData];
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
