//
//  OtherButCarController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-22.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherBuyCarController.h"
#import "OtherChooseController.h"
#import "SeriesAndTypeController.h"
#import "OtherCarTypeController.h"
#import "CarTaxController.h"
#import "CarInsuranceController.h"
#import "CalculateTool.h"
#import "MainTabBarController.h"

#define WrongNum -1000

#define OtherBuyGap 10

#define TableHeight (10 * 2 + 4 * 44 + 60)

@interface OtherBuyCarController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,CarInsuranceControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSString *carSeriesName;

@property (nonatomic,strong) NSString *carTypeName;

@property (nonatomic,weak) UILabel * carSeriesLabel;

@property (nonatomic,weak) UILabel * carTypeLabel;

@property (nonatomic,weak) UILabel * carPriceLabel;

@property (nonatomic,strong) NSString *carSeriesId;

@property (nonatomic,strong) NSString *carTypeId;

@property (nonatomic,weak) UITextField *pureText;

@property (nonatomic,strong) NSString *guidePrice;

@property (nonatomic,strong) NSString *lowPrice;

@property (nonatomic,assign) CGFloat pureValue;

/*

///税
@property (nonatomic,assign) NSInteger buyTax;
@property (nonatomic,assign) NSInteger invaliteTax;
@property (nonatomic,assign) NSInteger carUseTax;
@property (nonatomic,assign) NSInteger trafficTax;
@property (nonatomic,assign) NSInteger allTax;



///险
@property (nonatomic,assign) NSInteger thirdInsurance;
@property (nonatomic,assign) NSInteger loseInsurance;
@property (nonatomic,assign) NSInteger carStealInsurance;
@property (nonatomic,assign) NSInteger glassInsurance;
@property (nonatomic,assign) NSInteger burnInsurance;
@property (nonatomic,assign) NSInteger ingnoreInsurance;
@property (nonatomic,assign) NSInteger carPeopleInsurance;
@property (nonatomic,assign) NSInteger scratchInsurance;
@property (nonatomic,assign) NSInteger allInsurance;
@property (nonatomic,assign) NSInteger noWrongInsurance;
 
 */

@property (nonatomic,strong) NSMutableDictionary *taxDictM;

@property (nonatomic,strong) NSMutableDictionary *insuranceDictM;

@property (nonatomic,weak) UILabel *taxValue;

@property (nonatomic,weak) UILabel *insuranceValue;

@property (nonatomic,weak) UILabel *allValue;

@property (nonatomic,assign) CGFloat currentAllInsurance;


//税费的改变状态
@property (nonatomic,assign) NSInteger taxChangeState;


//保险费的改变状态
@property (nonatomic,assign) NSInteger insuranceChangeState;

@property (nonatomic,assign) NSInteger familySites;

@property (nonatomic,strong) OtherChooseController *otherChooseVc;

@end

@implementation OtherBuyCarController

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
    
    
    self.view.backgroundColor = MainBackGroundColor;
    
    
    self.carSeriesName = @"添加车系（必选）";
    self.carTypeName = @"添加车型（必选）";
    
    
    /*
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -20;
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_home_backarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, backItem];
    */
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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, 20, 150, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"购车计算器";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, TableHeight)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.showsVerticalScrollIndicator = NO;
    
    //表格注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"OtherByCarCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    //通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carDetailSelected:) name:@"OtherCarDetail" object:nil];
    
    self.currentAllInsurance = WrongNum;
    self.taxChangeState = WrongNum;
    self.insuranceChangeState = WrongNum;
    
}

- (void)carDetailSelected:(NSNotification *)notification {
    
    NSDictionary *dict = notification.userInfo;
    
    
    self.carTypeName = [NSString stringWithFormat:@"%@ %@", dict[@"seriesName"], dict[@"name"]];
    
    self.carTypeId = [NSString stringWithFormat:@"%@", dict[@"id"]];
    
    self.guidePrice = [NSString stringWithFormat:@"%@",dict[@"guidePrice"]];
    
    self.lowPrice = [NSString stringWithFormat:@"%@",dict[@"MinPrice"]];
    
    if ([self.lowPrice floatValue] != 0) {
        self.pureValue = [self.lowPrice floatValue];
    } else if ([self.lowPrice floatValue] == 0 && [self.guidePrice floatValue] != 0) {
        self.pureValue = [self.guidePrice floatValue];
    }
    
    
    //清空数组
    self.insuranceDictM = nil;
    
    self.currentAllInsurance = WrongNum;
    
}

- (void)dealloc {
    //移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    MyLog(@"%s",__FILE__);
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
    
    //刷新表格的第一个section
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 4;
    } else {
        return 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"OtherByCarCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    switch (indexPath.section) {
        case 0:{
            UILabel * carTypeLabel = [[UILabel alloc]init];
            carTypeLabel.numberOfLines = -1;
            self.carTypeLabel = carTypeLabel;
            carTypeLabel.text = self.carTypeName;
            carTypeLabel.font = [UIFont systemFontOfSize:16];

            CGSize carTypeMaxSize = CGSizeMake(ScreenWidth - 20 - 10, cell.height);
            
            NSDictionary *carTypeAttrs = @{NSFontAttributeName : carTypeLabel.font};
            
            CGSize carTypeSize = [self.carTypeName boundingRectWithSize:carTypeMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:carTypeAttrs context:nil].size;
            
            carTypeLabel.frame = CGRectMake(10,0, carTypeSize.width, cell.height);
            
            
            carTypeLabel.textAlignment = NSTextAlignmentLeft;
                        carTypeLabel.textColor = MainFontGrayColor;
            [cell.contentView addSubview:carTypeLabel];
            
            UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 18, 5, 8)];
            indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];                [cell.contentView addSubview:indicatorImage];
            break;
        }
        case 1:{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0) {
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(OtherBuyGap, OtherBuyGap, 100, 24)];
                nameLabel.text = @"裸  车  价：";
                
                nameLabel.font = [UIFont systemFontOfSize:16];
                nameLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:nameLabel];
                
                UITextField *pureText = [[UITextField alloc]initWithFrame:CGRectMake(ScreenWidth - 100 - 30, 5, 100, 34)];
                pureText.returnKeyType = UIReturnKeyDone;
                pureText.placeholder = @"例：28.98";
                pureText.delegate = self;
                self.pureText = pureText;
                [pureText addTarget:self action:@selector(pureTextChanged:) forControlEvents:UIControlEventEditingChanged];
                
                pureText.font = [UIFont systemFontOfSize:16];
                
                pureText.textColor = MainFontGrayColor;
                
                pureText.tag = 1;
                
                pureText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                
                pureText.background = [UIImage imageNamed:@"chexun_inputbox"];
                
                pureText.textAlignment = NSTextAlignmentRight;
                [cell.contentView addSubview:pureText];
                
                if (self.pureValue != 0) {
                    
                    pureText.text = [NSString stringWithFormat:@"%.2f",self.pureValue];
                }
                
                
                UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 24)];
                rightLabel.font = [UIFont systemFontOfSize:16];
                
                rightLabel.text = @"万";
                pureText.rightViewMode = UITextFieldViewModeAlways;
                pureText.rightView = rightLabel;
                
                if ([self.pureText.text floatValue] == 0) {
                    rightLabel.textColor = MainFontGrayColor;
                } else {
                    rightLabel.textColor = MainFontGrayColor;
                }
                
            } else if (indexPath.row == 1) {
                UILabel *taxLabel = [[UILabel alloc]initWithFrame:CGRectMake(OtherBuyGap, OtherBuyGap, 100, 24)];
                taxLabel.text = @"各项税费：";
                taxLabel.font = [UIFont systemFontOfSize:16];
                
                taxLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:taxLabel];
                
                UILabel *taxValue = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 100 - 30, OtherBuyGap, 100, 24)];
                NSDictionary *allTaxDict = [CalculateTool calculateTax:self.pureValue taxDictM:self.taxDictM];
                CGFloat allTax = [allTaxDict[@"allTax"] floatValue];
                taxValue.text = [NSString stringWithFormat:@"%.2f万",allTax / 10000.0];
                taxValue.textAlignment = NSTextAlignmentRight;
                self.taxValue = taxValue;
                taxValue.font = [UIFont systemFontOfSize:16];
                taxValue.textColor = MainBlackColor;
                [cell.contentView addSubview:taxValue];
                
                if ([self.pureText.text floatValue] == 0) {
                    taxValue.hidden = YES;
                } else {
                    taxValue.hidden = NO;
                }
                
                
                UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 20, 15, 10, 15)];
                indicatorImage.image = [UIImage imageNamed:@"chexun_models_rightarroow"];
                [cell.contentView addSubview:indicatorImage];
                
            } else if (indexPath.row == 2) {
                UILabel *insuranceLabel = [[UILabel alloc]initWithFrame:CGRectMake(OtherBuyGap, OtherBuyGap, 100, 24)];
                insuranceLabel.text = @"商业保险：";
                insuranceLabel.font = [UIFont systemFontOfSize:16];
                insuranceLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:insuranceLabel];
                
                UILabel *insuranceValue = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 100 - 30, OtherBuyGap, 100, 24)];
                NSDictionary *allInsuranceDict = [CalculateTool calculateInsurance:self.pureValue insureDictM:self.insuranceDictM familySites:self.familySites];
                self.currentAllInsurance = [allInsuranceDict[@"allInsurance"] floatValue];
                insuranceValue.text = [NSString stringWithFormat:@"%.2f万",self.currentAllInsurance / 10000.0];
                self.insuranceValue = insuranceValue;
                insuranceValue.textAlignment = NSTextAlignmentRight;
                insuranceValue.font = [UIFont systemFontOfSize:16];
                insuranceValue.textColor = MainBlackColor;
                [cell.contentView addSubview:insuranceValue];
                
                if ([self.pureText.text floatValue] == 0) {
                    insuranceValue.hidden = YES;
                } else {
                    insuranceValue.hidden = NO;
                }
                
                
                UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 20, 15, 10, 15)];
                indicatorImage.image = [UIImage imageNamed:@"chexun_models_rightarroow"];
                [cell.contentView addSubview:indicatorImage];
            } else {
                UILabel *allLabel = [[UILabel alloc]initWithFrame:CGRectMake(OtherBuyGap, 26, 100, 24)];
                allLabel.text = @"全款总价：";
                allLabel.font = [UIFont systemFontOfSize:16];
                allLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:allLabel];
                
                UILabel *allValue = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 100 - 30, 20, 100, 24)];
                self.allValue = allValue;
                allValue.textAlignment = NSTextAlignmentRight;
                NSDictionary *allTaxDict = [CalculateTool calculateTax:self.pureValue taxDictM:self.taxDictM];
                CGFloat allTax = [allTaxDict[@"allTax"] floatValue];
                CGFloat allprice = self.pureValue + (allTax / 10000.0) + (self.currentAllInsurance / 10000.0);
                allValue.text = [NSString stringWithFormat:@"%.2f",allprice];
                allValue.textColor = MainFontRedColor;
                allValue.font = [UIFont systemFontOfSize:30];
                [cell.contentView addSubview:allValue];
                
                UILabel *allPriceWan = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(allValue.frame), 26, 15, 24)];
                allPriceWan.textAlignment = NSTextAlignmentLeft;
                allPriceWan.text = @"万";
                allPriceWan.textColor = MainFontRedColor;
                allPriceWan.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:allPriceWan];
                
                if ([self.pureText.text floatValue] == 0) {
                    allPriceWan.hidden = YES;
                    allValue.hidden = YES;
                } else {
                    allPriceWan.hidden = NO;
                    allValue.hidden = NO;
                }
            }
            UIView *bottomLine = [[UIView alloc]init];
            bottomLine.backgroundColor = MainLineGrayColor;
            bottomLine.frame = CGRectMake(0, cell.height - 1,ScreenWidth, 1);
            [cell.contentView addSubview:bottomLine];
            
            break;
        }
        default:
            break;
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return 60;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *secHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    secHeadView.backgroundColor = MainBackGroundColor;
    
    return secHeadView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        OtherChooseController *otherChooseVc = [[OtherChooseController alloc]initWithIndicator:@"CarType"];
        self.otherChooseVc = otherChooseVc;
        [self.navigationController pushViewController:otherChooseVc animated:YES];
    } else {
        if (indexPath.row == 1) {
            if ([self.pureText.text floatValue] == 0) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"请输入裸车价！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                
                [alert show];
                [self.pureText becomeFirstResponder];
                return;
            } else {
                CarTaxController *carTaxVc = [[CarTaxController alloc]initWithTaxDictM:self.taxDictM pureValue:self.pureValue];
                [self.navigationController pushViewController:carTaxVc animated:YES];
            }
            
        } else if (indexPath.row ==2) {
            if ([self.pureText.text floatValue] == 0) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"请输入裸车价！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                
                [alert show];
                [self.pureText becomeFirstResponder];
                return;
            } else {
                CarInsuranceController *carInsuranceVc = [[CarInsuranceController alloc]initWithInsuranceDictM:self.insuranceDictM pureValue:self.pureValue familySites:self.familySites];
                
                carInsuranceVc.delegate = self;
                [self.navigationController pushViewController:carInsuranceVc animated:YES];
            }

        }
        
    }
}


#pragma mark - 代理方法
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


#pragma mark - 按钮点击事件


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


- (void)pureTextChanged:(UITextField *)textField {
    
    
    self.pureValue = [textField.text floatValue];
    
    if (self.pureValue > 0) {
        self.taxValue.hidden = NO;
        self.insuranceValue.hidden = NO;
        self.allValue.hidden = NO;
    }
    
    //重置
    [self resetTaxState];
    [self resetInsuranceState];
    
    NSDictionary *allInsuranceDict = [CalculateTool calculateInsurance:self.pureValue insureDictM:self.insuranceDictM familySites:self.familySites];
    CGFloat allInsurance = [allInsuranceDict[@"allInsurance"] floatValue];
    
    NSDictionary *allTaxDict = [CalculateTool calculateTax:self.pureValue taxDictM:self.taxDictM];
    CGFloat allTax = [allTaxDict[@"allTax"] floatValue];
    
    self.taxValue.text = [NSString stringWithFormat:@"%.2f万",allTax / 10000.0];
    
    self.insuranceValue.text = [NSString stringWithFormat:@"%.2f万",allInsurance / 10000.0];
    
    CGFloat allprice = self.pureValue + (allTax / 10000.0) + (allInsurance / 10000.0);
    self.allValue.text = [NSString stringWithFormat:@"%.2f",allprice];
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

@end
