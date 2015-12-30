//
//  CarScreenResultController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-22.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarScreenResultController.h"
#import "MBProgressHUD+GJ.h"
#import "AFNetworking.h"

#import "CSContentCell.h"
#import "PriceComponentsController.h"

#define HCarScreenGap 8
#define VCarScreenGap 4
#define ButtonNum 4
#define BtnHeight 27
#define BtnWidth ((ScreenWidth - (ButtonNum + 1) * HCarScreenGap) / ButtonNum)

@interface CarScreenResultController ()<UITableViewDelegate,UITableViewDataSource,CSContentCellDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,weak) UIView *navView;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) __block NSString *years;
@property (nonatomic,strong) __block NSString *actives;
@property (nonatomic,strong) __block NSMutableArray *yearArrM;
@property (nonatomic,strong) __block NSMutableArray *activeArrM;
@property (nonatomic,strong) __block NSArray *activeArr;
@property (nonatomic,strong) __block NSDictionary *contentData;
@property (nonatomic,strong) __block NSArray *carTypes;

@property (nonatomic,strong) NSArray *displaces;

@property (nonatomic,weak) UIView *screenView;

@property (nonatomic,weak) UIButton *currentTypeBtn;
@property (nonatomic,weak) UIButton *currentYearBtn;

@property (nonatomic,assign) NSInteger type;
@property (nonatomic,strong) NSString *year;

@property (nonatomic,strong) NSString *cityId;
@property (nonatomic,strong) NSDictionary *seriesDict;

@property (nonatomic,strong) PriceComponentsController *priceVc;

@end

@implementation CarScreenResultController

- (instancetype)initWithDisplaces:(NSArray *)displaces cityId:(NSString *)cityId seriesDict:(NSDictionary *)seriesDict {
    if (self = [super init]) {
        self.displaces = displaces;
        self.cityId = cityId;
        self.seriesDict = seriesDict;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"筛选结果";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    //下面的筛选视图
    UIView *screenView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navView.frame), ScreenWidth, 160)];
    screenView.backgroundColor = [UIColor whiteColor];
    self.screenView = screenView;
    [self.view addSubview:screenView];
    
    //添加表格
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(screenView.frame), ScreenWidth, ScreenHeight - 64 - 160)];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    //注册单元格
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CarResultCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:tableView];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getDataWithType:0 Year:nil];
    
        
}
- (void)getDataWithType:(NSInteger)type Year:(NSString *)year {
    //异步获取数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListSelect.do?seriesId=%@&cityId=%@",self.seriesDict[@"id"],self.cityId];
    
    if (type != 0 && [year integerValue] == 0) {
        urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListSelect.do?seriesId=%@&cityId=%@&active=%@",self.seriesDict[@"id"],self.cityId,@(type)];
    } else if (type != 0 && [year integerValue] > 0) {
        urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarModelListSelect.do?seriesId=%@&cityId=%@&active=%@&year=%@",self.seriesDict[@"id"],self.cityId,@(type),year];
    }
    
    __weak CarScreenResultController *myself = self;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        myself.contentData = responseObject;
        
        
        myself.actives = myself.contentData[@"active"];
        myself.activeArrM = [NSMutableArray arrayWithArray:[myself.actives componentsSeparatedByString:@","]];
        _carTypes = _contentData[@"carModelList"];
        myself.activeArr = myself.activeArrM;
        [myself.activeArrM removeLastObject];
        
        NSMutableArray *arrM = [NSMutableArray array];
        //获得排量
        for (NSDictionary *dict in _carTypes) {
            int indicator = 0;
            for (int i = 0; i < arrM.count; i++) {
                
                if ([dict[@"displacement"] floatValue] == [arrM[i] floatValue]) {
                    indicator = 1;
                }
            }
            if (indicator == 0) {
                [arrM addObject:dict[@"displacement"]];
            }
        }
        
        myself.displaces = arrM;
        
        
        //把上面的品牌数组，变成二维数组
        NSMutableArray *sections = [NSMutableArray array];
        for (int i = 0; i < myself.displaces.count; i++) {
            
            NSNumber *displace = myself.displaces[i];
            NSMutableArray *cells = [NSMutableArray array];
            for (int j = 0; j < _carTypes.count; j++) {
                
                NSDictionary *displaceLetter = _carTypes[j];
                if ([displace floatValue] == [displaceLetter[@"displacement"] floatValue]) {
                    
                    [cells addObject:displaceLetter];
                }
            }
            if (cells.count > 0) {
                [sections addObject:cells];
            }
            
        }
        
        _carTypes = sections;
        
        
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < myself.activeArrM.count; i++) {
            switch ([myself.activeArrM[i] integerValue]) {
                case 1:
                    [temp addObject:@"在售"];
                    break;
                case 2:
                    [temp addObject:@"停产"];
                    break;
                case 3:
                    [temp addObject:@"未上市"];
                    break;
                case 4:
                    [temp addObject:@"停产在售"];
                    break;
                    
                default:
                    break;
            }
        }
        myself.activeArrM = temp;
        
        
        myself.years = myself.contentData[@"year"];
        myself.yearArrM = [NSMutableArray arrayWithArray:[myself.years componentsSeparatedByString:@","]] ;
        [myself.yearArrM removeLastObject];
        
        
        
        //计算整个筛选视图的大小
        NSInteger activeCount = myself.activeArrM.count;
        NSInteger yearCount = myself.yearArrM.count;
        CGFloat upHeight = 0;
        CGFloat downHeight = 0;
        NSInteger upRow = 0;
        NSInteger downRow = 0;
        if (activeCount % ButtonNum == 0 && yearCount % ButtonNum == 0) {
            upRow = activeCount / ButtonNum;
            downRow = yearCount / ButtonNum;
        } else if (activeCount % ButtonNum != 0 && yearCount % ButtonNum == 0) {
            upRow = (activeCount / ButtonNum) + 1;
            downRow = yearCount / ButtonNum;
        } else if (activeCount % ButtonNum == 0 && yearCount % ButtonNum != 0) {
            upRow = activeCount / ButtonNum;
            downRow = (yearCount / ButtonNum) + 1;
            
        } else {
            upRow = (activeCount / ButtonNum) + 1;
            downRow = (yearCount / ButtonNum) + 1;
        }
        upHeight = upRow * (BtnHeight + VCarScreenGap) + 26;
        downHeight = downRow * (BtnHeight + VCarScreenGap) + 26;
        CGFloat screenViewHeight = upHeight + downHeight + 3 * VCarScreenGap;
        
        
        //下面的筛选视图
        [myself.screenView removeFromSuperview];
        UIView *screenView = [[UIView alloc]init];
        screenView.backgroundColor = [UIColor whiteColor];
        myself.screenView = screenView;
        [myself.view addSubview:screenView];
        
        myself.screenView.frame = CGRectMake(0, CGRectGetMaxY(myself.navView.frame), ScreenWidth, screenViewHeight);
        myself.tableView.frame = CGRectMake(0, CGRectGetMaxY(myself.screenView.frame), ScreenWidth, ScreenHeight - 64 - screenViewHeight);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(HCarScreenGap, VCarScreenGap, 70, 26)];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.text = @"类型";
        [myself.screenView addSubview:titleLabel];
        
        //添加分割线
        UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0,screenViewHeight - 1, ScreenWidth, 1)];
        spliteLine.backgroundColor = MainLineGrayColor;
        [myself.screenView addSubview:spliteLine];
        
        
        //计算上面类型的baseTypeY值
        CGFloat baseTypeY = CGRectGetMaxY(titleLabel.frame);
        //计算下面车款的baseYearY值
        CGFloat baseYearY = upHeight + VCarScreenGap;
        
        //创建按钮
        //创建按钮并设置frame
        for (int i = 0; i < myself.activeArrM.count; i++) {
            UIButton *typeBtn = [[UIButton alloc]init];
            typeBtn.tag = [myself.activeArr[i] integerValue];
            [typeBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
            [typeBtn setTitleColor:MainWhiteColor forState:UIControlStateSelected];
            [typeBtn setTitle:myself.activeArrM[i] forState:UIControlStateNormal];
            typeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            
            [typeBtn setBackgroundImage:[UIImage imageNamed:@"chexun_button3"] forState:UIControlStateNormal];
            [typeBtn setBackgroundImage:[UIImage imageNamed:@"chexun_button1"] forState:UIControlStateSelected];
            
            [typeBtn addTarget:myself action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            //设置frame
            NSInteger row = i % ButtonNum;
            NSInteger col = i / ButtonNum;
            
            CGFloat btnX = HCarScreenGap + row * (BtnWidth + HCarScreenGap);
            CGFloat btnY = col * (BtnHeight + VCarScreenGap) + VCarScreenGap + baseTypeY;
            
            typeBtn.frame = CGRectMake(btnX, btnY, BtnWidth, BtnHeight);
            
            if (myself.currentTypeBtn == nil && i == 0) {
                myself.currentTypeBtn = typeBtn;
                typeBtn.selected = YES;
                myself.type = typeBtn.tag;
            } else if (myself.currentTypeBtn != nil && myself.currentTypeBtn.tag == typeBtn.tag) {
                myself.currentTypeBtn = typeBtn;
                myself.type = typeBtn.tag;
                typeBtn.selected = YES;
            }
            
            
            [myself.screenView addSubview:typeBtn];
        }
        
        //创建车款视图
        UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(HCarScreenGap, baseYearY + VCarScreenGap, 70, 26)];
        yearLabel.font = [UIFont systemFontOfSize:14];
        yearLabel.text = @"车款";
        [myself.screenView addSubview:yearLabel];
        //创建按钮
        //创建按钮并设置frame
        for (int i = 0; i < myself.yearArrM.count; i++) {
            UIButton *yearBtn = [[UIButton alloc]init];
            yearBtn.tag = i;
            [yearBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
            [yearBtn setTitleColor:MainWhiteColor forState:UIControlStateSelected];
            [yearBtn setTitle:myself.yearArrM[i] forState:UIControlStateNormal];
            yearBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            
            [yearBtn setBackgroundImage:[UIImage imageNamed:@"chexun_button3"] forState:UIControlStateNormal];
            [yearBtn setBackgroundImage:[UIImage imageNamed:@"chexun_button1"] forState:UIControlStateSelected];
            
            [yearBtn addTarget:myself action:@selector(yearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            //设置frame
            NSInteger row = i % ButtonNum;
            NSInteger col = i / ButtonNum;
            
            CGFloat btnX = HCarScreenGap + row * (BtnWidth + HCarScreenGap);
            CGFloat btnY = col * (BtnHeight + VCarScreenGap) + VCarScreenGap + baseYearY + 26;
            
            yearBtn.frame = CGRectMake(btnX, btnY, BtnWidth, BtnHeight);
            if (myself.currentYearBtn == nil && i == 0) {
                myself.currentYearBtn = yearBtn;
                yearBtn.selected = YES;
            } else if (myself.currentYearBtn != nil && myself.currentYearBtn.tag == yearBtn.tag) {
                myself.currentYearBtn = yearBtn;
                yearBtn.selected = YES;
            }
            
            [myself.screenView addSubview:yearBtn];
        }
        
        [myself.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
}

- (void)typeBtnClick:(UIButton *)typeBtn {
    typeBtn.selected = YES;
    self.currentTypeBtn.selected = NO;
    self.currentTypeBtn = typeBtn;
    self.type = typeBtn.tag;
    self.currentYearBtn = nil;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self getDataWithType:self.type Year:nil];
}

- (void)yearBtnClick:(UIButton *)yearBtn {
    yearBtn.selected = YES;
    self.currentYearBtn.selected = NO;
    self.currentYearBtn = yearBtn;
    self.year = self.yearArrM[yearBtn.tag];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self getDataWithType:self.type Year:self.year];
}
- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.carTypes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.carTypes[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CarResultCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    NSArray *arr = self.carTypes[indexPath.section];
    NSDictionary *dict = arr[indexPath.row];
    
    CSContentCell *contentCell = [[CSContentCell alloc]init];
    contentCell.delegate = self;
    contentCell.cellDict = dict;
    contentCell.frame = cell.bounds;
    
    [cell.contentView addSubview:contentCell];
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 29 + 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *secView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    secView.backgroundColor = [UIColor whiteColor];
    
    UILabel *displaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 30)];
    displaceLabel.textColor = MainFontGrayColor;
    displaceLabel.backgroundColor = [UIColor clearColor];
    displaceLabel.contentMode = UIViewContentModeLeft;
    displaceLabel.font = [UIFont systemFontOfSize:14];
    displaceLabel.text = [NSString stringWithFormat:@"%.1f",[self.displaces[section] floatValue]];
    [secView addSubview:displaceLabel];
    
    //分割线
    NSString *backgroudpath = [[NSBundle mainBundle] pathForResource:@"chexun_dotted-line" ofType:@"png"];
    UIView *bottomLine = [[UIView alloc]init];
    
    UIImage  *backgroudImage = [UIImage imageWithContentsOfFile:backgroudpath];
    bottomLine.backgroundColor=[UIColor colorWithPatternImage:backgroudImage] ;
    bottomLine.frame = CGRectMake(0, 30 - 1, ScreenWidth, 1);
    [secView addSubview:bottomLine];
    
    return secView;
}

#pragma mark - CSContentCellDelegate方法
- (void)cSContentCellClick:(CSContentCell *)contentCell {
    NSString *carTypeId = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"id"]];
    NSString *carTypeName = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"name"]];
    NSString *carTypeImage = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"imagePath"]];
    NSString *carTypePrice = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"guidePrice"]];
    NSString *carTypeLowPrice = [NSString stringWithFormat:@"%@",contentCell.cellDict[@"MinPrice"]];
    
    
    NSString *carSeriesId = self.seriesDict[@"id"];
    NSString *carSeriesName = self.seriesDict[@"name"];
    
    NSDictionary *carTypeInfo = @{@"carSeriesId":carSeriesId,@"carSeriesName":carSeriesName,@"carTypeId":carTypeId,@"carTypeName":carTypeName,@"carTypeImage":carTypeImage,@"carTypePrice":carTypePrice,@"carTypeLowPrice":carTypeLowPrice,@"yearName":contentCell.cellDict[@"yearName"]};
    
    PriceComponentsController *priceVc = [[PriceComponentsController alloc]initWithPriceDict:carTypeInfo];
    self.priceVc = priceVc;
    [self.navigationController pushViewController:priceVc animated:YES];
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}


@end
