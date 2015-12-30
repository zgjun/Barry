//
//  CarTypeScreenController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-31.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "CarTypeScreenController.h"
#import "CTBgView.h"
#import "CarTypeScreenView.h"
#import "HTTPHelper.h"


#define SectionHeight  20

#define TableHeight 300


@interface CarTypeScreenController ()<UITableViewDataSource,UITableViewDelegate,CTBgViewDelegate,CarTypeScreenViewDelegate>

@property (nonatomic,strong) NSArray *showLabelTitles;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSDictionary *conditions;

@property (nonatomic,strong) NSMutableArray *displacement;

@property (nonatomic,strong) NSMutableArray *speedbox;

@property (nonatomic,strong) NSMutableArray *yearlist;

@property (nonatomic,assign) CGFloat displaceHeight;
@property (nonatomic,assign) CGFloat speedHeight;
@property (nonatomic,assign) CGFloat yearHeight;

@property (nonatomic,assign) CGFloat tableHeight;

@property (nonatomic,strong) NSString *displace;
@property (nonatomic,strong) NSString *speed;
@property (nonatomic,strong) NSString *year;

@property (nonatomic,strong) NSMutableDictionary *screenSelected;

@end

@implementation CarTypeScreenController

- (instancetype)initWithConditions:(NSDictionary *)conditions screenSelected:(NSMutableDictionary *)screenSelected {
    if (self = [super init]) {
        self.screenSelected = screenSelected;
        self.conditions = conditions;
        NSString *displaceStr = conditions[@"displacementList"];
        self.displacement = [NSMutableArray arrayWithArray:[displaceStr componentsSeparatedByString:@","]];
        [self.displacement removeLastObject];
        [self.displacement insertObject:@"全部" atIndex:0];
        NSString *speedStr = conditions[@"speedBoxList"];
        self.speedbox = [NSMutableArray arrayWithArray:[speedStr componentsSeparatedByString:@","]];
        [self.speedbox removeLastObject];
        [self.speedbox insertObject:@"全部" atIndex:0];
        NSString *year = conditions[@"yearList"];
        self.yearlist = [NSMutableArray arrayWithArray:[year componentsSeparatedByString:@","]];
        [self.yearlist removeLastObject];
//        [self.yearlist insertObject:@"不限" atIndex:0];
        //计算表格每一行的高度以及表格的高度
        NSInteger displacementCount = self.displacement.count;
        NSInteger displacementValue = displacementCount % ButtonNum;
        NSInteger displacementRow = displacementCount / ButtonNum;
        if (displacementValue == 0) {
            self.displaceHeight = displacementRow * BtnHeight + (displacementRow - 1) * CenterGap +  2 * UpDownGap;
        } else {
            self.displaceHeight = (displacementRow + 1) * BtnHeight + displacementRow * CenterGap +  2 * UpDownGap;
        }
        
        NSInteger speedCount = self.speedbox.count;
        NSInteger speedValue = speedCount % ButtonNum;
        NSInteger speedRow = speedCount / ButtonNum;
        if (speedValue == 0) {
            self.speedHeight = speedRow * BtnHeight + (speedRow - 1) * CenterGap +  2 * UpDownGap;
        } else {
            self.speedHeight = (speedRow + 1) * BtnHeight + speedRow * CenterGap +  2 * UpDownGap;
        }
        
        NSInteger yearCount = self.yearlist.count;
        NSInteger yearValue = yearCount % ButtonNum;
        NSInteger yearRow = yearCount / ButtonNum;
        if (yearValue == 0) {
            self.yearHeight = yearRow * BtnHeight + (yearRow - 1) * CenterGap +  2 * UpDownGap;
        } else {
            self.yearHeight = (yearRow + 1) * BtnHeight + yearRow * CenterGap +  2 * UpDownGap;
        }
        if (ScreenHeight <= 480) {
            self.tableHeight = TableHeight;
        } else {
            self.tableHeight = self.displaceHeight + self.speedHeight + self.yearHeight + 3 * SectionHeight;
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    CTBgView *bgView = [[CTBgView alloc]initWithFrame:self.view.bounds];
    bgView.delegate = self;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha =0.7;
    [self.view addSubview:bgView];
    
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, self.tableHeight + 80)];
    containerView.backgroundColor = MainBackGroundColor;
    [self.view addSubview:containerView];
    
    //创建表格
    UITableView *tableView = [[UITableView alloc]init];
    tableView.frame = CGRectMake(0, 0, ScreenWidth, self.tableHeight);
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [containerView addSubview:tableView];
    
    UIButton *commitBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, containerView.height - 44, ScreenWidth, 44)];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"chexun_okbutbg"] forState:UIControlStateNormal];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:commitBtn];
    
    self.showLabelTitles = @[@"排量",@"变速箱",@"年代"];
    
    
    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CarTypeScreenCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)commitBtnClick {
    NSMutableString *stringM = [NSMutableString string];
    if (self.displace != nil) {
        [stringM appendString:[NSString stringWithFormat:@"displacement=%@&",self.displace]];
    }
    if (self.speed != nil) {
        NSString *str = [HTTPHelper StringEncode:self.speed];
        [stringM appendString:[NSString stringWithFormat:@"speedBox=%@&",[HTTPHelper StringEncode:str]]];
    }
    if (self.year != nil) {
        [stringM appendString:[NSString stringWithFormat:@"year=%@&",self.year]];
    }
    
    if ([self.delegate respondsToSelector:@selector(carTypeScreenViewBtnClick: screenSelected:)]) {
        [self.delegate carTypeScreenViewBtnClick:stringM screenSelected:self.screenSelected];
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CarTypeScreenCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (CarTypeScreenView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    CarTypeScreenView *carScreenView = [[CarTypeScreenView alloc]initWithFrame:cell.bounds];
    carScreenView.delegate = self;
    [cell.contentView addSubview:carScreenView];
    
    if (indexPath.section == 0) {
        carScreenView.sectionValue = 0;
        carScreenView.selectedValue = [self.screenSelected[@"section0"] integerValue];
        carScreenView.params = self.displacement;
        
    } else if (indexPath.section == 1) {
        carScreenView.sectionValue = 1;
        carScreenView.selectedValue = [self.screenSelected[@"section1"] integerValue];
        carScreenView.params = self.speedbox;
        
    } else {
        carScreenView.sectionValue = 2;
        carScreenView.selectedValue = [self.screenSelected[@"section2"] integerValue];
        carScreenView.params = self.yearlist;
        
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, SectionHeight)];
    titleView.backgroundColor = MainBackGroundColor;
    
    UILabel *sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, SectionHeight)];
    sectionLabel.text = self.showLabelTitles[section];
    sectionLabel.font = [UIFont systemFontOfSize:14];
    sectionLabel.textColor = MainFontGrayColor;
    [titleView addSubview:sectionLabel];
    
    return titleView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.displaceHeight;
    } else if (indexPath.section == 1) {
        return self.speedHeight;
    } else {
        return self.yearHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SectionHeight;
}

- (void)cTBgViewClick {
    if ([self.delegate respondsToSelector:@selector(cTParaChooseBgClick)]) {
        [self.delegate cTParaChooseBgClick];
    }
}

- (void)cTParaChooseViewBtnClick:(NSString *)selectTitle SectionValue:(NSInteger)sectionValue selectedValue:(NSInteger)selectedValue {
    if (sectionValue == 0 && ![selectTitle isEqualToString:@"全部"]) {
        self.displace = selectTitle;
    }
    
    if (sectionValue == 1 && ![selectTitle isEqualToString:@"全部"]) {
        self.speed = selectTitle;
     }
    
    if(sectionValue == 2) {
        self.year = selectTitle;
    }
    
    if (sectionValue == 0 && selectedValue != [self.screenSelected[@"section0"] integerValue]) {
        [self.screenSelected setObject:@(selectedValue) forKey:@"section0"];
    } else if (sectionValue == 1 && selectedValue != [self.screenSelected[@"section1"] integerValue]) {
        [self.screenSelected setObject:@(selectedValue) forKey:@"section1"];
    } else if(sectionValue == 2 && selectedValue != [self.screenSelected[@"section2"] integerValue]) {
        [self.screenSelected setObject:@(selectedValue) forKey:@"section2"];
    }
    
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
