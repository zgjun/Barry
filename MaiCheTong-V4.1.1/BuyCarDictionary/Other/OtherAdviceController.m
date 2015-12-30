//
//  OtherAdviceController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-27.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherAdviceController.h"
#import "OtherAdviceView.h"

@interface OtherAdviceController ()

@end

@implementation OtherAdviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"意见反馈";
    
    self.view.backgroundColor = MainBackGroundColor;
    
    
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
    
    [self createChildViews];
}

- (void)createChildViews {
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + 15, ScreenWidth, 130)];
    textView.backgroundColor = MainWhiteColor;
    [self.view addSubview:textView];
    
    OtherAdviceView *contentText = [[OtherAdviceView alloc]init];
    contentText.frame = CGRectMake(0, 0, ScreenWidth, 130);
    contentText.placeholder = @"请输入错误信息以及正确信息，如报价错误，电话错误，车系参数错误...";
    contentText.contentMode = UIViewContentModeTopLeft;
    [textView addSubview:contentText];
    
    UIView *phoneView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(textView.frame) + 15, ScreenWidth, 35)];
    phoneView.backgroundColor = MainWhiteColor;
    [self.view addSubview:phoneView];
    
    UITextField *phoneField = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, ScreenWidth - 10, 35)];
    phoneField.placeholder = @"请输入您的手机号码";
    [phoneView addSubview:phoneField];
    
    //提交按钮
    UIButton *commitBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(phoneView.frame) + 15, ScreenWidth - 30, 35)];
    [commitBtn setTitle:@"提交信息" forState:UIControlStateNormal];
    commitBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"chexun_home_filterbut_navbar"] forState:UIControlStateNormal];
    [self.view addSubview:commitBtn];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
