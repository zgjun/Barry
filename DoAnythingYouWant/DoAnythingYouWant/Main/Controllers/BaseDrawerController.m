//
//  BaseDrawerController.m
//  DoAnythingYouWant
//
//  Created by zgjun on 15/12/28.
//  Copyright © 2015年 barry. All rights reserved.
//

#import "BaseDrawerController.h"
#import "BaseTabBarController.h"
#import "MenuViewController.h"

@interface BaseDrawerController ()

@end

@implementation BaseDrawerController

- (instancetype)initWithMainController:(UIViewController *)mainViewController {
    if (self = [super init]) {
        self.mainControl = mainViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    
    MenuViewController *leftVc = [[MenuViewController alloc]init];
    
    [self.leftControl addChildViewController:leftVc];
    [self.leftControl.view addSubview:leftVc.view];
    
    [self.leftControl.view addSubview:self.tapView];
    
//    [self.tapView bringSubviewToFront:leftVc.view];
    
    
    
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
