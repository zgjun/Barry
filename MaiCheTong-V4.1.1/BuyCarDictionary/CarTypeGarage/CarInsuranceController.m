//
//  CarInsuranceController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-30.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarInsuranceController.h"
#import "CarInsuranceCell.h"
#import "CalculateTool.h"


@interface CarInsuranceController ()<CarInsuranceCellDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableDictionary *insuranceDictM;

@property (nonatomic,weak) UILabel *allLabel;

@property (nonatomic,weak) UILabel *ingnoreLabel;

@property (nonatomic,weak) UILabel *noWrongLabel;

@property (nonatomic,assign) CGFloat pureValue;

@property (nonatomic,strong) NSDictionary *insuranceDict;

@property (nonatomic,assign) NSInteger familySites;

@property (nonatomic,weak) UITableView *tableView;

@end

@implementation CarInsuranceController

- (instancetype)initWithInsuranceDictM:(NSMutableDictionary *)insuranceDictM pureValue:(CGFloat)pureValue familySites:(NSInteger)familySites{
    if (self = [super init]) {
        self.insuranceDictM = insuranceDictM;
        self.pureValue = pureValue;
        self.familySites = familySites;
    }
    return self;
}

- (NSDictionary *)insuranceDict {
    if (_insuranceDict == nil) {
        _insuranceDict = [CalculateTool calculateInsurance:self.pureValue insureDictM:self.insuranceDictM familySites:self.familySites];
    }
    return _insuranceDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = MainWhiteColor;
    
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
    titleLabel.text = @"商业保险";
    [navView addSubview:titleLabel];
    
    //添加分割线
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView.backgroundColor = MainBackGroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    cell.userInteractionEnabled = YES;
    cell.contentView.userInteractionEnabled = YES;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    switch (indexPath.row) {
        case 0: {
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0.5 * cell.width, cell.height)];
            titleLabel.textAlignment = NSTextAlignmentRight;
            titleLabel.textColor = MainFontRedColor;
            titleLabel.text = @"商业保险总计：";
            [cell.contentView addSubview:titleLabel];
            
            UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 10, 0, 0.5 * cell.width - 10, cell.height)];
            
            self.allLabel = contentLabel;
            
            
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.text = [NSString stringWithFormat:@"%.0f元",[self.insuranceDict[@"allInsurance"] floatValue]];
            
            contentLabel.textColor = MainFontRedColor;
            [cell.contentView addSubview:contentLabel];
            break;
        }
        case 1: {
            NSDictionary *dict = @{@"title":@"第三者责任险：",@"content":self.insuranceDict[@"thirdInsurance"],@"insuranceShow":self.insuranceDictM[@"thirdShow"]};
            NSDictionary *dict1;
            NSDictionary *dict2;
            NSDictionary *dict3;
            NSDictionary *dict4;
            NSDictionary *dict5;
            if (self.familySites == 0) {
                dict1 = @{@"showText":@"保险金额5万：保险费用：801元",@"value":@801};
                dict2 = @{@"showText":@"保险金额10万：保险费用：971元",@"value":@971};
                dict3 = @{@"showText":@"保险金额20万：保险费用：1120元",@"value":@1120};
                dict4 = @{@"showText":@"保险金额50万：保险费用：1293元",@"value":@1293};
                dict5 = @{@"showText":@"保险金额100万：保险费用：1412元",@"value":@1412};
            } else {
                dict1 = @{@"showText":@"保险金额5万：保险费用：685元",@"value":@685};
                dict2 = @{@"showText":@"保险金额10万：保险费用：831元",@"value":@831};
                dict3 = @{@"showText":@"保险金额20万：保险费用：958元",@"value":@958};
                dict4 = @{@"showText":@"保险金额50万：保险费用：1106元",@"value":@1106};
                dict5 = @{@"showText":@"保险金额100万：保险费用：1208元",@"value":@1208};
            }
            
            NSArray *contentArr = @[dict1,dict2,dict3,dict4,dict5];
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:YES contentArr:contentArr];
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.delegate = self;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            [cell.contentView addSubview:insuranceCell];
            
            break;
        }
        case 2: {
            NSDictionary *dict = @{@"title":@"玻璃破碎险：",@"content":self.insuranceDict[@"glassInsurance"],@"insuranceShow":self.insuranceDictM[@"glassShow"]};
            NSDictionary *dict2 = @{@"showText":[NSString stringWithFormat:@"进口车：保险费用：%.0f元",self.pureValue * 0.0025 * 10000],@"value":[NSString stringWithFormat:@"%.0f",self.pureValue * 0.0025 * 10000]};
            NSDictionary *dict1 = @{@"showText":[NSString stringWithFormat:@"国产车：保险费用：%.0f元",self.pureValue * 0.0015 * 10000],@"value":[NSString stringWithFormat:@"%.0f",self.pureValue * 0.0015 * 10000]};
            NSArray *contentArr = @[dict1,dict2];
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:YES contentArr:contentArr];
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.delegate = self;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            [cell.contentView addSubview:insuranceCell];
            break;
            
        }
        case 3: {
            
            NSDictionary *dict = @{@"title":@"车身划痕险：",@"content":self.insuranceDict[@"scratchInsurance"],@"insuranceShow":self.insuranceDictM[@"scratchShow"]};
            NSDictionary *dict1;
            NSDictionary *dict2;
            NSDictionary *dict3;
            NSDictionary *dict4;
            
            if (self.pureValue < 30) {
                dict1 = @{@"showText":@"赔付金额2千：保险费用：400元",@"value":@400};
                dict2 = @{@"showText":@"赔付金额5千：保险费用：570元",@"value":@570};
                dict3 = @{@"showText":@"赔付金额1万：保险费用：760元",@"value":@760};
                dict4 = @{@"showText":@"赔付金额2万：保险费用：1140元",@"value":@1140};
            } else if (self.pureValue > 50) {
                dict1 = @{@"showText":@"赔付金额2千：保险费用：850元",@"value":@850};
                dict2 = @{@"showText":@"赔付金额5千：保险费用：1100元",@"value":@1100};
                dict3 = @{@"showText":@"赔付金额1万：保险费用：1500元",@"value":@1500};
                dict4 = @{@"showText":@"赔付金额2万：保险费用：2250元",@"value":@2250};
            } else {
                dict1 = @{@"showText":@"赔付金额2千：保险费用：585元",@"value":@585};
                dict2 = @{@"showText":@"赔付金额5千：保险费用：900元",@"value":@900};
                dict3 = @{@"showText":@"赔付金额1万：保险费用：1170元",@"value":@1170};
                dict4 = @{@"showText":@"赔付金额2万：保险费用：1780元",@"value":@1780};
            }
            
            NSArray *contentArr = @[dict1,dict2,dict3,dict4];
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:YES contentArr:contentArr];
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.delegate = self;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            [cell.contentView addSubview:insuranceCell];
            break;
            
            
        }
        case 4: {
            NSDictionary *dict = @{@"title":@"车辆损失险：",@"content":self.insuranceDict[@"loseInsurance"],@"insuranceShow":self.insuranceDictM[@"loseShow"]};
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:NO contentArr:nil];
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            insuranceCell.delegate = self;
            [cell.contentView addSubview:insuranceCell];
            break;
        }
        case 5: {
            NSDictionary *dict = @{@"title":@"自燃损失险：",@"content":self.insuranceDict[@"burnInsurance"],@"insuranceShow":self.insuranceDictM[@"burnShow"]};
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:NO contentArr:nil];
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            insuranceCell.delegate = self;
            [cell.contentView addSubview:insuranceCell];
            break;
        }
        case 6: {
            NSDictionary *dict = @{@"title":@"不计免赔特约险：",@"content":self.insuranceDict[@"ingnoreInsurance"],@"insuranceShow":self.insuranceDictM[@"ingnoreShow"]};
            
            
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:NO contentArr:nil];
            
            self.ingnoreLabel = insuranceCell.contentLabel;
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            insuranceCell.delegate = self;
            [cell.contentView addSubview:insuranceCell];
            break;
        }
        case 7: {
            NSDictionary *dict = @{@"title":@"车上人员责任险：",@"content":self.insuranceDict[@"carPeopleInsurance"],@"insuranceShow":self.insuranceDictM[@"carPeopleShow"]};
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:NO contentArr:nil];
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            insuranceCell.delegate = self;
            [cell.contentView addSubview:insuranceCell];
            break;
        }
        case 8: {
            NSDictionary *dict = @{@"title":@"全车盗抢险：",@"content":self.insuranceDict[@"carStealInsurance"],@"insuranceShow":self.insuranceDictM[@"carStealShow"]};
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:NO contentArr:nil];
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            insuranceCell.delegate = self;
            [cell.contentView addSubview:insuranceCell];
            break;
        }
        case 9: {
            NSDictionary *dict;
            if ([self.insuranceDictM[@"thirdShow"] integerValue] == 1) {
                dict = @{@"title":@"无过责任险：",@"content":self.insuranceDict[@"noWrongInsurance"],@"insuranceShow":self.insuranceDictM[@"noWrongShow"]};
            } else {
                dict = @{@"title":@"无过责任险：",@"content":@0,@"insuranceShow":self.insuranceDictM[@"noWrongShow"]};
            }
            
            CarInsuranceCell *insuranceCell = [[CarInsuranceCell alloc]initWithInsuranceDict:dict isChoose:NO contentArr:nil];
            self.noWrongLabel = insuranceCell.contentLabel;
            insuranceCell.rowValue = indexPath.row;
            insuranceCell.frame = CGRectMake(0, 0, ScreenWidth, cell.height);
            insuranceCell.delegate = self;
            [cell.contentView addSubview:insuranceCell];
            break;
        }
            
        default:
            break;
    }
    UIView *seperateLine = [[UIView alloc]init];
    seperateLine.backgroundColor = MainLineGrayColor;
    seperateLine.frame = CGRectMake(10, cell.height - 1, ScreenWidth - 10, 1);
    [cell.contentView addSubview:seperateLine];
    
    return cell;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - delegate
- (void)carInsuranceCellChangeValue:(NSInteger)rowValue component:(NSInteger)component {
    
    switch (rowValue) {
        case 1:
            [self.insuranceDictM setObject:@(component) forKey:@"thirdValueSort"];
            break;
        case 2:
            [self.insuranceDictM setObject:@(component) forKey:@"glassValueSort"];
            break;
        case 3:
            [self.insuranceDictM setObject:@(component) forKey:@"scratchValueSort"];
            break;
        default:
            break;
    }
    NSDictionary *allInsuranceDict = [CalculateTool calculateInsurance:self.pureValue insureDictM:self.insuranceDictM familySites:self.familySites];
    CGFloat allInsurance = [allInsuranceDict[@"allInsurance"] floatValue];
    CGFloat ingnore = [allInsuranceDict[@"ingnoreInsurance"] floatValue];
    CGFloat noWrong = [allInsuranceDict[@"noWrongInsurance"] floatValue];
    
    self.ingnoreLabel.text = [NSString stringWithFormat:@"%.0f元",ingnore];
    self.noWrongLabel.text = [NSString stringWithFormat:@"%.0f元",noWrong];
    self.allLabel.text = [NSString stringWithFormat:@"%.0f元",allInsurance];
    
    
    
}

//开关按钮点击
-(void)carInsuranceCellSwitch:(BOOL)isSwitch rowValue:(NSInteger)rowValue {
    
    
    switch (rowValue) {
        case 1:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"thirdShow"];
            break;
        case 2:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"glassShow"];
            break;
        case 3:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"scratchShow"];
            break;
        case 4:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"loseShow"];
            break;
        case 5:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"burnShow"];
            break;
        case 6:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"ingnoreShow"];
            break;
        case 7:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"carPeopleShow"];
            break;
        case 8:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"carStealShow"];
            break;
        case 9:
            [self.insuranceDictM setObject:@(isSwitch) forKey:@"noWrongShow"];
            break;

        default:
            break;
    }
    
    
    self.insuranceDict = [CalculateTool calculateInsurance:self.pureValue insureDictM:self.insuranceDictM familySites:self.familySites];
//    CGFloat allInsurance = [allInsuranceDict[@"allInsurance"] floatValue];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(carInsuranceControllerDictM:allInsurance:)]) {
        [self.delegate carInsuranceControllerSwitch:self.insuranceDictM allInsurance:[self.insuranceDict[@"allInsurance"] floatValue]];
    }
    
    [self.tableView reloadData];
    
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}





@end
