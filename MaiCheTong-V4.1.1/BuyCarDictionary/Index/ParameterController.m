//
//  ParameterController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "ParameterController.h"
#import "NoHighLightBtn.h"
#import "ParameterTableView.h"
#import "ParameterScrollView.h"
#import "MBProgressHUD+GJ.h"
#import "AFNetworking.h"
#import "ParameterCell.h"
#import "ParameterCarTypeView.h"
#import "BrandControl.h"
#import "CarTypeScreenController.h"
#import "PriceContentView.h"
#import "HTTPHelper.h"
#import "MainTabBarController.h"

#import "ZS_PageControl.h"
#import "CTCompareController.h"
#define WrongNum -1000


#define NavBarHeight 64
#define TopViewHeight 110
#define BottomViewHeight (ScreenHeight - TopViewHeight - NavBarHeight - 60)
#define TitleBarWidth 80
#define CellWidth (ScreenWidth - TitleBarWidth) * 0.5
#define CellHeight 45
#define BigCellHeight 60
#define SectionHeight 20
#define CarTypeHeight 90

@interface ParameterController ()<UITableViewDataSource,UITableViewDelegate,ParameterCarTypeViewDelegate,CarTypeScreenControllerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) NSString *carSeriesId;

@property (nonatomic,strong) NSString *carTypeId;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,weak) ZS_PageControl *brandControl;

@property (nonatomic,weak) ParameterScrollView *carTypeScrollView;

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

@property (nonatomic,strong) CarTypeScreenController *carTypeVc;

@property (nonatomic,weak) UIButton *screenBtn;

@property (nonatomic,strong) NSString *conditionStr;
/*
 0:表示显示所有
 1:表示显示不同
 */
@property (nonatomic,assign) NSInteger showIndicator;


//创建厂商指导价和全国最低价标签
@property (nonatomic,weak) UIView *headPriceView;

@property (nonatomic,weak) ParameterScrollView *headPriceScrollView;

@property (nonatomic,weak) UIView *contentPriceView;

@property (nonatomic,strong) NSDictionary *carSeriesDict;

@property (nonatomic,strong) NSDictionary *carTypeDict;

@property (nonatomic,strong) NSMutableDictionary *screenSelected;

@property (nonatomic,assign) NSInteger carTypeCount;

@property (nonatomic,weak) UIView *bottomView;

@property (nonatomic,strong) NSMutableArray *compareCars;

@property (nonatomic,weak) NoHighLightBtn *indicatorBtn;


@end

@implementation ParameterController

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

- (NSMutableDictionary *)screenSelected {
    if (_screenSelected == nil) {
        NSDictionary *dict = @{@"section0":@0,@"section1":@0,@"section2":@0};
        _screenSelected = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    return _screenSelected;
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


- (instancetype)initWithCarTypeDict:(NSDictionary *)carTypeDict {
    if (self = [super init]) {
        self.carTypeId = carTypeDict[@"carTypeId"];
        self.carTypeDict = carTypeDict;
    }
    return self;
}


- (instancetype)initWithCarSeriesDict:(NSDictionary *)carSeriesDict {
    if (self = [super init]) {
        self.carSeriesId = carSeriesDict[@"carSeriesId"];
        self.carSeriesDict = carSeriesDict;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    
    tab.tabBarView.hidden = YES;
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
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.navigationController.navigationBarHidden = NO;
    
    self.tabBarController.tabBar.hidden = YES;
    
    self.carTypeCount = WrongNum;
    
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
    UIButton *screenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    screenBtn.enabled = NO;
    self.screenBtn = screenBtn;
    
    [screenBtn addTarget:self action:@selector(screenBtnClick:) forControlEvents:UIControlEventTouchDown];
    
    screenBtn.frame = CGRectMake(ScreenWidth - 44, 20 + 4, 35, 35);
    screenBtn.imageView.contentMode = UIViewContentModeRight;
    [screenBtn setImage:[UIImage imageNamed:@"chexun_menuicon_black"] forState:UIControlStateNormal];
    [screenBtn setImage:[UIImage imageNamed:@"chexun_closeicon_gray"] forState:UIControlStateSelected];
    [navView addSubview:screenBtn];
    
    if (self.carTypeDict != nil) {
        screenBtn.hidden = YES;
    }

    
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
- (void)screenBtnClick:(UIButton *)screenBtn {
    
    if (self.carTypeCount == 0) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                              
                                                        message:@"没有相关的车型"
                              
                                                       delegate:nil
                              
                                              cancelButtonTitle:@"确定"
                              
                                              otherButtonTitles:nil];
        
        
        
        [alert show];
        
        return;
        
    }
    
    screenBtn.selected = !screenBtn.selected;
    if (screenBtn.selected) {
        
        CarTypeScreenController *carTypeVc = [[CarTypeScreenController alloc]initWithConditions:self.screenConditions screenSelected:self.screenSelected];
        carTypeVc.delegate = self;
        self.carTypeVc = carTypeVc;
        carTypeVc.conditionData = self.screenConditions;
        carTypeVc.view.frame = CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64);
        [self.view addSubview:carTypeVc.view];
        [self addChildViewController:carTypeVc];
    } else {
        [self.carTypeVc.view removeFromSuperview];
        self.carTypeVc = nil;
    }
    
}

- (void)cTParaChooseBgClick {
    self.screenBtn.selected = NO;
    [self.carTypeVc.view removeFromSuperview];
    self.carTypeVc = nil;
}

- (void)loadAsyncData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr;
    
    if (self.carTypeId == nil) {
        
        if (self.conditionStr == nil) {
            urlStr = [ NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarCompare.do?seriesId=%@",self.carSeriesId];
        } else {
            

            
            urlStr = [ NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarCompare.do?%@seriesId=%@",self.conditionStr,self.carSeriesId];
            
                                  
//           urlStr =  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)unicodeStr, NULL, NULL,  kCFStringEncodingUTF8 ));
            
        }
        
    } else {
        urlStr = [ NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarCompare.do?modelId=%@",self.carTypeId];
        
    }
    
    
    
//    urlStr = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)urlStr, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    __weak ParameterController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSArray *arr = [NSArray arrayWithArray:responseObject];
        
        if (arr.count == 0) {
            [MBProgressHUD showError:@"没有可用数据！"];
            [MBProgressHUD hideAllHUDsForView:myself.navigationController.view animated:YES];
            return;
        }
        
        [myself setViewData:responseObject];
        
        //筛选按钮可用
        myself.screenBtn.enabled = YES;
        
        [myself.contentTableView reloadData];
        
        [myself.navTableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.navigationController.view animated:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.navigationController.view animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        

        
    }];
}
- (void)setViewData:(id)data {
    if (self.carTypeId == nil && self.screenConditions == nil) {
        self.screenConditions = data[2];
    }
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
        UILabel *showLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth - TitleBarWidth, SectionHeight)];
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
    
    //排量
    NSDictionary *rowDic9 = secArr[9];
    NSArray *rowArr9 = rowDic9[@"valueitems"];
    //档位
    NSDictionary *rowDic14 = secArr[14];
    NSArray *rowArr14 = rowDic14[@"valueitems"];
    //年份
    NSDictionary *rowDic1 = secArr[1];
    NSArray *rowArr1 = rowDic1[@"valueitems"];
    
    self.contentTableView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, BottomViewHeight);
    
    self.contentScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.carTypeScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.carTypeView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, self.carTypeScrollView.height);
    
    self.headPriceScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.contentPriceView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, self.headPriceScrollView.height);
    
    
    //创建carTypeScrollView子视图
    
    NSInteger subviewsCount = self.carTypeView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in self.carTypeView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    for (int i = 0; i < rowArr.count; i++) {
        ParameterCarTypeView *paraCarView = [[ParameterCarTypeView alloc]init];
        NSDictionary *rowDict = rowArr[i];
        NSDictionary *rowDict2 = rowArr2[i];
        NSString *guidePrice = [NSString stringWithFormat:@"%@",rowDict2[@"value"]];
        if ([guidePrice hasSuffix:@"万元"]) {
            guidePrice = [guidePrice substringToIndex:guidePrice.length - 2];
        }
        NSDictionary *rowDict3 = rowArr3[i];
        NSString *lowPrice = [NSString stringWithFormat:@"%@",rowDict3[@"value"]];
        if ([lowPrice hasSuffix:@"万元"]) {
            lowPrice = [lowPrice substringToIndex:lowPrice.length - 2];
        }
        
        NSDictionary *rowDict1 = rowArr1[i];
        NSString *year = [NSString stringWithFormat:@"%@",rowDict1[@"value"]];
        
        NSDictionary *rowDict9 = rowArr9[i];
        NSString *displace = [NSString stringWithFormat:@"%@",rowDict9[@"value"]];
        
        NSDictionary *rowDict14 = rowArr14[i];
        NSString *speed = [NSString stringWithFormat:@"%@",rowDict14[@"value"]];
        
        NSString *carTypeImage;
        NSString *carSeriesId;
        NSString *carSeriesName;
        if (self.carTypeDict == nil) {
            carTypeImage = self.carSeriesDict[@"carSeriesImg"];
            carSeriesId = [NSString stringWithFormat:@"%@",self.carSeriesDict[@"carSeriesId"]];
            carSeriesName = [NSString stringWithFormat:@"%@",self.carSeriesDict[@"carSeriesName"]];
        } else {
            carTypeImage = self.carTypeDict[@"carSeriesImg"];
            carSeriesId = [NSString stringWithFormat:@"%@",self.carTypeDict[@"carSeriesId"]];
            carSeriesName = [NSString stringWithFormat:@"%@",self.carTypeDict[@"carSeriesName"]];
        }
        
        NSDictionary *dataDict = @{@"carTypeId":rowDict[@"specid"],
                                   @"carTypeImage":carTypeImage,
                                   @"carTypeLowPrice":lowPrice,
                                   @"carTypeName":rowDict[@"value"],
                                   @"carTypePrice":guidePrice,
                                   @"year":year,
                                   @"displace":displace,
                                   @"speed":speed,
                                   @"carSeriesId":carSeriesId,
                                   @"carSeriesName":carSeriesName
                                   };
        
        paraCarView.dataDict = dataDict;
        paraCarView.delegate = self;
        paraCarView.tag = i;
        paraCarView.frame = CGRectMake(i * CellWidth, 0, CellWidth, CarTypeHeight);
        [self.carTypeView addSubview:paraCarView];
    }
    //设置页码按钮
    self.brandControl.numberOfPages = rowArr.count % 2 ? (rowArr.count / 2 + 1) : rowArr.count / 2;
    self.brandControl.currentPage = 0;
    
    //创建headPriceScroll子视图
    
    NSInteger count = self.contentPriceView.subviews.count;
    
    if (count > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in self.contentPriceView.subviews) {
            [view removeFromSuperview];
        }
    }
    for (int i = 0; i < rowArr.count; i++) {
        PriceContentView *priceContenView = [[PriceContentView alloc]init];
        NSDictionary *dict2 = rowArr2[i];
        
        NSDictionary *dict3 = rowArr3[i];
        
        NSDictionary *dataDict = @{@"companyPrice":dict2[@"value"],@"lowPrice":dict3[@"value"]};
        
        priceContenView.dataDict = dataDict;
//        priceContenView.delegate = self;
        priceContenView.tag = i;
        priceContenView.frame = CGRectMake(i * CellWidth, 0, CellWidth, CarTypeHeight);
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
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, TopViewHeight)];
    topView.backgroundColor = MainWhiteColor;
    [self.view addSubview:topView];
    //添加一个页码控件
    ZS_PageControl *brandControl = [[ZS_PageControl alloc]initWithFrame:CGRectMake((ScreenWidth - TitleBarWidth - 100) * 0.5 + TitleBarWidth, TopViewHeight - 20, 100, 20)];
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
    
    UIView *parameterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TitleBarWidth, TopViewHeight)];
    UILabel *parameterLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 80)];
    parameterLabel.numberOfLines = -1;
    parameterLabel.textAlignment = NSTextAlignmentCenter;
    parameterLabel.font = [UIFont systemFontOfSize:16];
    parameterLabel.text = @"车型\n配置表";
    [parameterView addSubview:parameterLabel];
    [topView addSubview:parameterView];
    
    ParameterScrollView *carTypeScrollView = [[ParameterScrollView alloc]initWithFrame:CGRectMake(TitleBarWidth, 5, ScreenWidth - TitleBarWidth, TopViewHeight - 20)];
    carTypeScrollView.showsHorizontalScrollIndicator = NO;
//    carTypeScrollView.pagingEnabled = YES;
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
    
    ParameterScrollView *headPriceScrollView = [[ParameterScrollView alloc]initWithFrame:CGRectMake(TitleBarWidth, 0, ScreenWidth - TitleBarWidth, 60)];
    headPriceScrollView.bounces = NO;
    headPriceScrollView.showsHorizontalScrollIndicator = NO;
    headPriceScrollView.delegate = self;
    self.headPriceScrollView = headPriceScrollView;
    headPriceScrollView.indicatorStr = @"headPrice";
    [headPriceView addSubview:headPriceScrollView];
    
    UIView *contentPriceView = [[UIView alloc]init];
    self.contentPriceView = contentPriceView;
    [headPriceScrollView addSubview:contentPriceView];
    
    
    
    UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TitleBarWidth, 1)];
    topLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:topLine];
    
    UILabel *companyPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, TitleBarWidth, 30)];
    companyPrice.textAlignment = NSTextAlignmentCenter;
    companyPrice.text = @"厂商指导价";
    companyPrice.font = [UIFont systemFontOfSize:12];
    [headPriceView addSubview:companyPrice];
    
    UIView *centerLine = [[UIView alloc]initWithFrame:CGRectMake(0, 29, TitleBarWidth, 1)];
    centerLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:centerLine];
    
    UILabel *gobalLowPrice = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, TitleBarWidth, 30)];
    gobalLowPrice.textAlignment = NSTextAlignmentCenter;
    gobalLowPrice.font = [UIFont systemFontOfSize:12];
    gobalLowPrice.textColor = MainFontRedColor;
    gobalLowPrice.text = @"全国最低价";
    [headPriceView addSubview:gobalLowPrice];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 59, TitleBarWidth, 1)];
    
    bottomLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:bottomLine];
    
    UIView *upRightLine = [[UIView alloc]initWithFrame:CGRectMake(TitleBarWidth - 1, 0, 1, 30)];
    upRightLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:upRightLine];
    
    UIView *downRightLine = [[UIView alloc]initWithFrame:CGRectMake(TitleBarWidth - 1, 30, 1, 30)];
    downRightLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:downRightLine];
    
    
    
    //创建下面的视图
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headPriceView.frame), ScreenWidth, BottomViewHeight)];
    self.bottomView = bottomView;
    bottomView.backgroundColor = MainWhiteColor;
    
    
    ParameterTableView *navTableView = [[ParameterTableView alloc]initWithFrame:CGRectMake(0, 0, TitleBarWidth, BottomViewHeight)];
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
    
    ParameterScrollView *contentScrollView = [[ParameterScrollView alloc]initWithFrame:CGRectMake(TitleBarWidth, 0, ScreenWidth - TitleBarWidth, BottomViewHeight)];
//    contentScrollView.pagingEnabled = YES;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.delegate = self;
    contentScrollView.indicatorStr = @"content";
    self.contentScrollView = contentScrollView;
    contentScrollView.contentSize = CGSizeMake(500, 0);
    contentScrollView.bounces = NO;
    [bottomView addSubview:contentScrollView];
    
    ParameterTableView *contentTableView = [[ParameterTableView alloc]initWithFrame:CGRectMake(0, 0, 500, BottomViewHeight)];
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
    
    //在view上面添加pk按钮
    UIView *pkView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth - 10 - 35, ScreenHeight - 49 * 2 - 35, 45, 50)];
    [self.view addSubview:pkView];
    
    UIButton *pkBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 3, 35, 35)];
    [pkBtn setBackgroundImage:[UIImage imageNamed:@"chexun_pkbut"] forState:UIControlStateNormal];
    [pkBtn addTarget:self action:@selector(pkBtnClik) forControlEvents:UIControlEventTouchDown];
    
    [pkView addSubview:pkBtn];
    
    NoHighLightBtn *indicatorBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(23, 0, 18, 18)];
    [indicatorBtn addTarget:self action:@selector(pkBtnClik) forControlEvents:UIControlEventTouchDown];
    self.indicatorBtn = indicatorBtn;
    [indicatorBtn setBackgroundImage:[UIImage imageNamed:@"chexunr_pkicon_selected"] forState:UIControlStateNormal];
    indicatorBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [indicatorBtn setTitleColor:MainWhiteColor forState:UIControlStateNormal];
    if (self.compareCars.count == 0) {
        indicatorBtn.hidden = YES;
    } else {
        self.indicatorBtn.hidden = NO;
        [indicatorBtn setTitle:[NSString stringWithFormat:@"%@",@(self.compareCars.count)] forState:UIControlStateNormal];
    }
    [pkView addSubview:indicatorBtn];
    
    //在view上面添加置顶
    UIButton *topBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 10 - 35, ScreenHeight - 49 - 35, 35, 35)];
    [topBtn setBackgroundImage:[UIImage imageNamed:@"chexun_uparrow"] forState:UIControlStateNormal];
    [topBtn addTarget:self action:@selector(topBtnClick) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:topBtn];
}

///pkBtnClik
- (void)pkBtnClik {
//    CTCompareController *compareVc = [[CTCompareController alloc]init];
//    [self.navigationController pushViewController:compareVc animated:YES];
//    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GoToCompareVc" object:nil]];
}

///topBtnClick
- (void)topBtnClick {
    
    [self.contentTableView setContentOffset:CGPointMake(0,0) animated:YES];
    
}


- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
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
        readCellHeight = BigCellHeight;
    } else {
        readCellHeight = CellHeight;
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
            ParameterCell *parameterView = [[ParameterCell alloc]initWithFrame:CGRectMake(i * CellWidth, 0, CellWidth, readCellHeight) indicator:@"content"];
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
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TitleBarWidth, SectionHeight)];
        titleView.backgroundColor = MainBackGroundColor;
        
        [titleView addSubview:self.showLabels[section]];
        
        return titleView;
    } else {
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TitleBarWidth, SectionHeight)];
        contentView.backgroundColor = MainBackGroundColor;
        
        return contentView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return BigCellHeight;
    } else {
        return CellHeight;
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
- (void)parameterReduceBtnClick:(ParameterCarTypeView *)carTypeView {
    
    NSInteger indexNum = carTypeView.tag;
    
    for (int i = 0; i < self.carTypeView.subviews.count; i++) {
        ParameterCarTypeView *carView = self.carTypeView.subviews[i];
        if (carView.tag == indexNum) {
            [carView removeFromSuperview];
        }
    }
    
    for (int i = 0; i < self.contentPriceView.subviews.count; i++) {
        PriceContentView *priceView = self.contentPriceView.subviews[i];
        if (priceView.tag == indexNum) {
            [priceView removeFromSuperview];
        }
    }
    
    self.carTypeCount = self.carTypeView.subviews.count;
    
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
            NSString *rowStr;
            NSDictionary *dict;
            for (int k = 0; k < paraArr.count; k++) {
                
                if (k != indexNum) {
                    rowDict = paraArr[k];
                    /*内存溢出
                    rowStr = [NSString stringWithFormat:@"%@",[self dealNil:rowDict[@"value"]]];
                     */
                    rowStr = [NSString stringWithFormat:@"%@",[self dealNil:rowDict[@"value"]]];
                    dict = @{@"specid":[self dealNil:rowDict[@"specid"]],@"value":rowStr};
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
    
    
    if (self.contentData == nil) {
        self.contentData = [NSMutableArray arrayWithArray:allArrM];
    }
    
    if (self.contentDifData == nil) {
        self.contentDifData = [NSMutableArray arrayWithArray:allArrDifM];
    }
    
    //设置carTypeScrollView的子视图的frame
    
    for (NSInteger l = indexNum; l < self.carTypeView.subviews.count; l++) {
        ParameterCarTypeView *carView = self.carTypeView.subviews[l];
        carView.tag = l;
        carView.frame = CGRectMake(carView.tag * CellWidth, 0, CellWidth, CarTypeHeight);
    }
    
    //设置contentPriceView的子视图的frame
    
    for (NSInteger m = indexNum; m < self.contentPriceView.subviews.count; m++) {
        PriceContentView *priceView = self.contentPriceView.subviews[m];
        priceView.tag = m;
        priceView.frame = CGRectMake(priceView.tag * CellWidth, 0, CellWidth, CarTypeHeight);
    }
    
    NSDictionary *secDict = self.contentData[0];
    NSArray *secArr = secDict[@"paramitems"];
    NSDictionary *rowDic = secArr[0];
    NSArray *rowArr = rowDic[@"valueitems"];
    
    //重新设置相关contentsize
    self.contentTableView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, BottomViewHeight);
    
    self.contentScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.carTypeScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.carTypeView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, self.carTypeScrollView.height);
    
    self.headPriceScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.contentPriceView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, self.headPriceScrollView.height);
    
    
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

- (void)parameterAddBtnClick:(ParameterCarTypeView *)carTypeView {
    
    if (self.compareCars.count == 0) {
        self.indicatorBtn.hidden = YES;
    } else {
        self.indicatorBtn.hidden = NO;
        [self.indicatorBtn setTitle:[NSString stringWithFormat:@"%@",@(self.compareCars.count)] forState:UIControlStateNormal];
    }
}

#pragma mark - 右边的筛选按钮点击事件

- (void)carTypeScreenViewBtnClick:(NSString *)conditionStr screenSelected:(NSMutableDictionary *)screenSelected {
    
    self.screenBtn.selected = NO;
    [self.carTypeVc.view removeFromSuperview];
    self.carTypeVc = nil;
    
    self.screenSelected = screenSelected;
    
    self.conditionStr = conditionStr;
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [self loadAsyncData];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}


@end
