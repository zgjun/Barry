//
//  CTParaChooseController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-21.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CTParaChooseController.h"
#import "CTParaChooseView.h"
#import "CTBgView.h"

#define SectionHeight 25

@interface CTParaChooseController ()<UITableViewDataSource,UITableViewDelegate,CTBgViewDelegate,CTParaChooseViewDelegate>

@property (nonatomic,strong) NSDictionary *ctParaData;
@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,assign) CGFloat paramHeight;
@property (nonatomic,assign) CGFloat configHeight;

@end

@implementation CTParaChooseController

- (NSDictionary *)ctParaData {
    if (_ctParaData == nil) {
//        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *docDir = [[NSBundle mainBundle] pathForResource:@"screenParaAndCfg.plist" ofType:nil];
//        NSString *fileName = [docDir stringByAppendingPathComponent:@"screenParaAndCfg.plist"];
        _ctParaData = [NSDictionary dictionaryWithContentsOfFile:docDir];
    }
    return _ctParaData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CTBgView *bgView = [[CTBgView alloc]initWithFrame:self.view.bounds];
    bgView.delegate = self;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha =0.7;
    [self.view addSubview:bgView];
    
    NSArray *param = self.ctParaData[@"param"];
    NSInteger paramCount = param.count;
    NSInteger paramValue = paramCount % ButtonNum;
    NSInteger paramRow = paramCount / ButtonNum;
    if (paramValue == 0) {
        self.paramHeight = paramRow * BtnHeight + (paramRow - 1) * CenterGap +  2 * UpDownGap;
    } else {
        self.paramHeight = (paramRow + 1) * BtnHeight + paramRow * CenterGap +  2 * UpDownGap;
    }
    
    NSArray *config = self.ctParaData[@"config"];
    NSInteger configCount = config.count;
    NSInteger configValue = configCount % ButtonNum;
    NSInteger configRow = configCount / ButtonNum;
    
    if (configValue == 0) {
        self.configHeight = configRow * BtnHeight + (configRow - 1) * CenterGap +  2 * UpDownGap;
    } else {
        self.configHeight = (configRow + 1) * BtnHeight + configRow * CenterGap +  2 * UpDownGap;
    }
    
    
    
    UITableView *tableView = [[UITableView alloc]init];
    tableView.frame = CGRectMake(0, 0, ScreenWidth, self.paramHeight + self.configHeight + SectionHeight * 2);
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CTParaChooseCell"];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CTParaChooseCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    NSArray *paraArr;
    NSInteger sectionValue = 0;
    if (indexPath.section == 0) {
        paraArr = self.ctParaData[@"param"];
        sectionValue = 0;
    } else {
        paraArr = self.ctParaData[@"config"];
        sectionValue = 1;
    }
    
    CTParaChooseView *chooseView = [[CTParaChooseView alloc]init];
    chooseView.delegate = self;
    chooseView.frame = CGRectMake(0, UpDownGap, cell.width, cell.height - 2 * UpDownGap);
    chooseView.params = paraArr;
    chooseView.sectionValue = sectionValue;
    [cell.contentView addSubview:chooseView];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = self.paramHeight;
    } else {
        cellHeight = self.configHeight;
    }
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 25)];
    view.backgroundColor = MainBackGroundColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, view.width, view.height)];
    label.font = [UIFont systemFontOfSize:14];
    
    if (section == 0) {
        label.text = @"参数";
    } else {
        label.text = @"配置";
    }
    
    [view addSubview:label];
    
    return view;
}

- (void)cTBgViewClick {
    if ([self.delegate respondsToSelector:@selector(cTParaChooseBgClick)]) {
        [self.delegate cTParaChooseBgClick];
    }
}

- (void)cTParaChooseViewBtnClick:(NSInteger)btnTag SectionValue:(NSInteger)sectionValue {
    if ([self.delegate respondsToSelector:@selector(cTParaChooseButtonClick:btnTag:)]) {
        [self.delegate cTParaChooseButtonClick:sectionValue btnTag:btnTag];
    }
}


- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
