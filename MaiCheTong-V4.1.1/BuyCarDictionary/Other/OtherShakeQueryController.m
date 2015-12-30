//
//  OtherShakeQueryController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-22.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherShakeQueryController.h"
#import "AFNetworking.h"
#import "UIImage+Extension.h"

#import "MainTabBarController.h"

#define ShakeQueryGap 10
#define conditionViewHeight 150

@interface OtherShakeQueryController ()<UIGestureRecognizerDelegate,UITextFieldDelegate>

@property (nonatomic,weak) UITextField *noTextField;

@property (nonatomic,weak) UILabel *showResultLabel;

@end

@implementation OtherShakeQueryController
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
    self.tabBarController.tabBar.hidden = YES;
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
    
    titleLabel.text = @"摇号查询";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    [self createChildViews];
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
}


- (void)createChildViews {
    UIView *conditionView = [[UIView alloc]initWithFrame:CGRectMake(0,64 + ShakeQueryGap, ScreenWidth, conditionViewHeight)];
    conditionView.backgroundColor = MainWhiteColor;
    [self.view addSubview:conditionView];
    
    UILabel *showLabel = [[UILabel alloc]initWithFrame:CGRectMake(ShakeQueryGap, ShakeQueryGap, ScreenWidth - ShakeQueryGap, 30)];
    showLabel.font = [UIFont systemFontOfSize:15];
    showLabel.text = @"查询北京机动车摇号中签情况";
    showLabel.backgroundColor = MainWhiteColor;
    [conditionView addSubview:showLabel];
    
    UITextField *noTextField = [[UITextField alloc]initWithFrame:CGRectMake(ShakeQueryGap, CGRectGetMaxY(showLabel.frame) + ShakeQueryGap * 2, ScreenWidth, 30)];
    noTextField.font = [UIFont systemFontOfSize:15];
    [noTextField leftViewRectForBounds:CGRectMake(10, 0, 5, 20)];
    noTextField.placeholder = @"请输入申请编号：";
    noTextField.keyboardType = UIKeyboardTypeNumberPad;
    noTextField.returnKeyType = UIReturnKeyDone;
    noTextField.delegate = self;
    self.noTextField = noTextField;
    [conditionView addSubview:noTextField];
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(noTextField.frame), ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [conditionView addSubview:spliteLine];
    
    
    UIButton *queryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    queryBtn.frame = CGRectMake((ScreenWidth - 250) * 0.5, CGRectGetMaxY(spliteLine.frame) + 2 *ShakeQueryGap , 250, 35);
    
    [queryBtn setBackgroundImage:[UIImage resizableImageWithName:@"chexun_okbutbg"] forState:UIControlStateNormal];
    [queryBtn setTitle:@"查   询" forState:UIControlStateNormal];
    [queryBtn addTarget:self action:@selector(queryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [conditionView addSubview:queryBtn];
    
    UIView *resultView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(conditionView.frame) + ShakeQueryGap, ScreenWidth, 40)];
    resultView.backgroundColor = MainWhiteColor;
    [self.view addSubview:resultView];
    
    
    UILabel *resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(ShakeQueryGap, 0, 90, 40)];
    resultLabel.font = [UIFont systemFontOfSize:15];
    resultLabel.text = @"查询结果：";
    [resultView addSubview:resultLabel];
    
    
    UILabel *showResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(resultLabel.frame), 0, ScreenWidth - 100, 40)];
    self.showResultLabel = showResultLabel;
    showResultLabel.font = [UIFont systemFontOfSize:15];
    [resultView addSubview:showResultLabel];
    
}

- (void)queryBtnClick {
    NSString *queryStr = self.noTextField.text;
    
    if ([queryStr length]<=12) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入正确的申请编号！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [self.noTextField becomeFirstResponder];
        return;
    }
    
    
    NSString *urlStr = [NSString stringWithFormat:@"http://3g.chexun.com/api/getyaohao.ashx?name=%@",queryStr];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    __weak OtherShakeQueryController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = responseObject[0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([dict[@"Code"] integerValue] == 1) {
                myself.showResultLabel.text = [NSString stringWithFormat:@"恭喜您！在%@期已中签！",dict[@"Issue"]];
            } else {
                myself.showResultLabel.text = [NSString stringWithFormat:@"抱歉！未中签！"];
            }
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MyLog(@"error:%@",error);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField endEditing:YES];
    
    return YES;
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}

@end
