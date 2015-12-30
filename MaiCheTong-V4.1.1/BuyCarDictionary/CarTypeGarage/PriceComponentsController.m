//
//  PriceComponentsController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-23.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "PriceComponentsController.h"
#import "NoHighLightBtn.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "CarTaxController.h"
#import "CarInsuranceController.h"
#import "AFNetworking.h"
#import "CanBuyCarCell.h"
#import "ComponentsQueryController.h"
#import "CarTypeController.h"
#import "CalculateTool.h"

#import "WXApi.h"
#import "ParameterController.h"
#import "UIImage+Extension.h"

#define ComponentSectionHeight 30
#define ComponentSectionGap 10
#define ComponentBtnWidth ((ScreenWidth - 3 * 15) * 0.5)

//异常时赋值
#define WrongNum -1000

@interface PriceComponentsController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CanBuyCarCellDelegate,CarInsuranceControllerDelegate,UIActionSheetDelegate>
{
    enum WXScene _scene;
}

@property (nonatomic,weak) UIButton *pkBtn;

@property (nonatomic,weak) NoHighLightBtn *indicatorBtn;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSDictionary *priceDict;

@property (nonatomic,weak) UITextField *hqText;

@property (nonatomic,weak) UITextField *pureText;

@property (nonatomic,weak) UILabel *taxLabel;

@property (nonatomic,weak) UILabel *insuranceLabel;

@property (nonatomic,weak) UILabel *allPriceNum;

@property (nonatomic,weak) UILabel *guideLabel;

@property (nonatomic,assign) CGFloat guideValue;
@property (nonatomic,assign) CGFloat hqValue;
@property (nonatomic,assign) CGFloat pureValue;
@property (nonatomic,strong) NSMutableDictionary *taxDictM;
@property (nonatomic,strong) NSMutableDictionary *insuranceDictM;

///此价格还可以买到的车型
@property (nonatomic,strong) __block NSMutableArray *canBuyCars;
///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,assign) NSInteger pageNo;

@property (nonatomic,assign) NSInteger pageSize;

@property (nonatomic,assign) NSString *carTypeId;

@property (nonatomic,strong) NSMutableArray *compareArrM;


//当前保险总钱数
@property (nonatomic,assign) CGFloat currentAllInsurance;


@property (nonatomic,assign) CGFloat newPureValue;


@property (nonatomic,assign) CGFloat newHqValue;

//税费的改变状态
@property (nonatomic,assign) NSInteger taxChangeState;


//保险费的改变状态
@property (nonatomic,assign) NSInteger insuranceChangeState;

@property (nonatomic,assign) NSInteger familySites;


@property (nonatomic,weak) UIView *navView;

//@property (nonatomic,strong) CarTaxController *carTaxVc;
//
//@property (nonatomic,strong) CarInsuranceController *carInsuranceVc;

//@property (nonatomic,strong) ComponentsQueryController *componentsQueryVc;

@property (nonatomic,strong) ParameterController *parameterVc;

@property (nonatomic,strong) PriceComponentsController *priceComponentVc;

@end

@implementation PriceComponentsController


- (NSInteger)familySites {
    return [self.taxDictM[@"trafficValueSort"] integerValue];
}

- (NSMutableDictionary *)insuranceDictM {
    if (_insuranceDictM == nil) {
        _insuranceDictM = [NSMutableDictionary dictionaryWithObjects:@[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@0,@1] forKeys:@[@"thirdShow",@"loseShow",@"carStealShow",@"glassShow",@"burnShow",@"ingnoreShow",@"carPeopleShow",@"scratchShow",@"noWrongShow",@"thirdValueSort",@"glassValueSort",@"scratchValueSort"]];
    }
    return _insuranceDictM;
}

- (NSMutableDictionary *)taxDictM {
    if (_taxDictM == nil) {
        _taxDictM = [NSMutableDictionary dictionaryWithObjects:@[@0,@0] forKeys:@[@"carShipValueSort",@"trafficValueSort"]];
    }
    return _taxDictM;
}

- (NSMutableArray *)compareArrM {
    _compareArrM = [NSMutableArray array];
    
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    //先读取之前的历史记录
    _compareArrM = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    
    return _compareArrM;
}

- (instancetype)initWithPriceDict:(NSDictionary *)priceDict {
    if(self = [super init]) {
        _scene = WXSceneTimeline;
        self.priceDict = priceDict;
        self.carTypeId = priceDict[@"carTypeId"];
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    //刷新表格的第一个section
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //在显示完成后，写进历史记录
    //确定写入的路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"typeHistory.plist"];
    
    
    //先读取之前的历史记录
    NSMutableArray *historyArr = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    
    if (historyArr.count == 0) {
        historyArr = [NSMutableArray arrayWithObject:self.priceDict];
    } else {
        //去重
        for (int i = 0; i < historyArr.count; i++) {
            NSDictionary *dict = historyArr[i];
            if ([self.priceDict[@"carTypeId"] isEqual:dict[@"carTypeId"]]) {
                [historyArr removeObjectAtIndex:i];
            }
        }
        [historyArr insertObject:self.priceDict atIndex:0];
        
        if (historyArr.count > 50) {
            [historyArr removeLastObject];
        }
    }
    
    [historyArr writeToFile:fileName atomically:YES];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = MainWhiteColor;

    
    //导航视图
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    self.navView = navView;
    navView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:navView];
    
    
    
    //返回按钮
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_backarrow_black"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    [navView addSubview:backBtn];
    
    //分享按钮
    UIButton *shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 88  - 15, 20, 44, 44)];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"chexun_shareicon"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:shareBtn];
    
    //配置单按钮
    UIButton *configBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 44 - 5, 20, 44, 44)];
    [configBtn setBackgroundImage:[UIImage imageNamed:@"chexun_canshuicon_black"] forState:UIControlStateNormal];
    [configBtn addTarget:self action:@selector(configurationBtnClick) forControlEvents:UIControlEventTouchDown];
    [navView addSubview:configBtn];
    
    //标题视图
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, 20, 150, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = self.priceDict[@"carSeriesName"];
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //设置相关的初始值
    self.currentAllInsurance = WrongNum;
    self.newHqValue = WrongNum;
    self.newPureValue = WrongNum;
    
    self.taxChangeState = WrongNum;
    self.insuranceChangeState = WrongNum;
    
    
    self.pageSize = 20;
    self.pageNo = 1;
    
    [self createChildViews];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
    
    
    
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarAfford.do?modelId=%@&pageSize=%@&pageNo=%@",self.carTypeId,@(self.pageSize),@(self.pageNo)];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak  PriceComponentsController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        myself.canBuyCars = [NSMutableArray arrayWithArray:responseObject];
        
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MyLog(@"%@",error);
        
    }];
}

//配置单按钮
- (void)configurationBtnClick {
    
    
    NSDictionary *dict = @{@"carSeriesId":self.priceDict[@"carSeriesId"],
                           @"carTypeId":self.priceDict[@"carTypeId"],
                           @"carSeriesImg":self.priceDict[@"carTypeImage"],
                           @"carSeriesName":self.priceDict[@"carSeriesName"],
                           };
    ParameterController *parameterVc = [[ParameterController alloc]initWithCarTypeDict:dict];
    self.parameterVc = parameterVc;
    [self.navigationController pushViewController:parameterVc animated:YES];
    
}
- (void)pkBtnClick {
    
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GoToCompareVc" object:nil]];
    
    
    
//    self.tabBarController.selectedIndex = 0;
//    if (self.tabBarController.tabBar.frame.origin.y == ScreenHeight) {
//        self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
//    }
//    
//    
//    //发通知切换控制器
//    NSNotification *notification = [NSNotification notificationWithName:@"compareChoose" object:nil];
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
//    
//    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)createChildViews {
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PriceComponentsCell"];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    
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
    if (self.compareArrM.count == 0) {
        indicatorBtn.hidden = YES;
    } else {
        self.indicatorBtn.hidden = NO;
        [indicatorBtn setTitle:[NSString stringWithFormat:@"%@",@(self.compareArrM.count)] forState:UIControlStateNormal];
    }
    [pkView addSubview:indicatorBtn];
    
}

///pkBtnClik
- (void)pkBtnClik {
    
    [self.tabBarController setSelectedIndex:0];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GoToCompareVc" object:nil]];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.canBuyCars.count;
    }
    
}

#pragma mark - 按钮点击事件
- (void)compareBtnClick:(NoHighLightBtn *)btn {
    
    NSMutableArray *compareTemp = [NSMutableArray arrayWithArray:self.compareArrM] ;
    
    if (compareTemp.count >= 10 && btn.selected == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"亲，请注意" message:@"最多只能添加10款车进行对比选择" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    btn.selected = !btn.selected;
    
    if (btn.selected == YES) {
        //添加
        
        NSString *carTypeId = [NSString stringWithFormat:@"%@",self.priceDict[@"carTypeId"]];
        
        NSString *carTypeName = [NSString stringWithFormat:@"%@",self.priceDict[@"carTypeName"]];
        
        NSString *carTypeImage = [NSString stringWithFormat:@"%@",self.priceDict[@"carTypeImage"]];
        
        NSString *carTypePrice = [NSString stringWithFormat:@"%@",self.priceDict[@"carTypePrice"]];
        
        NSString *carTypeLowPrice = [NSString stringWithFormat:@"%@",self.priceDict[@"carTypeLowPrice"]];
        
        NSDictionary *carTypeInfo = @{@"carSeriesName":self.priceDict[@"carSeriesName"],@"carSeriesId":self.priceDict[@"carSeriesId"],@"carTypeId":carTypeId,@"carTypeName":carTypeName,@"carTypeImage":carTypeImage,@"carTypePrice":carTypePrice,@"carTypeLowPrice":carTypeLowPrice,@"compareState":@0};
        
        [compareTemp addObject:carTypeInfo];
        
    } else {
        //减少
        for (int i = 0; i < compareTemp.count; i++) {
            
            NSDictionary *dict = compareTemp[i];
            
            NSString *carTypeId = [NSString stringWithFormat:@"%@",self.priceDict[@"carTypeId"]];
            
            if ([dict[@"carTypeId"] isEqual: carTypeId]) {
                
                [compareTemp removeObject:dict];
                
                break;
                
            }
            
        }
    }
    
    if (compareTemp.count == 0) {
        
        //清除文件
        
        [self cleanCompareCars];
        
        
    } else {
        
        //写入新数据
        
        [self writeNewData:compareTemp];
    }
    
    [self canBuyCarCellSelected];
    
}

- (void)writeNewData:(NSMutableArray *)compareTemp {
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    
    [compareTemp writeToFile:fileName atomically:YES];
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

#define CarIconHeight 40
#define CarIconWidth 60


#define HPriceGap 20
#define PriceHeight 30
#define PriceLabelWidth 75
#define TitleLabelWidth 50

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        
        cell.backgroundColor = [UIColor redColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 496)];
        bgView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:bgView];
        //车型名
        UIImageView *carView = [[UIImageView alloc]initWithFrame:CGRectMake(HPriceGap, 10, ScreenWidth - HPriceGap * 2, 44)];
        carView.image = [UIImage resizableImageWithName:@"chexun_inputbox"];
        [bgView addSubview:carView];
        UIImageView *icon0 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 2, 60, 40)];
        [icon0 sd_setImageWithURL:[NSURL URLWithString:self.priceDict[@"carTypeImage"]] placeholderImage:[UIImage imageNamed:@"load1"]];
        [carView addSubview:icon0];
        
        UILabel *titleLabel0 = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, carView.width - 80, 44)];
        titleLabel0.text = [NSString stringWithFormat:@"%@款 %@",self.priceDict[@"yearName"],self.priceDict[@"carTypeName"]] ;
        titleLabel0.font = [UIFont systemFontOfSize:16];
        titleLabel0.textAlignment = NSTextAlignmentLeft;
        titleLabel0.textColor = MainBlackColor;
        [carView addSubview:titleLabel0];
        
        //线
        UIImageView *line1 = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 1) * 0.5, CGRectGetMaxY(carView.frame), 1, 35)];
        line1.image = [UIImage imageNamed:@"chexun_navbar_gray"];
        [bgView addSubview:line1];
        //指导价
        UIView *guideView = [[UIView alloc]initWithFrame:CGRectMake((ScreenWidth - 19) * 0.5, CGRectGetMaxY(line1.frame) - 5.5, (ScreenWidth + 19) * 0.5 - HPriceGap, PriceHeight)];
        guideView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:guideView];
        UIImageView *icon1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5.5, 19, 19)];
        icon1.image = [UIImage imageNamed:@"chxun_models_icon1"];
        [guideView addSubview:icon1];
        UILabel *priceLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(19 + 10, 0, PriceLabelWidth, PriceHeight)];
        priceLabel1.font = [UIFont systemFontOfSize:16];
        priceLabel1.textAlignment = NSTextAlignmentLeft;
        priceLabel1.text = [NSString stringWithFormat:@"%.2f万",[self.priceDict[@"carTypePrice"] floatValue]];
        self.guideValue = [self.priceDict[@"carTypePrice"] floatValue];
        
        priceLabel1.textColor = MainFontGrayColor;
        [guideView addSubview:priceLabel1];
        UILabel *titleLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(priceLabel1.frame), 0, TitleLabelWidth, PriceHeight)];
        titleLabel1.textAlignment = NSTextAlignmentLeft;
        titleLabel1.font = [UIFont systemFontOfSize:12];
        titleLabel1.text = @"指导价";
        titleLabel1.textColor = MainFontGrayColor;
        [guideView addSubview:titleLabel1];
        
        if ([self.priceDict[@"carTypeLowPrice"] floatValue] == 0) {
            self.pureValue = [self.priceDict[@"carTypePrice"] floatValue];
            
        } else {
            
            self.pureValue = [self.priceDict[@"carTypeLowPrice"] floatValue];
        }
        
        
        //线
        UIImageView *line2 = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 1) * 0.5, CGRectGetMaxY(line1.frame) + 19, 1, 35)];
        line2.image = [UIImage imageNamed:@"chexun_navbar_gray"];
        [bgView addSubview:line2];
        //优惠价
        UIView *hqView = [[UIView alloc]initWithFrame:CGRectMake(HPriceGap, CGRectGetMaxY(line2.frame) - 5.5, (ScreenWidth + 19) * 0.5 - HPriceGap, PriceHeight)];
        hqView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:hqView];
        UIImageView *icon2 = [[UIImageView alloc]initWithFrame:CGRectMake(hqView.width - 19, 5.5, 19, 19)];
        icon2.image = [UIImage imageNamed:@"chxun_models_icon2"];
        [hqView addSubview:icon2];
        UILabel *titleLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, TitleLabelWidth, PriceHeight)];
        titleLabel2.textAlignment = NSTextAlignmentRight;
        titleLabel2.font = [UIFont systemFontOfSize:12];
        titleLabel2.text = @"优惠金额";
        titleLabel2.textColor = MainFontGrayColor;
        [hqView addSubview:titleLabel2];
        UITextField *hqText = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel2.frame), 0, PriceLabelWidth, PriceHeight)];
        hqText.font = [UIFont systemFontOfSize:16];
        hqText.textColor = MainFontGrayColor;
        hqText.returnKeyType = UIReturnKeyDone;
        self.hqText = hqText;
        hqText.delegate = self;
        
        [hqText addTarget:self action:@selector(priceTextChanged:) forControlEvents:UIControlEventEditingChanged];
        
        hqText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        hqText.background = [UIImage resizableImageWithName:@"chexun_inputbox"];
        
        hqText.textAlignment = NSTextAlignmentRight;
        
        if (self.newHqValue == WrongNum) {
            if ([self.priceDict[@"carTypeLowPrice"] floatValue] == 0) {
                hqText.text = @"0";
                self.hqValue = 0;
            } else {
                CGFloat priceValue = [self.priceDict[@"carTypePrice"] floatValue] - [self.priceDict[@"carTypeLowPrice"] floatValue];
                self.hqValue = priceValue;
                hqText.text = [NSString stringWithFormat:@"%.2f",priceValue];
            }
        } else {
            hqText.text = [NSString stringWithFormat:@"%.2f",self.newHqValue];
        }
        
        UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
        rightLabel.textColor = MainFontGrayColor;
        rightLabel.font = [UIFont systemFontOfSize:16];
        rightLabel.text = @"万";
        hqText.rightViewMode = UITextFieldViewModeAlways;
        hqText.rightView = rightLabel;
        
        [hqView addSubview:hqText];
        
        //线
        UIImageView *line3 = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 1) * 0.5, CGRectGetMaxY(line2.frame) + 19, 1, 35)];
        line3.image = [UIImage imageNamed:@"chexun_navbar_gray"];
        [bgView addSubview:line3];
        
        //优惠
        CGFloat hqValue = self.hqValue;
        if (self.newHqValue != WrongNum) {
            hqValue = self.newHqValue;
            self.pureValue = self.guideValue - self.newHqValue;
        }
        
        //各项税费
        UIView *taxView = [[UIView alloc]initWithFrame:CGRectMake((ScreenWidth - 19) * 0.5, CGRectGetMaxY(line3.frame) - 5.5, (ScreenWidth + 19) * 0.5 - HPriceGap, PriceHeight)];
        // 监听点击
        UITapGestureRecognizer *taxTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taxTap:)];
        [taxView addGestureRecognizer:taxTap];
        
        taxView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:taxView];
        UIImageView *icon3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5.5, 19, 19)];
        icon3.image = [UIImage imageNamed:@"chxun_models_icon3"];
        [taxView addSubview:icon3];
        UILabel *priceLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(19 + 10, 0, PriceLabelWidth, PriceHeight)];
        self.taxLabel = priceLabel3;
        priceLabel3.font = [UIFont systemFontOfSize:16];
        priceLabel3.textAlignment = NSTextAlignmentLeft;
        NSDictionary *allTaxDict = [CalculateTool calculateTax:self.pureValue taxDictM:self.taxDictM];
        CGFloat allTax = [allTaxDict[@"allTax"] floatValue];
        priceLabel3.text = [NSString stringWithFormat:@"%.2f万",allTax / 10000.0];

        priceLabel3.textColor = MainFontGrayColor;
        [taxView addSubview:priceLabel3];
        UILabel *titleLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(priceLabel1.frame), 0, TitleLabelWidth, PriceHeight)];
        titleLabel3.textAlignment = NSTextAlignmentLeft;
        titleLabel3.font = [UIFont systemFontOfSize:12];
        titleLabel3.text = @"各项税费";
        titleLabel3.textColor = MainFontGrayColor;
        [taxView addSubview:titleLabel3];
        
        UIImageView *moreImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel3.frame), (PriceHeight - 8) * 0.5, 5, 8)];
        moreImage1.image = [UIImage imageNamed:@"chexun_liftarrow"];
        [taxView addSubview:moreImage1];
        //线
        UIImageView *line4 = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 1) * 0.5, CGRectGetMaxY(line3.frame) + 19, 1, 35)];
        line4.image = [UIImage imageNamed:@"chexun_navbar_gray"];
        [bgView addSubview:line4];
        //商业保险
        UIView *insuranceView = [[UIView alloc]initWithFrame:CGRectMake((ScreenWidth - 19) * 0.5, CGRectGetMaxY(line4.frame) - 5.5, (ScreenWidth + 19) * 0.5 - HPriceGap, 30)];
        insuranceView.backgroundColor = [UIColor clearColor];
        // 监听点击
        UITapGestureRecognizer *insuranceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(insuranceTap:)];
        [insuranceView addGestureRecognizer:insuranceTap];
        [bgView addSubview:insuranceView];
        UIImageView *icon4 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5.5, 19, 19)];
        icon4.image = [UIImage imageNamed:@"chxun_models_icon4"];
        [insuranceView addSubview:icon4];
        UILabel *priceLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(19 + 10, 0, PriceLabelWidth, PriceHeight)];
        self.insuranceLabel = priceLabel4;
        priceLabel4.font = [UIFont systemFontOfSize:16];
        priceLabel4.textAlignment = NSTextAlignmentLeft;
        NSDictionary *allInsuranceDict = [CalculateTool calculateInsurance:self.pureValue insureDictM:self.insuranceDictM familySites:self.familySites];
        self.currentAllInsurance = [allInsuranceDict[@"allInsurance"] floatValue];
        priceLabel4.text = [NSString stringWithFormat:@"%.2f万",self.currentAllInsurance / 10000.0];
        priceLabel4.textColor = MainFontGrayColor;
        [insuranceView addSubview:priceLabel4];
        UILabel *titleLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(priceLabel1.frame), 0, TitleLabelWidth, PriceHeight)];
        titleLabel4.textAlignment = NSTextAlignmentLeft;
        titleLabel4.font = [UIFont systemFontOfSize:12];
        titleLabel4.text = @"商业保险";
        titleLabel4.textColor = MainFontGrayColor;
        [insuranceView addSubview:titleLabel4];
        UIImageView *moreImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel4.frame), (PriceHeight - 8) * 0.5, 5, 8)];
        moreImage2.image = [UIImage imageNamed:@"chexun_liftarrow"];
        [insuranceView addSubview:moreImage2];

        //线
        UIImageView *line5 = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 1) * 0.5, CGRectGetMaxY(line4.frame) + 19, 1, 35)];
        line5.image = [UIImage imageNamed:@"chexun_navbar_gray"];
        [bgView addSubview:line5];
        //参考总价
        UIView *allView = [[UIView alloc]initWithFrame:CGRectMake((ScreenWidth - 107) * 0.5, CGRectGetMaxY(line5.frame), 107, 107)];
        allView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:allView];
        UIImageView *icon5 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 107, 107)];
        icon5.image = [UIImage imageNamed:@"chexun_models_pricebg"];
        [allView addSubview:icon5];
        
        UILabel *titleLabel5 = [[UILabel alloc]initWithFrame:CGRectMake((107 - TitleLabelWidth) * 0.5, 20, TitleLabelWidth, 25)];
        titleLabel5.textAlignment = NSTextAlignmentCenter;
        titleLabel5.font = [UIFont systemFontOfSize:12];
        titleLabel5.text = @"参考总价";
        titleLabel5.textColor = MainFontGrayColor;
        [allView addSubview:titleLabel5];
        UILabel *priceLabel5 = [[UILabel alloc] initWithFrame:CGRectMake((107 - 95) * 0.5, CGRectGetMaxY(titleLabel5.frame), 95, 30)];
        self.allPriceNum = priceLabel5;
        priceLabel5.font = [UIFont systemFontOfSize:20];
        priceLabel5.textAlignment = NSTextAlignmentCenter;
        
        CGFloat allprice = [self.priceDict[@"carTypePrice"] floatValue] - hqValue + (allTax / 10000.0) + (self.currentAllInsurance / 10000.0);
        priceLabel5.text = [NSString stringWithFormat:@"%.2f万",allprice];

        priceLabel5.textColor = MainFontRedColor;
        [allView addSubview:priceLabel5];
        
        
        //下面的视图
        UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(allView.frame) + 20, ScreenWidth, 44)];
        downView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:downView];
        
        
        CGFloat gapH = (ScreenWidth - 100 - 170 - 20) / 2;
        
        UIButton *compareBtn = [[UIButton alloc]initWithFrame:CGRectMake(gapH, 0, 100, 44)];
        [compareBtn setTitle:@"添加对比" forState:UIControlStateNormal];
        [compareBtn setTitle:@"取消对比" forState:UIControlStateSelected];
        [compareBtn setTitleColor:MainGoldenColor forState:UIControlStateNormal];
        [compareBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_button2"] forState:UIControlStateNormal];
        compareBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [compareBtn addTarget:self action:@selector(compareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        for (int i = 0; i < self.compareArrM.count; i++) {
            NSDictionary *dict = self.compareArrM[i];
            if ([self.priceDict[@"carTypeId"] integerValue] == [dict[@"carTypeId"] integerValue]) {
                compareBtn.selected = YES;
                break;
            }
        }
        
        [downView addSubview:compareBtn];
        
        UIButton *queryBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(compareBtn.frame) + 20, 0, 170, 44)];
        [queryBtn setTitle:@"询最低价" forState:UIControlStateNormal];
        [queryBtn setTitleColor:MainWhiteColor forState:UIControlStateNormal];
        [queryBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_button1"] forState:UIControlStateNormal];
        [queryBtn addTarget:self action:@selector(queryBtnClick) forControlEvents:UIControlEventTouchUpInside];
        queryBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [downView addSubview:queryBtn];
        
        return cell;
        
    } else {
        static NSString *ID = @"PriceComponentsCell";
        
        UITableViewCell *canCell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
        NSInteger subviewsCount = canCell.contentView.subviews.count;
        
        if (subviewsCount > 0) {
            //在这里只能用上面的forin,而不能用下面的for循环
            
            for (UIView *view in canCell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
        canCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CanBuyCarCell *canBuyCarCell = [[CanBuyCarCell alloc]initWithCanBuyCarDict:self.canBuyCars[indexPath.row]];
        canBuyCarCell.delegate = self;
        canBuyCarCell.frame = canCell.bounds;
        
        [canCell.contentView addSubview:canBuyCarCell];
        
        UIView *downLine = [[UIView alloc]init];
         downLine.backgroundColor = MainLineGrayColor;
        downLine.frame = CGRectMake(0, 80 - 1, ScreenWidth, 1);
        [canCell.contentView addSubview:downLine];
        
        return canCell;
    }
    
}

- (void)taxTap:(UITapGestureRecognizer *)gustureRecognizer {
    CarTaxController *carTaxVc = [[CarTaxController alloc]initWithTaxDictM:self.taxDictM pureValue:self.pureValue];
//    self.carTaxVc = carTaxVc;
    [self.navigationController pushViewController:carTaxVc animated:YES];
}
- (void)insuranceTap:(UITapGestureRecognizer *)gustureRecognizer {
    CarInsuranceController *carInsuranceVc = [[CarInsuranceController alloc]initWithInsuranceDictM:self.insuranceDictM pureValue:self.pureValue familySites:self.familySites];
//    self.carInsuranceVc = carInsuranceVc;
    carInsuranceVc.delegate = self;
    [self.navigationController pushViewController:carInsuranceVc animated:YES];
}

//分享按钮点击
- (void)shareBtnClick {
    
    //弹出actionsheet进行选择分享到哪
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  
                                  initWithTitle:@"分享"
                                  
                                  delegate:self
                                  
                                  cancelButtonTitle:@"取消"
                                  
                                  destructiveButtonTitle:nil
                                  
                                  otherButtonTitles:@"分享给朋友", @"分享到朋友圈",nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [actionSheet showInView:self.view];
    
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (buttonIndex == 0) {//分享给朋友
        
        _scene = WXSceneSession;
        
        [self shareCarPriceWithType:buttonIndex];
        
    }else if (buttonIndex == 1) {//分享到朋友圈
        
        _scene = WXSceneTimeline;
        
        [self shareCarPriceWithType:buttonIndex];
        
    }
    
}

- (void)shareCarPriceWithType:(NSInteger)type {
    
    NSString *modelName = [NSString stringWithFormat:@"%@ %@",self.priceDict[@"carSeriesName"],self.priceDict[@"carTypeName"]];
    NSString *modelImg = self.priceDict[@"carTypeImage"];
    NSString *guidePrice = [NSString stringWithFormat:@"%.2f万元",[self.priceDict[@"carTypePrice"] floatValue]];
    NSString *youHuiFuDu = [NSString stringWithFormat:@"%.2f万元",[self.hqText.text floatValue]];
    NSString *luoChePrice = [NSString stringWithFormat:@"%.2f万元",self.pureValue];
    
    NSDictionary *allInsuranceDict = [CalculateTool calculateInsurance:self.pureValue insureDictM:self.insuranceDictM familySites:self.familySites];
    CGFloat allInsurance = [allInsuranceDict[@"allInsurance"] floatValue];
    
    NSDictionary *allTaxDict = [CalculateTool calculateTax:self.pureValue taxDictM:self.taxDictM];
    CGFloat allTax = [allTaxDict[@"allTax"] floatValue];
    
    NSString *jiBenHuaFei = [NSString stringWithFormat:@"%@元",@((NSInteger)allTax)];
    NSString *shangYeBaoXian = [NSString stringWithFormat:@"%@元",@((NSInteger)allInsurance)];
    
    CGFloat allValue = self.pureValue + (allTax / 10000.0) + (allInsurance / 10000.0);
    
    NSString *allHuaFei = [NSString stringWithFormat:@"%.2f万元",allValue];
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    
    /*
     购车报价：
     1、微信好友
     标题文案：亲，捞到大便宜了，看我这款车贼便宜！
     图标：车系图标图片
     内容文案：车系+车型名称+北京（本地）最低价XX.XX万 总款XX.XX万  直降X.X万
     2、微信朋友圈
     文案：亲们，贼实惠的车价，不信你看：车系+车型名称+北京（本地）最低价XX.XX万 总款XX.XX万  直降X.X万
     */
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    if (type == 0) {//分享给朋友
        
        message.title = @"亲，捞到大便宜了，看我这款车贼便宜！";
        
        message.description = [NSString stringWithFormat:@"%@ %@ %@（本地） 最低价%.2f万 总款%.2f万 直降%.2f万",self.priceDict[@"carSeriesName"],self.priceDict[@"carTypeName"],city,self.pureValue,allValue,[self.hqText.text floatValue]];
        
        [message setThumbImage:[UIImage imageNamed:@"shareIcon"]];
    } else if (type == 1) {//分享到朋友圈
        
        message.title = [NSString stringWithFormat:@"亲们，贼实惠的车价，不信你看：%@ %@ %@（本地）最低价%.2f万 总款%.2f万 直降%.2f万",self.priceDict[@"carSeriesName"],self.priceDict[@"carTypeName"],city,self.pureValue,allValue,[self.hqText.text floatValue]];
        [message setThumbImage:[UIImage imageNamed:@"shareIcon"]];
        
    }

    
    
    WXWebpageObject *ext = [WXWebpageObject object];
    
    NSString *commitUrl = [NSString stringWithFormat:@"http://3g.chexun.com/app/modelprice.aspx?modelName=%@&modelImg=%@&guidePrice=%@&youHuiFuDu=%@&luoChePrice=%@&jiBenHuaFei=%@&shangYeBaoXian=%@&allHuaFei=%@&os=ios",modelName,modelImg,guidePrice,youHuiFuDu,luoChePrice,jiBenHuaFei,shangYeBaoXian,allHuaFei];
    
    commitUrl =  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)commitUrl, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    ext.webpageUrl = commitUrl;
    
    message.mediaObject = ext;
    
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    
    req.bText = NO;
    
    req.message = message;
    
    req.scene = _scene;
    
    [WXApi sendReq:req];
}

///询最低价按钮点击
- (void)queryBtnClick {
    ComponentsQueryController *componentsQueryVc = [[ComponentsQueryController alloc]initWithCarTypeDict:self.priceDict];
//    self.componentsQueryVc = componentsQueryVc;
    [self.navigationController pushViewController:componentsQueryVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return ComponentSectionHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 496;
    } else {
        return 80;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        
        UIView *canBuyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ComponentSectionHeight)];
        
        canBuyView.backgroundColor = MainBackGroundColor;
        
        UILabel *canBuyLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, ScreenWidth - 10, ComponentSectionHeight)];
        canBuyLabel.font = [UIFont systemFontOfSize:14];
        
        canBuyLabel.text = @"此价格还可以买到的车型";
        
        [canBuyView addSubview:canBuyLabel];
        
        return canBuyView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSDictionary *dict = self.canBuyCars[indexPath.row];
        NSString *carTypeId = [NSString stringWithFormat:@"%@",dict[@"id"]];
        NSString *carTypeName = [NSString stringWithFormat:@"%@",dict[@"name"]];
        NSString *carTypeImage = [NSString stringWithFormat:@"%@",dict[@"imgPath"]];
        NSString *carTypePrice = [NSString stringWithFormat:@"%@",dict[@"price"]];
        NSString *carTypeLowPrice = [NSString stringWithFormat:@"%@",dict[@"MinPrice"]];
        
        
        NSString *carSeriesId = dict[@"seriesId"];
        NSString *carSeriesName = dict[@"seriesName"];
        
        NSDictionary *carTypeInfo = @{@"carSeriesId":carSeriesId,@"carSeriesName":carSeriesName,@"carTypeId":carTypeId,@"carTypeName":carTypeName,@"carTypeImage":carTypeImage,@"carTypePrice":carTypePrice,@"carTypeLowPrice":carTypeLowPrice,@"yearName":dict[@"yearName"]};
        
        PriceComponentsController *priceComponentVc = [[PriceComponentsController alloc]initWithPriceDict:carTypeInfo];
        self.priceComponentVc =  priceComponentVc;
        [self.navigationController pushViewController:priceComponentVc animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


- (void)priceTextChanged:(UITextField *)textField {
    
    CGFloat guidePrice = self.guideValue;
    
    //先判断是否比指导价高
    if ([textField.text floatValue] > guidePrice) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"输入金额高于指导价，请重新输入"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        [textField becomeFirstResponder];
        return;
    }
    
    
    
    
    CGFloat hqValue = [textField.text floatValue];
    
    
    
    self.pureValue = guidePrice - hqValue;
    
    self.pureText.text = [NSString stringWithFormat:@"%.2f",self.pureValue];
    
    //重置
    [self resetTaxState];
    [self resetInsuranceState];
    
    NSDictionary *allInsuranceDict = [CalculateTool calculateInsurance:self.pureValue insureDictM:self.insuranceDictM familySites:self.familySites];
    CGFloat allInsurance = [allInsuranceDict[@"allInsurance"] floatValue];
    
    NSDictionary *allTaxDict = [CalculateTool calculateTax:self.pureValue taxDictM:self.taxDictM];
    CGFloat allTax = [allTaxDict[@"allTax"] floatValue];
    
    
    self.taxLabel.text = [NSString stringWithFormat:@"%.2f万",allTax / 10000.0];
    
    self.insuranceLabel.text = [NSString stringWithFormat:@"%.2f万",allInsurance / 10000.0];
    
    CGFloat allprice = self.pureValue + (allTax / 10000.0) + (allInsurance / 10000.0);
    self.allPriceNum.text = [NSString stringWithFormat:@"%.2f",allprice];
    
    self.newHqValue = [self.hqText.text floatValue];
    
    self.newPureValue = [self.pureText.text floatValue];
    
}

#pragma mark - CanBuyCarCell 代理
- (void)canBuyCarCellSelected {
    if (self.compareArrM.count == 0) {
        self.indicatorBtn.hidden = YES;
        
    } else {
        self.indicatorBtn.hidden = NO;
        
        [self.indicatorBtn setTitle:[NSString stringWithFormat:@"%@",@(self.compareArrM.count)] forState:UIControlStateNormal];
    }
}


- (void)carInsuranceControllerDictM:(NSMutableDictionary *)insuranceDictM allInsurance:(CGFloat)allInsurance {
    self.currentAllInsurance = allInsurance;
    self.insuranceDictM = insuranceDictM;
    self.insuranceChangeState = 1;
}

- (void)carInsuranceControllerSwitch:(NSMutableDictionary *)insuranceDictM allInsurance:(CGFloat)allInsurance {
    self.currentAllInsurance = allInsurance;
    self.insuranceDictM = insuranceDictM;
    self.insuranceChangeState = 1;
}

- (void)resetInsuranceState {
    
    self.insuranceDictM = [NSMutableDictionary dictionaryWithObjects:@[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@0,@1] forKeys:@[@"thirdShow",@"loseShow",@"carStealShow",@"glassShow",@"burnShow",@"ingnoreShow",@"carPeopleShow",@"scratchShow",@"noWrongShow",@"thirdValueSort",@"glassValueSort",@"scratchValueSort"]];
}

- (void)resetTaxState {
    self.taxDictM = [NSMutableDictionary dictionaryWithObjects:@[@0,@0] forKeys:@[@"carShipValueSort",@"trafficValueSort"]];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    [textField endEditing:YES];
    
    return YES;
}


- (void)dealloc {
    MyLog(@"%s",__FILE__);
}

@end
