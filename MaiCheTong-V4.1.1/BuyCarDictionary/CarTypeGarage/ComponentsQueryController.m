//
//  ComponentsQueryController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ComponentsQueryController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "InvaliteTool.h"
#import "CityChooseController.h"
#import "QueryDealerCell.h"

#define QueryPriceGap 10

@interface ComponentsQueryController ()<UITableViewDataSource,UITableViewDelegate,CityChooseControllerDelegate,QueryDealerCellDelegate,UITextFieldDelegate>

@property (nonatomic,weak) UITableView *tableView;


@property (nonatomic,weak) UILabel * carSeriesLabel;

@property (nonatomic,weak) UILabel * carTypeLabel;

@property (nonatomic,weak) UILabel * carPriceLabel;


@property (nonatomic,strong) NSDictionary *carTypeDict;

@property (nonatomic,strong) NSMutableArray *dealers;

///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;



@property (nonatomic,strong) NSTimer *secondTimer;

@property (nonatomic,assign) NSInteger secondsCount;


@property (nonatomic,weak) UITextField *phoneField;

@property (nonatomic,weak) UITextField *nameField;


@property (nonatomic,weak) UIButton *cityBtn;

@property (nonatomic,strong) NSString *cityId;


@property (nonatomic,strong) NSString *cityStr;

@property (nonatomic,strong) NSMutableArray *dealersM;

//经度

@property (nonatomic,strong) NSString *longitude;

//纬度

@property (nonatomic,strong) NSString *latitude;

@property (nonatomic,assign) NSInteger indicator;

@property (nonatomic,strong) NSString *nameStr;
@property (nonatomic,strong) NSString *phoneStr;
@property (nonatomic,strong) NSString *valicodeStr;

@property (nonatomic,weak) UIButton *commitBtn;

@property (nonatomic,strong) CityChooseController *cityVc;

@end

@implementation ComponentsQueryController
- (NSString *)longitude {
    
    _longitude = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityLongitude];
    
    if (_longitude == nil) {
        
        _longitude = [NSString stringWithFormat:@"116.33187772"];
        
    }
    return _longitude;
    
}
- (NSString *)latitude {
    
    _latitude = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityLatitude];
    
    if (_latitude == nil) {
        
        _latitude = [NSString stringWithFormat:@"39.99749624"];
        
    }
    
    
    
    return _latitude;
    
}

- (NSMutableArray *)dealersM {
    if (_dealersM == nil) {
        _dealersM = [NSMutableArray array];
    }
    return _dealersM;
}

- (NSString *)cityStr {
    _cityStr = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    
    if (_cityStr == nil) {
        _cityStr = [NSString stringWithFormat:@"北京"];
    }
    return _cityStr;
}


- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}


- (instancetype)initWithCarTypeDict:(NSDictionary *)carTypeDict {
    if (self = [super init]) {
        self.carTypeDict = carTypeDict;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"询更低价";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = MainBackGroundColor;
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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"询更低价";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.showsVerticalScrollIndicator = NO;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"QueryLowPriceCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    //初始化相关值
    self.indicator = 0;
    
    
    //添加键盘的监听通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:@"applicationWillResignActive" object:nil];
    
    
    [MBProgressHUD showHUDAddedTo:self.tableView  animated:YES];
    
    [self getData];
}

- (void)resignActive {
//    [self.view resignFirstResponder];
    [self.phoneField endEditing:YES];
    [self.nameField endEditing:YES];

}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersInfo3.ashx?sortType=0&cityId=%@&longitude=%@&latitude=%@&ModelID=%@",self.cityId,self.longitude,self.latitude,self.carTypeDict[@"carTypeId"]];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //为什么没加__block也可以更改值
        
        self.dealers = [NSMutableArray arrayWithArray:responseObject[@"dealerList"]] ;
        
        for (int i = 0 ; i < self.dealers.count; i++) {
            NSDictionary *dict = self.dealers[i];
            if ([dict[@"DealerLevel"] integerValue] > 0 && [dict[@"DealerLevel"] integerValue] < 60) {
                self.indicator = 1;
                break;
            }
        }
        
        [self.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
        MyLog(@"%@",error);
        
    }];
}


- (void)dealloc {
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    MyLog(@"%s",__FILE__);

}

- (void)commitBtnClick {
    self.commitBtn.enabled = NO;
    
    //判断姓名
    if (self.nameField.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入姓名！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        [self.nameField becomeFirstResponder];
        self.commitBtn.enabled = YES;
        return;
    }
    
    //判断姓名长度不超过10个字
    if (self.nameField.text.length > 10) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"姓名长度不能超过10，请重新输入！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        [self.nameField becomeFirstResponder];
        self.commitBtn.enabled = YES;
        return;
    }
    
    NSString *phone = self.phoneField.text;
    //验证手机号是否合法
    BOOL isPhone = [InvaliteTool checkTel:phone];
    
    if (!isPhone) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入正确的手机号！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        [self.phoneField becomeFirstResponder];
        self.commitBtn.enabled = YES;
        return;
    }
    
    //判断是否选择了经销商
    if (self.dealersM.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请选择经销商！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        self.commitBtn.enabled = YES;
        return;
    }
    
    NSString *strKey = [InvaliteTool md5Digest:[NSString stringWithFormat:@"%@@CheXun",phone]];
    
    NSString *url = [NSString stringWithFormat:@"http://reg.chexun.com/api/checkvalidcode.ashx?phone=%@&key=%@",phone,strKey];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html" ,nil];
    
    
    __weak ComponentsQueryController *myself = self;
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = responseObject[0];
        //判断验证码
        if ([dict[@"code"] integerValue] == -1) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"验证码错误！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            
            [alert show];
            myself.commitBtn.enabled = YES;
            return;
        } else {
            
            //拼接经销商ID
            NSMutableString *stringM = [NSMutableString string];
            for (int i = 0; i < myself.dealersM.count; i++) {
                NSString *dealerId = myself.dealersM[i];
                if (i == myself.dealersM.count - 1) {
                    [stringM appendString:dealerId];
                } else {
                    [stringM appendString:[NSString stringWithFormat:@"%@,",dealerId]];
                }
            }
            NSString *commitUrl = [NSString stringWithFormat:@"http://dealer.chexun.com/API/FenFaXunJiaHandler3.ashx?phone=%@&seriesId=%@&modelId=%@&userName=%@&cityId=%@&Source=2&DealersID=%@",phone,myself.carTypeDict[@"carSeriesId"],myself.carTypeDict[@"carTypeId"],myself.nameField.text,myself.cityId,stringM];
            
            commitUrl =  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)commitUrl, NULL, NULL,  kCFStringEncodingUTF8 ));
            
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:commitUrl]];
            
            NSURLResponse *response = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
            NSString *result =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([result integerValue] == 1) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"提交成功！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                
                [alert show];
                myself.commitBtn.enabled = YES;
                return;
            } else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"提交失败！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                
                [alert show];
                myself.commitBtn.enabled = YES;
                return;
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"提交失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        myself.commitBtn.enabled = YES;
        return;
    }];
    
}

- (void)keyboardWasChange:(NSNotification *)aNotification {
    
    // 0.取出键盘动画的时间
    CGFloat duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height;
    
    // 3.执行动画
    if (transformY < 0) {
        [UIView animateWithDuration:duration animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, transformY + 150);
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    }
    
    
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 4;
    } else {
        return self.dealers.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"QueryLowPriceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    switch (indexPath.section) {
        case 0:{
            UILabel * carTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth - 20, 35)];
            self.carTypeLabel = carTypeLabel;
            NSString *carTypeName = [NSString stringWithFormat:@"%@ %@",self.carTypeDict[@"carSeriesName"],self.carTypeDict[@"carTypeName"]];
            carTypeLabel.text = carTypeName;
            carTypeLabel.textAlignment = NSTextAlignmentLeft;
            carTypeLabel.font = [UIFont systemFontOfSize:16];
            carTypeLabel.textColor = MainFontGrayColor;
            [cell.contentView addSubview:carTypeLabel];
            
            UILabel *carPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(carTypeLabel.frame), ScreenWidth - 20, 20)];
            carPriceLabel.textAlignment = NSTextAlignmentLeft;
            carPriceLabel.text = [NSString stringWithFormat:@"%.2f万元",[self.carTypeDict[@"carTypePrice"] floatValue]];
            self.carPriceLabel = carPriceLabel;
            carPriceLabel.font = [UIFont systemFontOfSize:14];
            carPriceLabel.textColor = MainFontGrayColor;
            [cell.contentView addSubview:carPriceLabel];
            
            break;
        }
        case 1:{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0) {
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(QueryPriceGap, QueryPriceGap, 100, 24)];
                nameLabel.text = @"姓         名：";
                nameLabel.font = [UIFont systemFontOfSize:16];
                nameLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:nameLabel];
                
                UITextField *nameField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame), QueryPriceGap, 120, 24)];
                nameField.tag = 1;
                nameField.delegate = self;
                nameField.returnKeyType = UIReturnKeyNext;
                self.nameField = nameField;
                [nameField addTarget:self action:@selector(nameFieldChange:) forControlEvents:UIControlEventEditingChanged];
                if (self.nameStr.length > 0) {
                    self.nameField.text = self.nameStr;
                }
                
                nameField.font = [UIFont systemFontOfSize:16];
                nameField.textColor = MainBlackColor;
                [cell.contentView addSubview:nameField];
            } else if (indexPath.row == 1) {
                UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(QueryPriceGap, QueryPriceGap, 100, 24)];
                phoneLabel.text = @"手   机   号：";
                phoneLabel.font = [UIFont systemFontOfSize:16];
                phoneLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:phoneLabel];
                
                UITextField *phoneField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneLabel.frame), QueryPriceGap, 120, 24)];
                phoneField.tag = 2;
                phoneField.delegate = self;
                phoneField.keyboardType = UIKeyboardTypeNumberPad;
                phoneField.returnKeyType = UIReturnKeyDone;
                self.phoneField = phoneField;
                
                [phoneField addTarget:self action:@selector(phoneFieldChange:) forControlEvents:UIControlEventEditingChanged];

                if (self.phoneStr.length > 0) {
                    self.phoneField.text = self.phoneStr;
                }
                phoneField.font = [UIFont systemFontOfSize:16];
                phoneField.textColor = MainBlackColor;
                [cell.contentView addSubview:phoneField];
                
            } else if (indexPath.row == 2){
                UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(QueryPriceGap, QueryPriceGap, 100, 24)];
                cityLabel.text = @"城          市：";
                cityLabel.font = [UIFont systemFontOfSize:16];
                cityLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:cityLabel];
                
                UIButton *cityBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cityLabel.frame), QueryPriceGap, 80, 24)];
                self.cityBtn = cityBtn;
                [cityBtn setTitleColor:MainBlackColor forState:UIControlStateNormal];
                
                [cityBtn setTitle:self.cityStr forState:UIControlStateNormal];
                cityBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                cityBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                [cityBtn addTarget:self action:@selector(cityBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:cityBtn];
            } else {
                
                //提交信息
                
                UIButton *commitBtn = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth - 282) * 0.5, QueryPriceGap, 282, 44)];
                self.commitBtn = commitBtn;
                [commitBtn setTitle:@"提交信息" forState:UIControlStateNormal];
                [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [commitBtn setBackgroundImage:[UIImage imageNamed:@"chexun_okbutbg"] forState:UIControlStateNormal];
                [commitBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:commitBtn];
                
            }
            
            UIView *bottomLine = [[UIView alloc]init];
             bottomLine.backgroundColor = MainLineGrayColor;
            bottomLine.frame = CGRectMake(0, cell.height - 1,ScreenWidth, 1);
            [cell.contentView addSubview:bottomLine];
            
            break;
        }
        case 2:{
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            QueryDealerCell *dealerCell = [[QueryDealerCell alloc]init];
            dealerCell.frame = cell.bounds;
            
            NSMutableDictionary *queryDictM = [NSMutableDictionary dictionaryWithDictionary:self.dealers[indexPath.row]];
            
            
            if (self.indicator == 0 && indexPath.row == 0 && queryDictM[@"isMemberUser"] == nil) {
                [queryDictM setObject:@1 forKey:@"isMemberUser"];
                [self.dealersM addObject:queryDictM[@"dealerId"]];
            }
            
            if (queryDictM[@"isMemberUser"] == nil) {
                if ([queryDictM[@"DealerLevel"] integerValue] > 0 && [queryDictM[@"DealerLevel"] integerValue] < 60) {
                    [queryDictM setObject:@1 forKey:@"isMemberUser"];
                    [self.dealersM addObject:queryDictM[@"dealerId"]];
                } else {
                    [queryDictM setObject:@0 forKey:@"isMemberUser"];
                }
            }
            
            dealerCell.queryDict = queryDictM;
            dealerCell.tag = indexPath.row;
            
            dealerCell.delegate = self;
            [cell.contentView addSubview:dealerCell];
            
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
    if (indexPath.section == 0) {
        return 60;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 3) {
            return 64;
        } else {
            return 44;
        }
        
    } else {
        return 80;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *secHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    secHeadView.backgroundColor = MainBackGroundColor;
    
    UILabel *secHeadLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, 30)];
    [secHeadView addSubview:secHeadLabel];
    
    if (section == 0) {
        secHeadLabel.text = @"车型";
    } else if (section == 1) {
        secHeadLabel.text = @"个人信息";
    } else {
        secHeadLabel.text = @"经销商报价";
    }
    
    return secHeadView;
    
}
#pragma mark - 文本值改变
- (void)nameFieldChange:(UITextField *)textField {
    self.nameStr = textField.text;
}

- (void)phoneFieldChange:(UITextField *)textField {
    self.phoneStr = textField.text;
}

- (void)verifiCodeFieldChange:(UITextField *)textField {
    self.valicodeStr = textField.text;
}



///城市按钮的点击
- (void)cityBtnClick:(UIButton *)cityBtn {
    
    [self.view endEditing:YES];
    CityChooseController *cityVc = [[CityChooseController alloc]init];
    self.cityVc = cityVc;
    cityVc.cityDelegate = self;
    [self.navigationController pushViewController:cityVc animated:YES];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self.view endEditing:YES];
}

//城市控制器的代理方法
- (void)didCityTableRowClick:(CityChooseController *)cityVc infoDict:(NSDictionary *)infoDict {
    
    self.cityId = infoDict[@"cityId"];
    
    [self.cityBtn setTitle:infoDict[@"cityName"] forState:UIControlStateNormal];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    self.dealersM = nil;
    
    [self getData];
    
}

- (void)queryCellClick:(QueryDealerCell *)dealerCell QueryBtn:(UIButton *)queryBtn {
    NSString *dealerId = dealerCell.queryDict[@"dealerId"];
    
    [self.dealers replaceObjectAtIndex:dealerCell.tag withObject:dealerCell.queryDict];
    
    if (queryBtn.selected) {
        [self.dealersM addObject:dealerId];
    } else {
        
        [self.dealersM removeObject:dealerId];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1) {
        [self.phoneField becomeFirstResponder];
    } else if (textField.tag == 2) {
        [textField endEditing:YES];
    }
    
    
    return YES;
}



@end
