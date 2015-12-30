//
//  CarTaxController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-30.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarTaxController.h"
#import "CalculateTool.h"


@interface CarTaxController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableDictionary *taxDictM;
@property (nonatomic,assign) CGFloat pureValue;

@property (nonatomic,weak) UITextField *carShipField;
@property (nonatomic,weak) UITextField *controlField;
@property (nonatomic,strong) NSDictionary *taxDict;

@property (nonatomic,weak) UILabel *allContentLabel;

@property (nonatomic,weak) UITableView *tableView;

@end

@implementation CarTaxController

- (instancetype)initWithTaxDictM:(NSMutableDictionary *)taxDictM pureValue:(CGFloat)pureValue {
    if (self = [super init]) {
        self.taxDictM = taxDictM;
        self.pureValue = pureValue;
    }
    return self;
}
- (NSDictionary *)taxDict {
    if (_taxDict == nil) {
        _taxDict = [CalculateTool calculateTax:self.pureValue taxDictM:self.taxDictM];
    }
    return _taxDict;
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
    titleLabel.text = @"各项税费";
    [navView addSubview:titleLabel];
    
    //添加分割线
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];

    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    self.tableView.backgroundColor = MainBackGroundColor;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"CarTaxCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        
        UILabel *allTitleLabel = [[UILabel alloc]init];
        allTitleLabel.text = @"总计：";
        allTitleLabel.textAlignment = NSTextAlignmentLeft;
        allTitleLabel.textColor = MainBlackColor;
        allTitleLabel.font = [UIFont systemFontOfSize:16];
        allTitleLabel.frame = CGRectMake(15, 0, ScreenWidth * 0.4, cell.height);
        [cell.contentView addSubview:allTitleLabel];
        
        UILabel *allContentLabel = [[UILabel alloc]init];
        allContentLabel.text = [NSString stringWithFormat:@"%.0f元",[self.taxDict[@"allTax"] floatValue]];
        self.allContentLabel = allContentLabel;
        allContentLabel.textAlignment = NSTextAlignmentRight;
        allContentLabel.textColor = MainBlackColor;
        allContentLabel.font = [UIFont systemFontOfSize:16];
        allContentLabel.frame = CGRectMake(ScreenWidth * 0.6 - 10, 7,ScreenWidth * 0.4, 30);
        [cell.contentView addSubview:allContentLabel];
    } else {
        if (indexPath.row == 0) {
            
            UILabel *buyTaxTitleLabel = [[UILabel alloc]init];
            buyTaxTitleLabel.text = @"购置税：";
            buyTaxTitleLabel.textAlignment = NSTextAlignmentLeft;
            buyTaxTitleLabel.textColor = MainBlackColor;
            buyTaxTitleLabel.font = [UIFont systemFontOfSize:16];
            buyTaxTitleLabel.frame = CGRectMake(15, 0, ScreenWidth * 0.4, cell.height);
            [cell.contentView addSubview:buyTaxTitleLabel];
            
            UILabel *buyTaxContentLabel = [[UILabel alloc]init];
            buyTaxContentLabel.text = [NSString stringWithFormat:@"%.0f元",[self.taxDict[@"buyTax"] floatValue]];
            buyTaxContentLabel.textAlignment = NSTextAlignmentRight;
            buyTaxContentLabel.textColor = MainBlackColor;
            buyTaxContentLabel.font = [UIFont systemFontOfSize:16];
            buyTaxContentLabel.frame = CGRectMake(ScreenWidth * 0.6 - 10, 7, ScreenWidth * 0.4, 30);
            [cell.contentView addSubview:buyTaxContentLabel];
            
        } else if (indexPath.row == 1) {
            
            UILabel *invaliteTitleLabel = [[UILabel alloc]init];
            invaliteTitleLabel.text = @"上牌费用：";
            invaliteTitleLabel.textAlignment = NSTextAlignmentLeft;
            invaliteTitleLabel.textColor = MainBlackColor;
            invaliteTitleLabel.font = [UIFont systemFontOfSize:16];
            invaliteTitleLabel.frame = CGRectMake(15, 0, ScreenWidth * 0.4, cell.height);
            [cell.contentView addSubview:invaliteTitleLabel];
            
            UILabel *invaliteContentLabel = [[UILabel alloc]init];
            invaliteContentLabel.text = [NSString stringWithFormat:@"%.0f元",[self.taxDict[@"invaliteTax"] floatValue]];
            invaliteContentLabel.textAlignment = NSTextAlignmentRight;
            invaliteContentLabel.textColor = MainBlackColor;
            invaliteContentLabel.font = [UIFont systemFontOfSize:16];
            invaliteContentLabel.frame = CGRectMake(ScreenWidth * 0.6 - 10, 7, ScreenWidth * 0.4, 30);
            [cell.contentView addSubview:invaliteContentLabel];
            
        } else if (indexPath.row == 2) {
            
            UILabel *titleLabel = [[UILabel alloc]init];
            titleLabel.text = @"车船使用税：";
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.textColor = MainBlackColor;
            titleLabel.font = [UIFont systemFontOfSize:16];
            titleLabel.frame = CGRectMake(15, 0, ScreenWidth * 0.4, cell.height);
            [cell.contentView addSubview:titleLabel];
            
            UITextField *carShipField = [[UITextField alloc]init];
            carShipField.frame = CGRectMake(ScreenWidth * 0.6 - 10, 7,ScreenWidth * 0.4, 30);
            carShipField.delegate = self;
            
            carShipField.text = [NSString stringWithFormat:@"%.0f",[self.taxDict[@"carUseTax"] floatValue]];
            
            carShipField.textColor = MainBlackColor;
            
            UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 150)];
            
            inputView.backgroundColor = MainBackGroundColor;
            
            carShipField.inputView = inputView;
            
            //选择视图
            UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:inputView.bounds];
            pickerView.tag = 1;
            
            pickerView.dataSource = self;
            
            pickerView.delegate = self;
            
            [inputView addSubview:pickerView];
            
            self.carShipField = carShipField;
            
            carShipField.delegate = self;
            
            carShipField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            
            carShipField.background = [UIImage imageNamed:@"chexun_models_inputboxbg"];
            
            carShipField.textAlignment = NSTextAlignmentRight;
            
            [cell.contentView addSubview:carShipField];
            
            UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 25)];
            rightLabel.font = [UIFont systemFontOfSize:16];
            
            rightLabel.textColor = MainBlackColor;
            
            rightLabel.text = @"元";
            
            carShipField.rightViewMode = UITextFieldViewModeAlways;
            
            carShipField.rightView = rightLabel;
            
        } else if (indexPath.row == 3) {
            UILabel *titleLabel = [[UILabel alloc]init];
            titleLabel.text = @"交强险：";
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.textColor = MainBlackColor;
            titleLabel.font = [UIFont systemFontOfSize:16];
            titleLabel.frame = CGRectMake(15, 0,ScreenWidth * 0.4, cell.height);
            [cell.contentView addSubview:titleLabel];
            
            UITextField *controlField = [[UITextField alloc]init];
            controlField.frame = CGRectMake(ScreenWidth * 0.6 - 10, 7, ScreenWidth * 0.4, 30);
            controlField.delegate = self;
            controlField.text = [NSString stringWithFormat:@"%.0f",[self.taxDict[@"trafficTax"] floatValue]];
            
            controlField.textColor = MainBlackColor;
            
            UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 150)];
            
            inputView.backgroundColor = MainBackGroundColor;
            
            controlField.inputView = inputView;
            
            //选择视图
            UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:inputView.bounds];
            pickerView.tag = 2;
            
            pickerView.dataSource = self;
            
            pickerView.delegate = self;
            
            [inputView addSubview:pickerView];
            
            self.controlField = controlField;
            
            controlField.delegate = self;
            
            controlField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            
            controlField.background = [UIImage imageNamed:@"chexun_models_inputboxbg"];
            
            controlField.textAlignment = NSTextAlignmentRight;
            
            [cell.contentView addSubview:controlField];
            
            
            
            UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 25)];
            rightLabel.font = [UIFont systemFontOfSize:16];
            
            rightLabel.textColor = MainBlackColor;
            
            rightLabel.text = @"元";
            
            controlField.rightViewMode = UITextFieldViewModeAlways;
            
            controlField.rightView = rightLabel;
        }
        //分割线
        UIView *seperateLine = [[UIView alloc]init];
         seperateLine.backgroundColor = MainLineGrayColor;
        seperateLine.frame = CGRectMake(10, cell.height - 1, ScreenWidth - 10, 1);
        [cell addSubview:seperateLine];
    }
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 10;
    } else {
        return 0;
    }
}

#pragma mark - 数据源方法
/**
 *  一共有多少列
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/**
 *  第component列显示多少行
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

#pragma mark - 代理方法
/**
 *  第component列的第row行显示什么文字
 */

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView *contentView = [[UIView alloc]init];
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    
    [contentView addSubview:contentLabel];
    
    
    if (pickerView.tag == 1) {
        if (row == 0) {
            contentLabel.text = @"各省不统一，北京9座及以下客车480元/年";
        } else if (row == 1) {
            contentLabel.text = @"各省不统一，北京9座及以上客车540元/年";
        }
    }  else {
        if (row == 0) {
            contentLabel.text = @"家用6座以下为950元/年";
        } else if (row == 1) {
            contentLabel.text = @"家用6座以上为1100元/年";
        }
    }
    
    return contentView;
}

/**
 *  选中了第component列的第row行
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        if (row == 0) {
            self.carShipField.text = @"480";
            [self.taxDictM setObject:@0 forKey:@"carShipValueSort"];
        } else if (row == 1) {
            self.carShipField.text = @"540";
            [self.taxDictM setObject:@1 forKey:@"carShipValueSort"];
        }
    }  else {
        if (row == 0) {
            self.controlField.text = @"950";
            [self.taxDictM setObject:@0 forKey:@"trafficValueSort"];
        } else if (row == 1) {
            self.controlField.text = @"1100";
            [self.taxDictM setObject:@1 forKey:@"trafficValueSort"];
        }
        
        //通知代理
        
        
    }
    NSDictionary *allTaxDict = [CalculateTool calculateTax:self.pureValue taxDictM:self.taxDictM];
    CGFloat allTax = [allTaxDict[@"allTax"] floatValue];
    
    self.allContentLabel.text = [NSString stringWithFormat:@"%.0f元",allTax];
    
//    NSDictionary *dict = self.contentArr[row];
//    self.contentField.text = [NSString stringWithFormat:@"%@",dict[@"value"]];
//    
//    //通知代理
//    if ([self.delegate respondsToSelector:@selector(carInsuranceCellChangeValue:component:)]) {
//        [self.delegate carInsuranceCellChangeValue:self.rowValue component:row];
//    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
