//
//  LifeViewController.m
//  DoAnythingYouWant
//
//  Created by zgjun on 15/12/24.
//  Copyright © 2015年 barry. All rights reserved.
//

#import "LifeViewController.h"
#import "BaseDrawerController.h"

@interface LifeViewController ()

@end

@implementation LifeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *leftMenuBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [leftMenuBtn setBackgroundImage:[UIImage imageNamed:@"icon_title_drawer"] forState:UIControlStateNormal];
    [leftMenuBtn addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftMenuBtn];
//    [self.navigationItem.leftBarButtonItem setAction:@selector(hehe)];
    
}

- (void)menuClick:(UIButton *)menuBtn {
    MyLog(@"%s",__func__);
    
    BaseDrawerController * baseDrawerVc = (BaseDrawerController *)self.view.window.rootViewController;
    [baseDrawerVc showLeftView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
