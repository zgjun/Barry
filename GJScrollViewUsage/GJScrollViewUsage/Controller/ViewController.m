//
//  ViewController.m
//  GJScrollViewUsage
//
//  Created by zgjun on 15/9/17.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ViewController.h"
#import "NoHighLightBtn.h"
#import "ZS_PageControl.h"
#import "ParameterScrollView.h"
#import "ParameterTableView.h"
#import "ParameterCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD+GJ.h"
#import "MJExtension.h"
#import "ParameterCarTypeView.h"
#import "PriceContentView.h"

//Import models
#import "CarModel.h"
#import "CarInfoModel.h"
#import "CarItemModel.h"
#import "CarParamTypeModel.h"
#import "CarParamItemModel.h"
#import "CarValueitemModel.h"
#import "ConfigItemModel.h"
#import "ItemModel.h"
#import "ValueItemModel.h"

/*
 0:for all items
 1:for all same items
 */
static NSInteger showIndicator;
/**
 *  default rowNum 20
 */
//static NSInteger rowNum = 20;
/**
 *  default colNum 4
 */
static NSInteger colNum = 4;

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

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,ParameterCarTypeViewDelegate>

@property (nonatomic,strong) NSDictionary *carSeriesDict;
@property (nonatomic,assign) NSInteger page;

/** head views */
@property (nonatomic,weak) UIButton *screenBtn;
@property (nonatomic,weak) NoHighLightBtn *hiddenBtn;
@property (nonatomic,weak) NoHighLightBtn *showBtn;
@property (nonatomic,weak) ZS_PageControl *brandControl;
@property (nonatomic,weak) UIView *carTypeView;
@property (nonatomic,weak) ParameterScrollView *carTypeScrollView;
@property (nonatomic,weak) UIView *headPriceView;
@property (nonatomic,weak) ParameterScrollView *headPriceScrollView;
@property (nonatomic,weak) UIView *contentPriceView;

/** content views */
@property (nonatomic,weak) UIView *bottomView;
@property (nonatomic,weak) ParameterTableView *navTableView;
@property (nonatomic,weak) ParameterScrollView *contentScrollView;
@property (nonatomic,weak) ParameterTableView *contentTableView;
@property (nonatomic,weak) NoHighLightBtn *indicatorBtn;

/** content data */
@property (nonatomic,strong) NSMutableArray *contentData;
@property (nonatomic,strong) NSMutableArray *contentDifData;
@property (nonatomic,strong) NSMutableArray *compareCars;

@property (nonatomic,strong) NSMutableArray *showLabels;

@property (nonatomic,assign) NSInteger carTypeCount;

/** car data */
@property (nonatomic,strong) CarModel *cars;
@property (nonatomic,strong) CarItemModel *carItems;
@property (nonatomic,strong) CarInfoModel *carInfo;


@end

@implementation ViewController

#pragma mark lazy function
- (NSMutableArray *)showLabels {
    if (_showLabels == nil) {
        _showLabels = [NSMutableArray array];
    }
    return _showLabels;
}

- (NSMutableArray *)compareCars {
    _compareCars = [NSMutableArray array];
    //get history data path
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //join file name
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    //get history data from sand box
    _compareCars = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    return _compareCars;
}


#pragma mark - init function


#pragma mark - lift circle function

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initialize setting
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.carSeriesDict = @{@"carSeriesId" : @"107",
                           @"carSeriesImg" : @"http://i0.chexun.net/images/2014/1218/16574/car_750_500_1663025456503F2AEF6BFFB14486BCD1.jpg",
                           @"carSeriesName" : @"高尔夫"};
    
    self.carTypeCount = WrongNum;
    
    
    //create childViews
    [self createChildViews];
    
    //load data
    [self loadDataFromPlistFile];
    
}

#pragma mark - main function
#pragma mark *** views ***
- (void)createChildViews {
    //create head that contains show&hide buttons and right button
    [self createHeadView];
    
    //create content index view
    [self createContentIndexView];
    //create content view
    [self createContentView];
    //create other views
    [self createOtherViews];
    
    
}
/**
 *  create head view
 */
- (void)createHeadView {
    //head view
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    
    navView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:navView];
    
    //create right button
    UIButton *screenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    screenBtn.enabled = YES;
    self.screenBtn = screenBtn;
    [screenBtn addTarget:self action:@selector(screenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    screenBtn.frame = CGRectMake(ScreenWidth - 44, 20 + 4, 35, 35);
    screenBtn.imageView.contentMode = UIViewContentModeRight;
    [screenBtn setImage:[UIImage imageNamed:@"chexun_menuicon_black"] forState:UIControlStateNormal];
    [screenBtn setImage:[UIImage imageNamed:@"chexun_closeicon_gray"] forState:UIControlStateSelected];
    [navView addSubview:screenBtn];
    
    //create show or hide buttons
    UIImageView *titleView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 188) * 0.5, 27, 188, 30)];
    titleView.userInteractionEnabled = YES;
    titleView.image = [UIImage imageNamed:@"chexun_models_tabbg"];
    //hide button
    NoHighLightBtn *hiddenBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(0, 0.5, 94, 29)];
    self.hiddenBtn = hiddenBtn;
    hiddenBtn.tag = 1;
    [hiddenBtn setTitle:@"隐藏相同" forState:UIControlStateNormal];
    [hiddenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [hiddenBtn setTitleColor:MainLineGrayColor forState:UIControlStateNormal];
    [hiddenBtn setBackgroundImage:[UIImage imageNamed:@"chexun_models_tableft_selected"] forState:UIControlStateSelected];
    hiddenBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [hiddenBtn addTarget:self action:@selector(showOrHiddenClick:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:hiddenBtn];
    //show button
    NoHighLightBtn *showBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(94, 0.5, 94, 29)];
    self.showBtn = showBtn;
    showBtn.tag = 2;
    showBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [showBtn setBackgroundImage:[UIImage imageNamed:@"chexun_models_tabright_selected"] forState:UIControlStateSelected];
    [showBtn setTitle:@"显示全部" forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showBtn setTitleColor:MainLineGrayColor forState:UIControlStateNormal];
    [showBtn addTarget:self action:@selector(showOrHiddenClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //initialize selected button
    showBtn.selected = YES;
    [titleView addSubview:showBtn];
    [navView addSubview:titleView];
    
    //add splite line
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
}
/**
 *  create content index view
 */
- (void)createContentIndexView {
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, TopViewHeight)];
    topView.backgroundColor = MainWhiteColor;
    [self.view addSubview:topView];
    //create a pageControl widget
    ZS_PageControl *brandControl = [[ZS_PageControl alloc]initWithFrame:CGRectMake((ScreenWidth - TitleBarWidth - 100) * 0.5 + TitleBarWidth, TopViewHeight - 20, 100, 20)];
    brandControl.userInteractionEnabled = NO;
    brandControl.backgroundColor = [UIColor clearColor];
    // 2.non-selected color
    [brandControl setCoreNormalColor:MainFontGrayColor];
    // 3.selected color
    [brandControl setCoreSelectedColor:MainGoldenColor];
    // 4.control space
    [brandControl setGapWidth:5];
    // 5.width & height
    [brandControl setDiameter:3];
    //initial data
    brandControl.numberOfPages = 2;
    brandControl.currentPage = 0;
    
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
    self.carTypeScrollView = carTypeScrollView;
    carTypeScrollView.showsHorizontalScrollIndicator = NO;
    //must add this view,or can't get scrollview's child views
    UIView *carTypeView = [[UIView alloc]init];
    self.carTypeView = carTypeView;
    [carTypeScrollView addSubview:carTypeView];
    carTypeScrollView.delegate = self;
    carTypeScrollView.bounces = NO;
    carTypeScrollView.indicatorStr = @"carType";
    carTypeScrollView.backgroundColor = MainWhiteColor;
    [topView addSubview:carTypeScrollView];
    
    //set initial view
    for (int i = 0; i < colNum; i++) {
        ParameterCarTypeView *paraCarView = [[ParameterCarTypeView alloc]init];
        paraCarView.frame = CGRectMake(i * CellWidth, 0, CellWidth, CarTypeHeight);
        [self.carTypeView addSubview:paraCarView];
    }
    
    //lowest price and company prices
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
    
    
    // set initial views
    for (int i = 0; i < colNum; i++) {
        PriceContentView *priceContenView = [[PriceContentView alloc]init];
        priceContenView.tag = i;
        priceContenView.frame = CGRectMake(i * CellWidth, 0, CellWidth, CarTypeHeight);
        [self.contentPriceView addSubview:priceContenView];
    }
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 59, TitleBarWidth, 1)];
    bottomLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:bottomLine];
    UIView *upRightLine = [[UIView alloc]initWithFrame:CGRectMake(TitleBarWidth - 1, 0, 1, 30)];
    upRightLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:upRightLine];
    UIView *downRightLine = [[UIView alloc]initWithFrame:CGRectMake(TitleBarWidth - 1, 30, 1, 30)];
    downRightLine.backgroundColor = MainBackGroundColor;
    [headPriceView addSubview:downRightLine];
}
/**
 *  create content view
 */
- (void)createContentView {
    //create content view
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headPriceView.frame), ScreenWidth, BottomViewHeight)];
    self.bottomView = bottomView;
    bottomView.backgroundColor = MainWhiteColor;
    
    
    ParameterTableView *navTableView = [[ParameterTableView alloc]initWithFrame:CGRectMake(0, 0, TitleBarWidth, BottomViewHeight)];
    self.navTableView = navTableView;
    navTableView.indicatorId = @"title";
    navTableView.showsVerticalScrollIndicator = NO;
    navTableView.bounces = NO;

    //register cell
    [self.navTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NavTableCell"];
    self.navTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    navTableView.delegate = self;
    navTableView.dataSource = self;
    [bottomView addSubview:navTableView];
    
    ParameterScrollView *contentScrollView = [[ParameterScrollView alloc]initWithFrame:CGRectMake(TitleBarWidth, 0, ScreenWidth - TitleBarWidth, BottomViewHeight)];
    self.contentScrollView = contentScrollView;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.delegate = self;
    contentScrollView.indicatorStr = @"content";

    contentScrollView.contentSize = CGSizeMake(500, 0);
    contentScrollView.bounces = NO;
    [bottomView addSubview:contentScrollView];
    
    ParameterTableView *contentTableView = [[ParameterTableView alloc]initWithFrame:CGRectMake(0, 0, 500, BottomViewHeight)];
    contentTableView.showsVerticalScrollIndicator = NO;
    self.contentTableView = contentTableView;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.bounces = NO;
    contentTableView.dataSource = self;
    contentTableView.delegate = self;
    //register the table cell
    [self.contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ContentTableCell"];
    contentTableView.indicatorId = @"content";
    [contentScrollView addSubview:contentTableView];
    [self.view addSubview:bottomView];
}
/**
 *  create other views
 */
- (void)createOtherViews {
    
    
    //add pk button on the self.view
    UIView *pkView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth - 10 - 35, ScreenHeight - 49 * 2 - 35, 45, 50)];
    [self.view addSubview:pkView];
    
    UIButton *pkBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 3, 35, 35)];
    [pkBtn setBackgroundImage:[UIImage imageNamed:@"chexun_pkbut"] forState:UIControlStateNormal];
    [pkBtn addTarget:self action:@selector(pkBtnClik) forControlEvents:UIControlEventTouchDown];
    [pkView addSubview:pkBtn];
    
    //a indicator button above the pk button
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
    
    //add a top button on the self.view
    UIButton *topBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 10 - 35, ScreenHeight - 49 - 35, 35, 35)];
    [topBtn setBackgroundImage:[UIImage imageNamed:@"chexun_uparrow"] forState:UIControlStateNormal];
    [topBtn addTarget:self action:@selector(topBtnClick) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:topBtn];
}



/**
 *  show or hide button click
 *
 *  @param btn showbutton or hidebutton
 */
- (void)showOrHiddenClick:(UIButton *)btn {
    btn.selected = YES;
    if (btn.tag == 1) {//hide same items
        
        self.showBtn.selected = NO;
        showIndicator = 1;
        
    } else {//show all items
        self.hiddenBtn.selected = NO;
        showIndicator = 0;
    }
    
    //refresh tables
    [self.navTableView reloadData];
    [self.contentTableView reloadData];

}
/**
 *  back to the top
 */
- (void)topBtnClick {
    [self.contentTableView setContentOffset:CGPointMake(0,0) animated:YES];
}



- (void)pkBtnClik {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"PK按钮" message:@"去PK啰" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alertView show];
}

/**
 *  right button click
 *
 *  @param btn rightbutton
 */
- (void)screenBtnClick:(UIButton *)screenBtn {
    
    UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"功能" message:@"此功能尚未实现" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alerView show];
}


#pragma mark *** data ***
- (void)loadDataFromPlistFile {
    //get contentData from contentdata.plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"contentData.plist" ofType:nil];
    NSArray *contentArr = [NSArray arrayWithContentsOfFile:path];
    //deal data ,merge(combine)config and parame
    NSDictionary *dict0 = contentArr[0];
    NSDictionary *dict1 = contentArr[1];
    NSDictionary *paraDict = dict0[@"result"];
    //reset the differences of resultDict[@"paramtypeitems"]
    [self divideDifferentPara:paraDict[@"paramtypeitems"]];
    NSDictionary *configDict = dict1[@"result"];
    //reset the differences of configDict[@"configtypeitems"]
    [self divideDifferentConfig:configDict[@"configtypeitems"]];
    
    if (contentArr.count >= 3) {
        //get cars
        NSDictionary *carsDict = contentArr[0];
        NSDictionary *carsResult = carsDict[@"result"];
        
        self.cars = [CarModel objectWithKeyValues: carsResult];
        
        //get car items
        NSDictionary *carItemsDict = contentArr[1];
        NSDictionary *carsItemsResult = carItemsDict[@"result"];
        self.carItems = [CarItemModel objectWithKeyValues:carsItemsResult];
        //get car info
        NSDictionary *carInfoDict = contentArr[2];
        self.carInfo = [CarInfoModel objectWithKeyValues:carInfoDict];
        
        
        //reset view data
        [self resetViewData];
        
    } else {
        [MBProgressHUD showError:@"get data error"];
    }
    
    
}

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
                if (k == 0) {
                    rowDict0 = paraArr[0];
                    rowStr0 = [NSString stringWithFormat:@"%@",rowDict0[@"value"]];
                    
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
            }//third layer
            
            NSDictionary *resultDict = @{@"id":[self dealNil:paraId],@"name":[self dealNil:paraName],@"difIndicator":@(inditor),@"valueitems":rowArrM};
            
            [secondArrM addObject:resultDict];
            
            if (inditor == 1) {
                [secondArrDifM addObject:resultDict];
            }
            
        }//second layer
        NSDictionary *allResultDict = @{@"name":[self dealNil:name],@"paramitems":secondArrM};
        NSDictionary *allResultDifDict = @{@"name":[self dealNil:name],@"paramitems":secondArrDifM};
        [allArrM addObject:allResultDict];
        [allArrDifM addObject:allResultDifDict];
        
        
    }//first layer
    
    self.contentData = [NSMutableArray arrayWithArray:allArrM];
    self.contentDifData = [NSMutableArray arrayWithArray:allArrDifM];
    
}

- (void)divideDifferentConfig:(NSArray *)allArr {
    
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
                if (k == 0) {
                    rowDict0 = paraArr[0];
                    rowStr0 = [NSString stringWithFormat:@"%@",rowDict0[@"value"]];
                    
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
            }//third layer
            
            NSDictionary *resultDict = @{@"id":[self dealNil:paraId],@"name":[self dealNil:paraName],@"difIndicator":@(inditor),@"valueitems":rowArrM};
            
            [secondArrM addObject:resultDict];
            
            if (inditor == 1) {
                [secondArrDifM addObject:resultDict];
            }
            
        }//second layer
        NSDictionary *allResultDict = @{@"name":[self dealNil:name],@"paramitems":secondArrM};
        NSDictionary *allResultDifDict = @{@"name":[self dealNil:name],@"paramitems":secondArrDifM};
        
        [self.contentData addObject:allResultDict];
        
        [self.contentDifData addObject:allResultDifDict];
        
    }//first layer
    
}

//deal the null
- (NSString *)dealNil:(id)obj {
    if (obj == nil) {
        return [NSString stringWithFormat:@"-"];
    } else {
        return [NSString stringWithFormat:@"%@",obj];
    }
}



- (void)loadDataByHttpMethod {
    
    //write the data from http into plist file
    //just a temp function
    /*
     NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"contentData.plist" ];
     NSLog(@"path=%@",path);
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
     NSString *urlStr = @"http://api.tool.chexun.com/mobile/buyCarCompare.do?seriesId=107";
     [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
     NSArray *arr = [NSArray arrayWithArray:responseObject];
     [arr writeToFile:path atomically:YES];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
     }];
     */
    
    /**
     *  if (self.carTypeId == nil) {
     
     if (self.conditionStr == nil) {
     urlStr = [ NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarCompare.do?seriesId=%@",self.carSeriesId];
     } else {
     urlStr = [ NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarCompare.do?%@seriesId=%@",self.conditionStr,self.carSeriesId];
     
     //           urlStr =  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)unicodeStr, NULL, NULL,  kCFStringEncodingUTF8 ));
     
     }
     
     } else {
     urlStr = [ NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarCompare.do?modelId=%@",self.carTypeId];
     
     }
     */
}

/**
 *  reset view data
 */
- (void)resetViewData {
    //create section head
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
    
    //the guide price from company
    NSDictionary *rowDic2 = secArr[2];
    NSArray *rowArr2 = rowDic2[@"valueitems"];
    //the lowest price in country
    NSDictionary *rowDic3 = secArr[3];
    NSArray *rowArr3 = rowDic3[@"valueitems"];
    
    //displacement
    NSDictionary *rowDic9 = secArr[9];
    NSArray *rowArr9 = rowDic9[@"valueitems"];
    //top position
    NSDictionary *rowDic14 = secArr[14];
    NSArray *rowArr14 = rowDic14[@"valueitems"];
    //year
    NSDictionary *rowDic1 = secArr[1];
    NSArray *rowArr1 = rowDic1[@"valueitems"];
    
    self.contentTableView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, BottomViewHeight);
    
    self.contentScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.carTypeScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.carTypeView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, self.carTypeScrollView.height);
    
    self.headPriceScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.contentPriceView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, self.headPriceScrollView.height);
    
    //create carTypeScrollView's child views
    
    NSInteger subviewsCount = self.carTypeView.subviews.count;
    
    if (subviewsCount > 0) {
        //only forin,can not use for loop
        
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
        carTypeImage = self.carSeriesDict[@"carSeriesImg"];
        carSeriesId = [NSString stringWithFormat:@"%@",self.carSeriesDict[@"carSeriesId"]];
        carSeriesName = [NSString stringWithFormat:@"%@",self.carSeriesDict[@"carSeriesName"]];
        
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
    //set page number
    self.brandControl.numberOfPages = (int)(rowArr.count % 2 ? (rowArr.count / 2 + 1) : rowArr.count / 2);
    self.brandControl.currentPage = 0;
    
    //create headPriceScroll's childview
    NSInteger count = self.contentPriceView.subviews.count;
    
    if (count > 0) {
        //only forin,can not use for loop
        
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
        priceContenView.tag = i;
        priceContenView.frame = CGRectMake(i * CellWidth, 0, CellWidth, CarTypeHeight);
        [self.contentPriceView addSubview:priceContenView];
    }
}


#pragma mark - delegate function
#pragma mark *** tableview delegate function ***
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (showIndicator == 0) {
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
    if (showIndicator == 0) {
        return self.contentData.count;
    } else {
        return self.contentDifData.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arrData;
    if (showIndicator == 0) {
        arrData = self.contentData;
    } else if (showIndicator == 1) {
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
            //only forin,can not use for loop
            
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
            //only forin,can not use for loop
            
            for (UIView *view in contentCell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
        
        NSDictionary *secDict = arrData[indexPath.section];
        NSArray *secArr = secDict[@"paramitems"];
        NSDictionary *rowDic = secArr[indexPath.row];
        NSArray *rowArr = rowDic[@"valueitems"];
        //create child views
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

#pragma mark - scrollView delegate
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
        
        //count page numbers depends on scrollView's position
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

#pragma mark - other delegate

#pragma mark *** ParameterCarTypeView delegate ***
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
    
    //deal with data
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
            NSString *rowStr;
            NSDictionary *dict;
            for (int k = 0; k < paraArr.count; k++) {
                
                if (k != indexNum) {
                    rowDict = paraArr[k];
                    rowStr = [NSString stringWithFormat:@"%@",[self dealNil:rowDict[@"value"]]];
                    dict = @{@"specid":[self dealNil:rowDict[@"specid"]],@"value":rowStr};
                    [rowArrM addObject:dict];
                    
                }
                
                
            }//third layer
            
            NSDictionary *resultDict = @{@"id":[self dealNil:paraId],@"name":[self dealNil:paraName],@"difIndicator":@(inditor),@"valueitems":rowArrM};
            
            [secondArrM addObject:resultDict];
            
            if (inditor == 1) {
                [secondArrDifM addObject:resultDict];
            }
            
        }//second layer
        NSDictionary *allResultDict = @{@"name":[self dealNil:name],@"paramitems":secondArrM};
        NSDictionary *allResultDifDict = @{@"name":[self dealNil:name],@"paramitems":secondArrDifM};
        [allArrM addObject:allResultDict];
        [allArrDifM addObject:allResultDifDict];
        
        
    }//first layer
    
    [self divideDifferentPara:allArrM];
    
    
    if (self.contentData == nil) {
        self.contentData = [NSMutableArray arrayWithArray:allArrM];
    }
    
    if (self.contentDifData == nil) {
        self.contentDifData = [NSMutableArray arrayWithArray:allArrDifM];
    }
    
    //set carTypeScrollView subviews' frame
    
    for (NSInteger l = indexNum; l < self.carTypeView.subviews.count; l++) {
        ParameterCarTypeView *carView = self.carTypeView.subviews[l];
        carView.tag = l;
        carView.frame = CGRectMake(carView.tag * CellWidth, 0, CellWidth, CarTypeHeight);
    }
    
    //set contentPriceView subchlid frame
    
    for (NSInteger m = indexNum; m < self.contentPriceView.subviews.count; m++) {
        PriceContentView *priceView = self.contentPriceView.subviews[m];
        priceView.tag = m;
        priceView.frame = CGRectMake(priceView.tag * CellWidth, 0, CellWidth, CarTypeHeight);
    }
    
    NSDictionary *secDict = self.contentData[0];
    NSArray *secArr = secDict[@"paramitems"];
    NSDictionary *rowDic = secArr[0];
    NSArray *rowArr = rowDic[@"valueitems"];
    
    //reset contentsize
    self.contentTableView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, BottomViewHeight);
    
    self.contentScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.carTypeScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.carTypeView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, self.carTypeScrollView.height);
    
    self.headPriceScrollView.contentSize = CGSizeMake(rowArr.count * CellWidth, 0);
    
    self.contentPriceView.frame = CGRectMake(0, 0, rowArr.count * CellWidth, self.headPriceScrollView.height);
    
    
    //set page number
    self.brandControl.numberOfPages = (int)(rowArr.count % 2 ? (rowArr.count / 2 + 1) : rowArr.count / 2);
    int currentNum = self.carTypeScrollView.contentOffset.x / self.carTypeScrollView.width + 0.5;
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


@end
