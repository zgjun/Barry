//
//  CompareChooseController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-25.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CompareChooseController.h"
#import "NoHighLightBtn.h"
#import "CompareBrandController.h"
#import "CompareHotController.h"


@interface CompareChooseController ()<UIGestureRecognizerDelegate>
@property (nonatomic,weak) NoHighLightBtn *hiddenBtn;

@property (nonatomic,weak) NoHighLightBtn *showBtn;

@property (nonatomic,strong) UIViewController *contentController;

@property (nonatomic,strong) CompareBrandController *compareBrandVc;

@property (nonatomic,strong) CompareHotController *compareHotVc;
/*
 0:表示显示品牌
 1:表示显示热门
 */
@property (nonatomic,assign) NSInteger brandIndicator;
@end

@implementation CompareChooseController

-  (CompareBrandController *)compareBrandVc {
    if (_compareBrandVc == nil) {
        _compareBrandVc = [[CompareBrandController alloc]init];
        
    }
    return _compareBrandVc;
}
- (CompareHotController *)compareHotVc {
    if (_compareHotVc == nil) {
        _compareHotVc = [[CompareHotController alloc]init];
        
        [self addChildViewController:_compareHotVc];
    }
    return _compareHotVc;
}

- (void)setContentController:(UIViewController *)contentController {
    _contentController = contentController;
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
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
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
    
    
    //设置标题视图
    UIImageView *titleView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 188, 30)];
    titleView.userInteractionEnabled = YES;
    titleView.image = [UIImage imageNamed:@"chexun_pk_tabbg"];
    NoHighLightBtn *hiddenBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(0, 0, 94, 30)];
    self.hiddenBtn = hiddenBtn;
    hiddenBtn.tag = 1;
    [hiddenBtn setTitle:@"热门" forState:UIControlStateNormal];
    
    [hiddenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [hiddenBtn setTitleColor:MainGoldenColor forState:UIControlStateNormal];
    [hiddenBtn setBackgroundImage:[UIImage imageNamed:@"chexun_pk_tabhotbut_selected"] forState:UIControlStateSelected];
    
    hiddenBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [hiddenBtn addTarget:self action:@selector(showOrHiddenClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleView addSubview:hiddenBtn];
    
    
    NoHighLightBtn *showBtn = [[NoHighLightBtn alloc]initWithFrame:CGRectMake(94, 0, 94, 30)];
    self.showBtn = showBtn;
    showBtn.selected = YES;
    showBtn.tag = 2;
    showBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [showBtn setBackgroundImage:[UIImage imageNamed:@"chexun_pk_tabbrandbut_selected"] forState:UIControlStateSelected];
    [showBtn setTitle:@"品牌" forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [showBtn setTitleColor:MainGoldenColor forState:UIControlStateNormal];
    [showBtn addTarget:self action:@selector(showOrHiddenClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置初始选中
    showBtn.selected = YES;
    self.brandIndicator = 0;
    self.contentController = self.compareBrandVc;
    
    [self.view addSubview:self.contentController.view];
    
    [self addChildViewController:self.contentController];
    
    
    [titleView addSubview:showBtn];
    
    self.navigationItem.titleView = titleView;
    
}

- (void)showOrHiddenClick:(NoHighLightBtn *)btn {
    
    btn.selected = YES;
    
    if (btn.tag == 1) {//隐藏相同
        
        self.showBtn.selected = NO;
        self.brandIndicator = 1;
        self.contentController = self.compareHotVc;
        
        self.contentController.view.frame = self.view.bounds;
        
        [self.view addSubview:self.compareHotVc.view];
        
    } else {//显示品牌
        self.hiddenBtn.selected = NO;
        self.brandIndicator = 0;
        self.contentController = self.compareBrandVc;
        
        [self.view addSubview:self.compareBrandVc.view];
    }
}
- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
