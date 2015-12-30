//
//  MainTabBarController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14/11/24.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "MainTabBarController.h"
#import "MainNavigationController.h"
#import "IndexController.h"
#import "CTCompareController.h"
#import "CTGarageController.h"
#import "OtherController.h"
#import "RPriceController.h"
#import "NonHighButton.h"

#import "UINavigationController+YRBackGesture.h"


#define MiniGap 1

#define OtherViewNum 3
#define OtherViewSide ((ScreenWidth - OtherViewNum * MiniGap) / OtherViewNum)



@interface MainTabBarController ()<IndexTabBarViewDelegate>


@property (nonatomic,weak) UIView *bgView;

@property (nonatomic,assign) CGRect tabBarBounds;

@property (nonatomic,assign) NSInteger clickCount;


@property (nonatomic,strong) IndexController *indexVc;

@property (nonatomic,weak) UIImageView *image1;

@property (nonatomic,weak) UIImageView *image2;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tabBar.hidden = YES;
    
    self.tabBarBounds = self.tabBar.bounds;
    
    self.view.backgroundColor = TabBarViewBackGroundColor;
    
    //创建子控制器
    [self createChildControllers];
    
}


- (void)GoToCompareVcSelected {
    [self indexTabBarView:self.tabBarView didSelectIndex:0];
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    self.clickCount++;
    if (self.clickCount == 1) {
        self.image2.hidden = YES;
        self.image1.hidden = NO;
    } else {
        [gesture.view removeFromSuperview];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tabBarView != nil) {
        [self.tabBarView removeFromSuperview];
    }
    
    //自定义一个tabBar
    [self createTabBar];
    
    
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    
}
-(void)createTabBar{
    
    //创建tabBar
    self.tabBarView = [[IndexTabBarView alloc]init];
    self.tabBarView.frame = CGRectMake(0, ScreenHeight -  self.tabBarBounds.size.height, ScreenWidth, self.tabBarBounds.size.height);
    self.tabBarView.delegate = self;

    self.tabBarView.alpha = 1;
    [self.view addSubview:self.tabBarView];
    
    
    NSInteger firstLoad = [[[NSUserDefaults standardUserDefaults] objectForKey:kFirstLoad] integerValue];
    
    if (firstLoad != 1) {
        
        self.clickCount = 0;
        
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:kFirstLoad];
        
        //显示新特性的蒙板
        UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.alpha = 0.8;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [coverView addGestureRecognizer:tap];
        [self.view addSubview:coverView];
        
        UIImageView *image1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tishi2"]];
        self.image1 = image1;
        image1.hidden = YES;
        image1.frame = CGRectMake(0, (ScreenHeight - 271) * 0.5, 239, 271);
        [coverView addSubview:image1];
        UIImageView *image2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tishi1"]];
        self.image2 = image2;
        image2.hidden = NO;
        image2.frame = CGRectMake(ScreenWidth * 0.5 - 81, ScreenHeight - 112, 249, 112);
        [coverView addSubview:image2];
    }
    
    
}
-(void)createChildControllers {
    //首页
    IndexController *indexVc = [[IndexController alloc]init];
    MainNavigationController *indexNc = [[MainNavigationController alloc]initWithRootViewController:indexVc];
    [indexNc setEnableBackGesture:YES];
    self.indexVc = indexVc;
    [self addChildViewController:indexNc];
    //车型库
    CTGarageController *CTGVc = [[CTGarageController alloc]init];
    MainNavigationController *CTGNc = [[MainNavigationController alloc]initWithRootViewController:CTGVc];
    [CTGNc setEnableBackGesture:YES];
    CTGVc.view.backgroundColor = MainBackGroundColor;
    [self addChildViewController:CTGNc];
    
    //添加瀑布流子控制器
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(OtherViewSide, OtherViewSide);
    
    layout.sectionInset = UIEdgeInsetsMake(MiniGap, 0, 0, MiniGap);
    layout.minimumLineSpacing = MiniGap;
    layout.minimumInteritemSpacing = MiniGap;
    
    OtherController *OtherVc = [[OtherController alloc]initWithCollectionViewLayout:layout];
    MainNavigationController *OtherNc = [[MainNavigationController alloc]initWithRootViewController:OtherVc];
    [OtherNc setEnableBackGesture:YES];
    OtherVc.view.backgroundColor = MainBackGroundColor;
    
    [self addChildViewController:OtherNc];
}

- (void)indexTabBarView:(IndexTabBarView *)indexTabBarView didSelectIndex:(NSInteger)index{
    self.selectedIndex = index;
    
    if (index != 0) {
        [self.indexVc menuBgViewTap];
    }
    
}




@end
