//
//  CTCompareResultController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CTCompareResultController.h"
#import "NoHighLightBtn.h"
#import "ParameterTableView.h"
#import "ParameterScrollView.h"
#import "FriendHelpButton.h"
#import "AFNetworking.h"
#import "ParameterCell.h"
#import "CompareCarTypeView.h"
#import "BrandControl.h"
#import "MBProgressHUD+GJ.h"
#import "PriceContentView.h"
#import "FriendHelpButton.h"
#import "CTParaChooseController.h"
#import "WXApi.h"
#import "ZS_PageControl.h"

#import "MainTabBarController.h"
#import "UIImage+Extension.h"


#define WrongNum -1000


#define CTNavBarHeight 64
#define CTTopViewHeight 110
#define CTBottomViewHeight (ScreenHeight - CTTopViewHeight - CTNavBarHeight - 60)
#define CTTitleBarWidth 80
#define CTCellWidth (ScreenWidth - CTTitleBarWidth) * 0.5
#define CTCellHeight 45
#define CTBigCellHeight 60
#define CTSectionHeight 20
#define CTCarTypeHeight 90

@interface CTCompareResultController ()<UITableViewDataSource,UITableViewDelegate,CompareCarTypeViewDelegate,MBProgressHUDDelegate,CTParaChooseControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>
{
    enum WXScene _scene;
}
///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,weak) UIButton *chooseBtn;

@property (nonatomic,strong) NSArray *carTypeArrs;

@property (nonatomic,strong) NSString *carTypeIds;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,weak) ZS_PageControl *brandControl;

@property (nonatomic,weak) ParameterScrollView *carTypeScrollView;

@property (nonatomic,weak) UIView *bottomView;

@property (nonatomic,weak) UIView *carTypeView;

@property (nonatomic,weak) ParameterScrollView *contentScrollView;

@property (nonatomic,weak) ParameterTableView *navTableView;

@property (nonatomic,weak) ParameterTableView *contentTableView;

@property (nonatomic,strong) NSMutableArray *showLabels;

@property (nonatomic,weak) UILabel *loadLabel;


@property (nonatomic,strong) NSArray *headData;

@property (nonatomic,strong) NSMutableArray *titleData;

@property (nonatomic,strong) NSArray *sectionData;

@property (nonatomic,strong) NSMutableArray *contentData;

@property (nonatomic,strong) NSMutableArray *contentDifData;

@property (nonatomic,strong) NSDictionary *screenConditions;

@property (nonatomic,weak) NoHighLightBtn *showBtn;//显示全部

@property (nonatomic,weak) NoHighLightBtn *hiddenBtn;//隐藏相同

@property (nonatomic,strong) CTParaChooseController *paraChooseVc;

@property (nonatomic,strong) NSMutableArray *allCompareCars;

/*
 0:表示显示所有
 1:表示显示不同
 */
@property (nonatomic,assign) NSInteger showIndicator;

//创建厂商指导价和全国最低价标签
@property (nonatomic,weak) UIView *headPriceView;

@property (nonatomic,weak) ParameterScrollView *headPriceScrollView;

@property (nonatomic,weak) UIView *contentPriceView;

@property (nonatomic,strong) NSMutableArray *compareCarIds;

@property (nonatomic,assign) NSInteger carTypeCount;

@end

@implementation CTCompareResultController

///读取要对比的车

- (NSMutableArray *)allCompareCars {
    _allCompareCars = [NSMutableArray array];
    
    //从沙盒里面读取历史数据
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //拼接文件名
    
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    
    NSMutableArray *arrM = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    
    
    
    for (int i = 0; i < arrM.count; i++) {
        
        NSDictionary *dict = arrM[i];
        
        [_allCompareCars addObject:dict];
        
    }
    return _allCompareCars;
    
}




- (instancetype)initWithCarTypeArrs:(NSArray *)carTypeArrs CarTypeIds:(NSString *)carTypeIds{
    if (self = [super init]) {
        _scene = WXSceneTimeline;
        self.carTypeArrs = carTypeArrs;
        self.carTypeIds = carTypeIds;
        
    }
    return self;
}

- (NSMutableArray *)titleData {
    if (_titleData == nil) {
        _titleData = [NSMutableArray array];
    }
    return _titleData;
}

- (NSMutableArray *)showLabels {
    if (_showLabels == nil) {
        _showLabels = [NSMutableArray array];
    }
    return _showLabels;
}
/* 这里只是筛选出所有要对比的车型
//读取要对比的车的ID
- (NSMutableArray *)compareCarIds {
    
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    NSArray *arr = [[NSArray alloc]initWithContentsOfFile:fileName];
    
    _compareCarIds = [NSMutableArray array];
    for (int i = 0; i < arr.count; i++) {
        NSDictionary *dict = arr[i];
        [_compareCarIds addObject:dict[@"carTypeId"]];
    }
    
    return _compareCarIds;
}
*/

//这里是获得选中的对比车型
//读取要对比的车的ID
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
    
   
    
    //默认显示所有参数
    self.showIndicator = 0;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
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
    
    //设置导航栏上右边的按钮
    UIButton *chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [chooseBtn addTarget:self action:@selector(chooseBtnClick:) forControlEvents:UIControlEventTouchDown];
    self.chooseBtn = chooseBtn;
    chooseBtn.frame = CGRectMake(ScreenWidth - 44, 20 + 4, 35, 35);
    chooseBtn.imageView.contentMode = UIViewContentModeRight;
    [chooseBtn setImage:[UIImage imageNamed:@"chexun_menuicon_black"] forState:UIControlStateNormal];
    [chooseBtn setImage:[UIImage imageNamed:@"chexun_closeicon_gray"] forState:UIControlStateSelected];
    [navView addSubview:chooseBtn];
    
    
    //设置标题视图
    UIImageView *titleView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 188) * 0.5, 27, 188, 30)];
    titleView.userInteractionEnabled = YES;
    titleView.image = [UIImage imageNamed:@"chexun_models_tabbg"];
    NoHighLightBtn *hiddenBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(0, 0.5, 94, 29)];
    self.hiddenBtn = hiddenBtn;
    hiddenBtn.tag = 1;
    [hiddenBtn setTitle:@"隐藏相同" forState:UIControlStateNormal];
    
    [hiddenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [hiddenBtn setTitleColor:MainLineGrayColor forState:UIControlStateNormal];
    [hiddenBtn setBackgroundImage:[UIImage imageNamed:@"chexun_models_tableft_selected"] forState:UIControlStateSelected];
    //    [hiddenBtn setBackgroundImage:[UIImage imageNamed:@"chexun_pk_box_hengban"] forState:UIControlStateNormal];
    
    hiddenBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [hiddenBtn addTarget:self action:@selector(showOrHiddenClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleView addSubview:hiddenBtn];
    
    
    NoHighLightBtn *showBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(94, 0.5, 94, 29)];
    self.showBtn = showBtn;
    showBtn.tag = 2;
    showBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [showBtn setBackgroundImage:[UIImage imageNamed:@"chexun_models_tabright_selected"] forState:UIControlStateSelected];
    //    [showBtn setBackgroundImage:[UIImage imageNamed:@"chexun_pk_box_hengban"] forState:UIControlStateNormal];
    [showBtn setTitle:@"显示全部" forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showBtn setTitleColor:MainLineGrayColor forState:UIControlStateNormal];
    [showBtn addTarget:self action:@selector(showOrHiddenClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置初始选中
    showBtn.selected = YES;
    [titleView addSubview:showBtn];
    
    [navView addSubview:titleView];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    [self loadMainData];
    
}

- (void)loadMainData {
    
    //创建子视图
    [self createChildViews];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    
    
    //异步加载数据
    [self loadAsyncData];
}



/**右边筛选按钮的点击*/
- (void)chooseBtnClick:(UIButton *)chooseBtn {
    
    if (self.contentData.count == 0) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }
    
    chooseBtn.selected = !chooseBtn.selected;
    if (chooseBtn.selected) {
        CTParaChooseController *paraChooseVc = [[CTParaChooseController alloc]init];
        paraChooseVc.view.frame = CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64);
        paraChooseVc.delegate = self;
        self.paraChooseVc = paraChooseVc;
        [self.view addSubview:paraChooseVc.view];
    } else {
        [self.paraChooseVc.view removeFromSuperview];
        self.paraChooseVc = nil;
    }
}

- (void)loadAsyncData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarCompare.do%@",self.carTypeIds] ;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CTCompareResultController *myself = self;
    
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //回到主线程更新ui
        dispatch_async(dispatch_get_main_queue(), ^{
            [myself setViewData:responseObject];
            
            
            
            [myself.contentTableView reloadData];
            
            [myself.navTableView reloadData];
            
        });
        
        [MBProgressHUD hideAllHUDsForView:myself.navigationController.view  animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.navigationController.view animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
}
- (void)setViewData:(id)data {
    NSDictionary *dict0 = data[0];
    NSDictionary *dict1 = data[1];
    NSDictionary *paraDict = dict0[@"result"];
    //在这里重新对resultDict[@"paramtypeitems"]根据是否相同进行区分
    [self divideDifferentPara:paraDict[@"paramtypeitems"]];
    
    NSDictionary *configDict = dict1[@"result"];
    //在这里重新对resultDict[@"configtypeitems"]根据是否相同进行区分
    [self divideDifferentConfig:configDict[@"configtypeitems"]];
    
    
    //创建section head
    for (int i = 0; i < self.contentData.count; i++) {
        UILabel *showLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, ScreenWidth - CTTitleBarWidth, CTSectionHeight)];
        NSDictionary *paraDict = self.contentData[i];
        showLabel.text = paraDict[@"name"];
        showLabel.font = [UIFont systemFontOfSize:12];
        [self.showLabels addObject:showLabel];
    }
    
    NSDictionary *secDict = self.contentData[0];
    NSArray *secArr = secDict[@"paramitems"];
    NSDictionary *rowDic = secArr[0];
    NSArray *rowArr = rowDic[@"valueitems"];
    
    //厂商指导价
    NSDictionary *rowDic2 = secArr[2];
    NSArray *rowArr2 = rowDic2[@"valueitems"];
    //全国最低价
    NSDictionary *rowDic3 = secArr[3];
    NSArray *rowArr3 = rowDic3[@"valueitems"];
    
    self.contentTableView.frame = CGRectMake(0, 0, rowArr.count * CTCellWidth, CTBottomViewHeight);
    
    self.contentScrollView.contentSize = CGSizeMake(rowArr.count * CTCellWidth, 0);
    
    self.carTypeScrollView.contentSize = CGSizeMake(rowArr.count * CTCellWidth, 0);
    
    self.carTypeView.frame = CGRectMake(0, 0, rowArr.count * CTCellWidth, self.carTypeScrollView.height);
    
    self.headPriceScrollView.contentSize = CGSizeMake(rowArr.count * CTCellWidth, 0);
    
    self.contentPriceView.frame = CGRectMake(0, 0, rowArr.count * CTCellWidth, self.headPriceScrollView.height);
    
    //创建carTypeScrollView子视图
    
    for (int i = 0; i < rowArr.count; i++) {
        CompareCarTypeView *compareView = [[CompareCarTypeView alloc]init];
        NSMutableDictionary *carTypeDict = [NSMutableDictionary dictionaryWithDictionary:self.carTypeArrs[i]];
        NSDictionary *rowDict = rowArr[i];
        
        [carTypeDict setObject:rowDict[@"value"] forKey:@"carTypeName"];
        compareView.dataDict = carTypeDict;
        compareView.delegate = self;
        compareView.tag = i;
        compareView.frame = CGRectMake(i * CTCellWidth, 0, CTCellWidth, CTCarTypeHeight);
        [self.carTypeView addSubview:compareView];
    }
    //设置页码按钮
    self.brandControl.numberOfPages = rowArr.count % 2 ? (rowArr.count / 2 + 1) : rowArr.count / 2;
    self.brandControl.currentPage = 0;
    
    
    //创建headPriceScroll子视图
    for (int i = 0; i < rowArr.count; i++) {
        PriceContentView *priceContenView = [[PriceContentView alloc]init];
        NSDictionary *dict2 = rowArr2[i];
        
        NSDictionary *dict3 = rowArr3[i];
        
        NSDictionary *dataDict = @{@"companyPrice":dict2[@"value"],@"lowPrice":dict3[@"value"]};
        
        priceContenView.dataDict = dataDict;
        //        priceContenView.delegate = self;
        priceContenView.tag = i;
        priceContenView.frame = CGRectMake(i * CTCellWidth, 0, CTCellWidth, CTCarTypeHeight);
        [self.contentPriceView addSubview:priceContenView];
    }
}
///
- (void)divideDifferentPara:(NSArray *)allArr {
    
    NSMutableArray *allArrM = [NSMutableArray array];
    NSMutableArray *allArrDifM = [NSMutableArray array];
    for (int i = 0; i < allArr.count; i++) {
        NSDictionary *sectionDict = allArr[i];
        NSString *name = sectionDict[@"name"];
        NSArray *rowArr = sectionDict[@"paramitems"];
        
        NSMutableArray *secondArrM = [NSMutableArray array];
        NSMutableArray *secondArrDifM = [NSMutableArray array];
        for (int j = 0; j < rowArr.count; j++) {
            NSInteger inditor = 0;
            NSMutableArray *rowArrM = [NSMutableArray array];
            NSDictionary *secondDict = rowArr[j];
            NSString *paraName = secondDict[@"name"];
            NSString *paraId = [NSString stringWithFormat:@"%@",secondDict[@"id"]];
            NSArray *paraArr = secondDict[@"valueitems"];
            NSDictionary *rowDict0;
            NSString *rowStr0;
            NSDictionary *rowDict;
            NSString *rowStr;
            NSDictionary *dict;
            for (int k = 0; k < paraArr.count; k++) {
                /*内存溢出
                if (k == 0) {
                    rowDict0 = paraArr[0];
                    rowStr0 = [NSString stringWithFormat:@"%@",rowDict0[@"value"]];
                    dict = @{@"specid":[self dealNil:rowDict0[@"specid"]],@"value":[self dealNil:rowDict0[@"value"]]};
                    
                }
                 */
                if (k == 0) {
                    rowDict0 = paraArr[0];
                    rowStr0 = [NSString stringWithFormat:@"%@",rowDict0[@"value"]];
//                    dict = @{@"specid":[self dealNil:rowDict0[@"specid"]],@"value":[self dealNil:rowDict0[@"value"]]};
                    
                }
                rowDict = paraArr[k];
                rowStr = [NSString stringWithFormat:@"%@",[self dealNil:rowDict[@"value"]]];
                dict = @{@"specid":[self dealNil:rowDict[@"specid"]],@"value":[self dealNil:rowDict[@"value"]]};
                
                
                [rowArrM addObject:dict];
                NSString *row0 = [self dealNil:rowStr0];
                NSString *rowOther = [self dealNil:rowStr];
                
                
                if (![row0 isEqualToString:rowOther]) {
                    inditor = 1;
                }
            }//第三层
            
            NSDictionary *resultDict = @{@"id":[self dealNil:paraId],@"name":[self dealNil:paraName],@"difIndicator":@(inditor),@"valueitems":rowArrM};
            
            [secondArrM addObject:resultDict];
            
            if (inditor == 1) {
                [secondArrDifM addObject:resultDict];
            }
            
        }//第二层
        NSDictionary *allResultDict = @{@"name":[self dealNil:name],@"paramitems":secondArrM};
        NSDictionary *allResultDifDict = @{@"name":[self dealNil:name],@"paramitems":secondArrDifM};
        [allArrM addObject:allResultDict];
        [allArrDifM addObject:allResultDifDict];
        
        
    }//第一层
    
    self.contentData = [NSMutableArray arrayWithArray:allArrM];
    self.contentDifData = [NSMutableArray arrayWithArray:allArrDifM];
    
//    if (self.contentData == nil) {
//        self.contentData = [NSMutableArray arrayWithArray:allArrM];
//    }
//    
//    if (self.contentDifData == nil) {
//        self.contentDifData = [NSMutableArray arrayWithArray:allArrDifM];
//    }
}

- (void)divideDifferentConfig:(NSArray *)allArr {
    
    //    NSMutableArray *allArrM = [NSMutableArray array];
    //    NSMutableArray *allArrDifM = [NSMutableArray array];
    for (int i = 0; i < allArr.count; i++) {
        NSDictionary *sectionDict = allArr[i];
        NSString *name = sectionDict[@"name"];
        NSArray *rowArr = sectionDict[@"configitems"];
        
        NSMutableArray *secondArrM = [NSMutableArray array];
        NSMutableArray *secondArrDifM = [NSMutableArray array];
        for (int j = 0; j < rowArr.count; j++) {
            NSInteger inditor = 0;
            NSMutableArray *rowArrM = [NSMutableArray array];
            NSDictionary *secondDict = rowArr[j];
            NSString *paraName = secondDict[@"name"];
            NSString *paraId = [NSString stringWithFormat:@"%@",secondDict[@"id"]];
            NSArray *paraArr = secondDict[@"valueitems"];
            NSDictionary *rowDict0;
            NSString *rowStr0;
            NSDictionary *rowDict;
            NSString *rowStr;
            NSDictionary *dict;
            for (int k = 0; k < paraArr.count; k++) {
                /*内存溢出
                if (k == 0) {
                    rowDict0 = paraArr[0];
                    rowStr0 = [NSString stringWithFormat:@"%@",rowDict0[@"value"]];
                    dict = @{@"specid":[self dealNil:rowDict0[@"specid"]],@"value":[self dealNil:rowDict0[@"value"]]};
                    
                }
                 */
                if (k == 0) {
                    rowDict0 = paraArr[0];
                    rowStr0 = [NSString stringWithFormat:@"%@",rowDict0[@"value"]];
//                    dict = @{@"specid":[self dealNil:rowDict0[@"specid"]],@"value":[self dealNil:rowDict0[@"value"]]};
                    
                }
                rowDict = paraArr[k];
                rowStr = [NSString stringWithFormat:@"%@",[self dealNil:rowDict[@"value"]]];
                dict = @{@"specid":[self dealNil:rowDict[@"specid"]],@"value":[self dealNil:rowDict[@"value"]]};
                
                
                [rowArrM addObject:dict];
                NSString *row0 = [self dealNil:rowStr0];
                NSString *rowOther = [self dealNil:rowStr];
                
                
                if (![row0 isEqualToString:rowOther]) {
                    inditor = 1;
                }
            }//第三层
            
            NSDictionary *resultDict = @{@"id":[self dealNil:paraId],@"name":[self dealNil:paraName],@"difIndicator":@(inditor),@"valueitems":rowArrM};
            
            [secondArrM addObject:resultDict];
            
            if (inditor == 1) {
                [secondArrDifM addObject:resultDict];
            }
            
        }//第二层
        NSDictionary *allResultDict = @{@"name":[self dealNil:name],@"paramitems":secondArrM};
        NSDictionary *allResultDifDict = @{@"name":[self dealNil:name],@"paramitems":secondArrDifM};
        //        [allArrM addObject:allResultDict];
        //        [allArrDifM addObject:allResultDifDict];
        
        [self.contentData addObject:allResultDict];
        
        [self.contentDifData addObject:allResultDifDict];
        
    }//第一层
    
    
    
    //    if (self.contentData == nil) {
    //        self.contentData = [NSMutableArray arrayWithArray:allArrM];
    //    }
    //
    //    if (self.contentDifData == nil) {
    //        self.contentDifData = [NSMutableArray arrayWithArray:allArrDifM];
    //    }
    
    
}


//进行非空处理
- (NSString *)dealNil:(id)obj {
    if (obj == nil) {
        return [NSString stringWithFormat:@"-"];
    } else {
        return [NSString stringWithFormat:@"%@",obj];
    }
}

- (void)showOrHiddenClick:(NoHighLightBtn *)btn {
    btn.selected = YES;
    
    if (btn.tag == 1) {//隐藏相同
        
        self.showBtn.selected = NO;
        self.showIndicator = 1;
        
    } else {//显示全部
        self.hiddenBtn.selected = NO;
        self.showIndicator = 0;
    }
    //刷新下面的两个表格
    [self.navTableView reloadData];
    [self.contentTableView reloadData];
    
}

- (void)createChildViews {
    //创建上面的视图
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, CTNavBarHeight, ScreenWidth, CTTopViewHeight)];
    topView.backgroundColor = MainWhiteColor;
    [self.view addSubview:topView];
    //添加一个页码控件
//    BrandControl *brandControl = [[BrandControl alloc]initWithFrame:CGRectMake((ScreenWidth - CTTitleBarWidth - 30) * 0.5 + CTTitleBarWidth, CTTopViewHeight - 10, 30, 10)];
    ZS_PageControl *brandControl = [[ZS_PageControl alloc]initWithFrame:CGRectMake((ScreenWidth - CTTitleBarWidth - 100) * 0.5 + CTTitleBarWidth, CTTopViewHeight - 20, 100, 20)];
    brandControl.userInteractionEnabled = NO;
    
    brandControl.backgroundColor = [UIColor clearColor];
    //    _pageControl.userInteractionEnabled = NO;
    
    // 2.非选中颜色
    [brandControl setCoreNormalColor:MainFontGrayColor];
    
    // 3.选中颜色
    [brandControl setCoreSelectedColor:MainGoldenColor];
    
    // 4.间距
    [brandControl setGapWidth:5];
    
    // 5.宽高
    [brandControl setDiameter:3];
    
    [topView addSubview:brandControl];
    self.brandControl = brandControl;
    
    //朋友帮选车按钮
    UIView *friendHelpView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, CTTitleBarWidth, CTTopViewHeight)];
    
    //添加朋友帮选车按钮
    
    FriendHelpButton *friendHelpBtn = [[FriendHelpButton  alloc]initWithFrame:CGRectMake(10, 10, 60, 80)];
    
    [friendHelpBtn setBackgroundImage:[UIImage resizableImageWithName:@"checun_friendsbut"] forState:UIControlStateNormal];
    
    friendHelpBtn.titleLabel.numberOfLines = -1;
    
    
    
    [friendHelpBtn setTitle:@"朋友\n帮选车" forState:UIControlStateNormal];
    
    friendHelpBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    friendHelpBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    friendHelpBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    friendHelpBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    //添加点击事件
    
    [friendHelpBtn addTarget:self action:@selector(friendHelpBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [friendHelpView addSubview:friendHelpBtn];
    
    [topView addSubview:friendHelpView];
    
    ParameterScrollView *carTypeScrollView = [[ParameterScrollView alloc]initWithFrame:CGRectMake(CTTitleBarWidth, 5, ScreenWidth - CTTitleBarWidth, CTTopViewHeight - 20)];
    carTypeScrollView.showsHorizontalScrollIndicator = NO;
    UIView *carTypeView = [[UIView alloc]init];
    
    self.carTypeView = carTypeView;
    [carTypeScrollView addSubview:carTypeView];
    
    carTypeScrollView.delegate = self;
    carTypeScrollView.bounces = NO;
    carTypeScrollView.indicatorStr = @"carType";
    self.carTypeScrollView = carTypeScrollView;
    carTypeScrollView.backgroundColor = MainWhiteColor;
    
    
    [topView addSubview:carTypeScrollView];
    
    
    //创建厂商指导价和全国最低价标签
    UIView *headPriceView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), ScreenWidth, 60)];
    self.headPriceView = headPriceView;
    headPriceView.backgroundColor = MainWhiteColor;
    [self.view addSubview:headPriceView];
    
    ParameterScrollView *headPriceScrollView = [[ParameterScrollView alloc]initWithFrame:CGRectMake(CTTitleBarWidth, 0, ScreenWidth - CTTitleBarWidth, 60)];
    headPriceScrollView.bounces = NO;
    headPriceScrollView.showsHorizontalScrollIndicator = NO;
    headPriceScrollView.delegate = self;
    self.headPriceScrollView = headPriceScrollView;
    headPriceScrollView.indicatorStr = @"headPrice";
    [headPriceView addSubview:headPriceScrollView];
    
    UIView *contentPriceView = [[UIView alloc]init];
    self.contentPriceView = contentPriceView;
    [headPriceScrollView addSubview:contentPriceView];
    
    
    
    UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CTTitleBarWidth, 1)];
    topLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:topLine];
    
    UILabel *companyPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CTTitleBarWidth, 30)];
    companyPrice.textAlignment = NSTextAlignmentCenter;
    companyPrice.text = @"厂商指导价";
    companyPrice.font = [UIFont systemFontOfSize:12];
    [headPriceView addSubview:companyPrice];
    
    UIView *centerLine = [[UIView alloc]initWithFrame:CGRectMake(0, 29, CTTitleBarWidth, 1)];
    centerLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:centerLine];
    
    UILabel *gobalLowPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, CTTitleBarWidth, 30)];
    gobalLowPrice.textAlignment = NSTextAlignmentCenter;
    gobalLowPrice.font = [UIFont systemFontOfSize:12];
    gobalLowPrice.textColor = MainFontRedColor;
    gobalLowPrice.text = @"全国最低价";
    [headPriceView addSubview:gobalLowPrice];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 59, CTTitleBarWidth, 1)];
    bottomLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:bottomLine];
    
    UIView *upRightLine = [[UIView alloc]initWithFrame:CGRectMake(CTTitleBarWidth - 1, 0, 1, 30)];
    upRightLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:upRightLine];
    
    UIView *downRightLine = [[UIView alloc]initWithFrame:CGRectMake(CTTitleBarWidth - 1, 30, 1, 30)];
    downRightLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:downRightLine];
    

    
    //创建下面的视图
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headPriceView.frame), ScreenWidth, CTBottomViewHeight)];
    self.bottomView = bottomView;
    bottomView.backgroundColor = MainWhiteColor;
    
    
    ParameterTableView *navTableView = [[ParameterTableView alloc]initWithFrame:CGRectMake(0, 0, CTTitleBarWidth, CTBottomViewHeight)];
    navTableView.indicatorId = @"title";
    navTableView.showsVerticalScrollIndicator = NO;
    navTableView.bounces = NO;
    self.navTableView = navTableView;
    //注册单元格
    [self.navTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NavTableCell"];
    self.navTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    navTableView.delegate = self;
    navTableView.dataSource = self;
    [bottomView addSubview:navTableView];
    
    ParameterScrollView *contentScrollView = [[ParameterScrollView alloc]initWithFrame:CGRectMake(CTTitleBarWidth, 0, ScreenWidth - CTTitleBarWidth, CTBottomViewHeight)];
//    contentScrollView.pagingEnabled = YES;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.delegate = self;
    contentScrollView.indicatorStr = @"content";
    self.contentScrollView = contentScrollView;
    contentScrollView.contentSize = CGSizeMake(500, 0);
    contentScrollView.bounces = NO;
    [bottomView addSubview:contentScrollView];
    
    ParameterTableView *contentTableView = [[ParameterTableView alloc]initWithFrame:CGRectMake(0, 0, 500, CTBottomViewHeight)];
    contentTableView.showsVerticalScrollIndicator = NO;
    self.contentTableView = contentTableView;
    contentTableView.bounces = NO;
    contentTableView.dataSource = self;
    contentTableView.delegate = self;
    //注册单元格
    [self.contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ContentTableCell"];
    contentTableView.indicatorId = @"content";
    [contentScrollView addSubview:contentTableView];
    
    [self.view addSubview:bottomView];
    
}


- (void)friendHelpBtnClick {
    
    if (self.contentData.count == 0) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
    }
    
    
    //http://3g.chexun.com/app/modelshare.aspx?modelIds=115360,115361,115366,115365&os=ios
    
    if (self.compareCarIds == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"没有分享的车型"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    
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
    if (buttonIndex == 0) {
        _scene = WXSceneSession;
        [self shareCompare];
    }else if (buttonIndex == 1) {
        _scene = WXSceneTimeline;
        [self shareCompare];
    }
}

- (void)shareCompare {
    NSMutableString *urlStrM = [NSMutableString stringWithFormat:@"?modelIds="];
    
    for (int i = 0; i < self.compareCarIds.count; i++) {
        if (i == self.compareCarIds.count - 1) {
            [urlStrM appendString:[NSString stringWithFormat:@"%@",self.compareCarIds[i]]];
        } else {
            [urlStrM appendString:[NSString stringWithFormat:@"%@,",self.compareCarIds[i]]];
        }
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"买车通-帮你的朋友选车吧！";
    message.description = @"一款针对买车用户量身打造的购车工具类APP。能够帮助用户查看车辆价格、经销商、车型参数等信息；提供优惠信息与团购活动，并可以报名参与团购和询问车辆最低价。";
    [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"http://3g.chexun.com/app/modelshare.aspx%@&os=ios",urlStrM];
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    [WXApi sendReq:req];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    tab.tabBarView.hidden = YES;
}


#pragma mark - tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showIndicator == 0) {
        NSDictionary *dict = self.contentData[section];
        NSArray *arr = dict[@"paramitems"];
        return arr.count;
    } else {
        NSDictionary *dict = self.contentDifData[section];
        NSArray *arr = dict[@"paramitems"];
        return arr.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.showIndicator == 0) {
        return self.contentData.count;
    } else {
        return self.contentDifData.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arrData;
    if (self.showIndicator == 0) {
        arrData = self.contentData;
    } else if (self.showIndicator == 1) {
        arrData = self.contentDifData;
    }
    
    CGFloat readCellHeight;
    if (indexPath.section == 0 && indexPath.row == 0) {
        readCellHeight = CTBigCellHeight;
    } else {
        readCellHeight = CTCellHeight;
    }
    
    ParameterTableView *tmp = (ParameterTableView *)tableView;
    if ([tmp.indicatorId isEqualToString:@"title"]) {
        static NSString *titleID = @"NavTableCell";
        UITableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier:titleID forIndexPath:indexPath];
        titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSInteger subviewsCount = titleCell.contentView.subviews.count;
        
        if (subviewsCount > 0) {
            //在这里只能用上面的forin,而不能用下面的for循环
            
            for (UIView *view in titleCell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
        
        NSDictionary *secDict = arrData[indexPath.section];
        NSArray *secArr = secDict[@"paramitems"];
        NSDictionary *rowDic = secArr[indexPath.row];
        ParameterCell *parameterView = [[ParameterCell alloc]initWithFrame:titleCell.bounds indicator:@"title"];
        if ([rowDic[@"difIndicator"] integerValue] == 0) {
            parameterView.isAll = YES;
        } else {
            parameterView.isAll = NO;
        }
        parameterView.contentStr = rowDic[@"name"];
        [titleCell.contentView addSubview:parameterView];
        
        return titleCell;
    } else {
        static NSString *contentID = @"ContentTableCell";
        UITableViewCell *contentCell = [tableView dequeueReusableCellWithIdentifier:contentID forIndexPath:indexPath];
        contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSInteger subviewsCount = contentCell.contentView.subviews.count;
        
        if (subviewsCount > 0) {
            //在这里只能用上面的forin,而不能用下面的for循环
            
            for (UIView *view in contentCell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
        
        NSDictionary *secDict = arrData[indexPath.section];
        NSArray *secArr = secDict[@"paramitems"];
        NSDictionary *rowDic = secArr[indexPath.row];
        NSArray *rowArr = rowDic[@"valueitems"];
        //创建子视图
        for (int i = 0; i < rowArr.count; i++) {
            NSDictionary *dict = rowArr[i];
            ParameterCell *parameterView = [[ParameterCell alloc]initWithFrame:CGRectMake(i * CTCellWidth, 0, CTCellWidth, readCellHeight) indicator:@"content"];
            if ([rowDic[@"difIndicator"] integerValue] == 0) {
                parameterView.isAll = YES;
            } else {
                parameterView.isAll = NO;
            }
            NSString *str = [NSString stringWithFormat:@"%@",dict[@"value"]];
            parameterView.contentStr = str;
            [contentCell.contentView addSubview:parameterView];
        }
        
        return contentCell;
    }
    
    
}

#pragma mark - tableview delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ParameterTableView *tmp = (ParameterTableView *)tableView;
    if ([tmp.indicatorId isEqualToString:@"title"]) {
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CTTitleBarWidth, CTSectionHeight)];
        titleView.backgroundColor = MainBackGroundColor;
        
        [titleView addSubview:self.showLabels[section]];
        
        return titleView;
    } else {
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CTTitleBarWidth, CTSectionHeight)];
        contentView.backgroundColor = MainBackGroundColor;
        
        return contentView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CTSectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return CTBigCellHeight;
    } else {
        return CTCellHeight;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[ParameterScrollView class]]) {
        ParameterScrollView *tmp = (ParameterScrollView *)scrollView;
        
        if ([tmp.indicatorStr isEqualToString:@"content"]) {
            self.carTypeScrollView.contentOffset = tmp.contentOffset;
            self.headPriceScrollView.contentOffset = tmp.contentOffset;
        } else if ([tmp.indicatorStr isEqualToString:@"headPrice"]) {
            self.carTypeScrollView.contentOffset = tmp.contentOffset;
            self.contentScrollView.contentOffset = tmp.contentOffset;
        } else {
            self.contentScrollView.contentOffset = tmp.contentOffset;
            self.headPriceScrollView.contentOffset = tmp.contentOffset;
        }
        
        // 根据scrollView的滚动位置决定pageControl显示第几页
        CGFloat scrollW = scrollView.frame.size.width;
        int page = (scrollView.contentOffset.x + scrollW * 0.5) / scrollW;
        self.brandControl.currentPage = page;
        self.page = page;
        
    } else if ([scrollView isKindOfClass:[ParameterTableView class]]) {
        ParameterTableView *tmp = (ParameterTableView *)scrollView;
        
        if ([tmp.indicatorId isEqualToString:@"title"]) {
            self.contentTableView.contentOffset = tmp.contentOffset;
        } else {
            self.navTableView.contentOffset = tmp.contentOffset;
        }
        
    }
}

#pragma mark - ParameterCarTypeView delegate
- (void)compareReduceBtnClick:(CompareCarTypeView *)carTypeView {
    
    
    NSDictionary *dict = carTypeView.dataDict;
    
    NSMutableArray *temCom = self.allCompareCars;
    
    for (int i = 0; i < self.allCompareCars.count; i++) {
        
        NSDictionary *comDict = self.allCompareCars[i];
        
        if ([dict[@"carTypeId"] isEqual:comDict[@"carTypeId"]]) {
            
            [temCom removeObject:comDict];
            
            break;
            
        }
        
    }
    //写入文件
    
    [self writeNewData:temCom];
    
    
    NSInteger indexNum = carTypeView.tag;
    
    for (int i = 0; i < self.carTypeView.subviews.count; i++) {
        CompareCarTypeView *carView = self.carTypeView.subviews[i];
        if (carView.tag == indexNum) {
            [carView removeFromSuperview];
        }
    }
    
    self.carTypeCount = self.carTypeView.subviews.count;
    
    for (int i = 0; i < self.contentPriceView.subviews.count; i++) {
        PriceContentView *priceView = self.contentPriceView.subviews[i];
        if (priceView.tag == indexNum) {
            [priceView removeFromSuperview];
        }
    }
    
    //对数据进行处理
    NSMutableArray *allArrM = [NSMutableArray array];
    NSMutableArray *allArrDifM = [NSMutableArray array];
    for (int i = 0; i < self.contentData.count; i++) {
        NSDictionary *sectionDict = self.contentData[i];
        NSString *name = sectionDict[@"name"];
        NSArray *rowArr = sectionDict[@"paramitems"];
        
        NSMutableArray *secondArrM = [NSMutableArray array];
        NSMutableArray *secondArrDifM = [NSMutableArray array];
        for (int j = 0; j < rowArr.count; j++) {
            
            NSMutableArray *rowArrM = [NSMutableArray array];
            NSDictionary *secondDict = rowArr[j];
            NSString *paraName = secondDict[@"name"];
            NSInteger inditor = [secondDict[@"difIndicator"] integerValue];
            NSString *paraId = [NSString stringWithFormat:@"%@",secondDict[@"id"]];
            NSArray *paraArr = secondDict[@"valueitems"];
            
            NSDictionary *rowDict;
            /*内存溢出
            NSString *rowStr;
             */
            NSDictionary *dict;
            for (int k = 0; k < paraArr.count; k++) {
                
                if (k != indexNum) {
                    rowDict = paraArr[k];
                    /*内存溢出
                    rowStr = [NSString stringWithFormat:@"%@",[self dealNil:rowDict[@"value"]]];
                     */
                    dict = @{@"specid":[self dealNil:rowDict[@"specid"]],@"value":[self dealNil:rowDict[@"value"]]};
                    [rowArrM addObject:dict];
                    
                }
                
                
            }//第三层
            
            NSDictionary *resultDict = @{@"id":[self dealNil:paraId],@"name":[self dealNil:paraName],@"difIndicator":@(inditor),@"valueitems":rowArrM};
            
            [secondArrM addObject:resultDict];
            
            if (inditor == 1) {
                [secondArrDifM addObject:resultDict];
            }
            
        }//第二层
        NSDictionary *allResultDict = @{@"name":[self dealNil:name],@"paramitems":secondArrM};
        NSDictionary *allResultDifDict = @{@"name":[self dealNil:name],@"paramitems":secondArrDifM};
        [allArrM addObject:allResultDict];
        [allArrDifM addObject:allResultDifDict];
        
        
    }//第一层
    
//    self.contentData = allArrM;
    
    [self divideDifferentPara:allArrM];
    self.contentData = [NSMutableArray arrayWithArray:allArrM];
    self.contentDifData = [NSMutableArray arrayWithArray:allArrDifM];
    
    
    //设置carTypeScrollView的子视图的frame
    
    for (NSInteger l = indexNum; l < self.carTypeView.subviews.count; l++) {
        CompareCarTypeView *carView = self.carTypeView.subviews[l];
        carView.tag = l;
        carView.frame = CGRectMake(carView.tag * CTCellWidth, 0, CTCellWidth, CTCarTypeHeight);
    }
    
    //设置contentPriceView的子视图的frame
    
    for (NSInteger m = indexNum; m < self.contentPriceView.subviews.count; m++) {
        PriceContentView *priceView = self.contentPriceView.subviews[m];
        priceView.tag = m;
        priceView.frame = CGRectMake(priceView.tag * CTCellWidth, 0, CTCellWidth, CTCarTypeHeight);
    }
    
    NSDictionary *secDict = self.contentData[0];
    NSArray *secArr = secDict[@"paramitems"];
    NSDictionary *rowDic = secArr[0];
    NSArray *rowArr = rowDic[@"valueitems"];
    
    //重新设置相关contentsize
    self.contentTableView.frame = CGRectMake(0, 0, rowArr.count * CTCellWidth, CTBottomViewHeight);
    
    self.contentScrollView.contentSize = CGSizeMake(rowArr.count * CTCellWidth, 0);
    
    self.carTypeScrollView.contentSize = CGSizeMake(rowArr.count * CTCellWidth, 0);
    
    self.carTypeView.frame = CGRectMake(0, 0, rowArr.count * CTCellWidth, self.carTypeScrollView.height);
    
    self.headPriceScrollView.contentSize = CGSizeMake(rowArr.count * CTCellWidth, 0);
    
    self.contentPriceView.frame = CGRectMake(0, 0, rowArr.count * CTCellWidth, self.headPriceScrollView.height);
    
    //设置页码控件的显示
    self.brandControl.numberOfPages = rowArr.count % 2 ? (rowArr.count / 2 + 1) : rowArr.count / 2;
    NSInteger currentNum = (NSInteger)(self.carTypeScrollView.contentOffset.x / self.carTypeScrollView.width + 0.5);
    self.brandControl.currentPage = currentNum;
    
    if (self.carTypeCount == 0) {
        self.bottomView.hidden = YES;
        self.navTableView.hidden = YES;
        self.contentScrollView.hidden = YES;
        self.contentTableView.hidden = YES;
    } else {
        self.bottomView.hidden = NO;
        self.navTableView.hidden = NO;
        self.contentScrollView.hidden = NO;
        self.contentTableView.hidden = NO;
        
    }
    
    [self.navTableView reloadData];
    [self.contentTableView reloadData];
    
}


- (void)writeNewData:(NSMutableArray *)compareTemp {
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    
    [compareTemp writeToFile:fileName atomically:YES];
}


- (void)cTParaChooseBgClick {
    
    self.chooseBtn.selected = NO;
    [self.paraChooseVc.view removeFromSuperview];
    self.paraChooseVc = nil;
    
}

- (void)cTParaChooseButtonClick:(NSInteger)sectionValue btnTag:(NSInteger)btnTag {
    
    
    if (sectionValue == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:btnTag];
        if (indexPath) {
            [self.navTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            [MBProgressHUD showError:@"暂无数据"];
        }
        
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:btnTag + 5];
        NSInteger rows = [self.navTableView numberOfRowsInSection:btnTag + 5];
        if (rows > 0) {
            [self.navTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            [MBProgressHUD showError:@"暂无数据"];
        }
        
    }
    
    self.chooseBtn.selected = NO;
    [self.paraChooseVc.view removeFromSuperview];
    self.paraChooseVc = nil;
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}




@end
