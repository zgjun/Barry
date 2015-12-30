//
//  HTDrawerViewController.h
//  IoTSmart
//
//  Created by HT.CRY on 14/12/23.
//  Copyright (c) 2014年 WLD.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTDrawerViewController : UIViewController

@property (nonatomic, strong) UIViewController * leftControl;
@property (nonatomic, strong) UIViewController * righControl;
@property (nonatomic, strong) UIViewController * mainControl;

@property (nonatomic, strong) NSIndexPath      * currentIndexPath;

@property (nonatomic, strong) UIView *tapView;// 用来接收点击\左滑事件


// 是否允许拖拽. 默认为yes
@property (strong) UIPanGestureRecognizer *panGesture;

// 恢复位置
-(void)showMainView;

// 显示左视图
-(void)showLeftView;

@end
