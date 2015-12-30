//
//  BaseTabBarController.m
//  DoAnythingYouWant
//
//  Created by zgjun on 15/12/24.
//  Copyright © 2015年 barry. All rights reserved.
//

#import "BaseTabBarController.h"
#import "TabbarCustom.h"
#import "TabbarItem.h"
#import "BaseNavigationController.h"
#import "LifeViewController.h"
#import "NewsViewController.h"
#import "EntertainmentViewController.h"
#import "TestEffectViewController.h"

#define TabbarNum 4

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //deal with tabbar
    self.tabBar.hidden = YES;
    self.tabbarBounds = self.tabBar.bounds;
    self.tabbarCustom = [[TabbarCustom alloc]init];
    self.tabbarCustom.frame = CGRectMake(0, ScreenHeight -  self.tabbarBounds.size.height, ScreenWidth, self.tabbarBounds.size.height);
    [self.view addSubview:self.tabbarCustom];
    
    NSArray *titles = @[@"生活",@"新闻",@"娱乐",@"测试"];
    NSArray *imageNames = @[@"life",@"news",@"entertainment",@"test"];
    NSArray *imageSelectedNames = @[@"life",@"news",@"entertainment",@"test"];
    
    NSMutableArray *tabbbarItems = [NSMutableArray array];
    
    for (int i = 0; i < TabbarNum; i++) {
        TabbarItem * tabbarItem = [[TabbarItem alloc]init];
        tabbarItem.titleName = titles[i];
        tabbarItem.imageName = imageNames[i];
        tabbarItem.imageSelectedName = imageSelectedNames[i];
        [tabbbarItems addObject:tabbarItem];
    }
    self.tabbarCustom.tabbarItems = tabbbarItems;
    __weak __typeof(self) myself = self;
    self.tabbarCustom.tabJumpBlock =  ^ (NSInteger index) {
        myself.selectedIndex = index;
    };
    
    NSMutableArray *baseNavVcs = [NSMutableArray array];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //create child viewcontrollers
    //life
    LifeViewController *lifeVc = [sb instantiateViewControllerWithIdentifier:@"life"];
    BaseNavigationController *lifeNavVc = [[BaseNavigationController alloc]initWithRootViewController:lifeVc];
    [baseNavVcs addObject:lifeNavVc];
    //news
    NewsViewController *newsVc = [sb instantiateViewControllerWithIdentifier:@"news"];
    BaseNavigationController *newsNavVc = [[BaseNavigationController alloc]initWithRootViewController:newsVc];
    [baseNavVcs addObject:newsNavVc];
    //entainment
    EntertainmentViewController *entertainmentVc = [sb instantiateViewControllerWithIdentifier:@"entertainment"];
    BaseNavigationController *entertainmentNavVc = [[BaseNavigationController alloc]initWithRootViewController:entertainmentVc];
    [baseNavVcs addObject:entertainmentNavVc];
    //test
    LifeViewController *testVc = [sb instantiateViewControllerWithIdentifier:@"test"];
    BaseNavigationController *testNavVc = [[BaseNavigationController alloc]initWithRootViewController:testVc];
    [baseNavVcs addObject:testNavVc];
    
    [self setViewControllers:baseNavVcs];
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
