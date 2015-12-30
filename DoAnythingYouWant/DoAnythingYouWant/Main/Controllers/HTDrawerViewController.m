//
//  HTDrawerViewController.m
//  IoTSmart
//
//  Created by HT.CRY on 14/12/23.
//  Copyright (c) 2014年 WLD.cn. All rights reserved.
//

#import "HTDrawerViewController.h"
#import "BaseTabBarController.h"

#define kLeftViewTransX  -80.0
#define kMainViewRotate  55.0
#define kMainViewTransX  240.0
#define kMainViewScaleY  50.0  //控制显示侧边栏时的右边view距上下的距离

#define kDuration 0.35

CGFloat MainViewDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat MainViewScaleY(CGFloat degrees) {return degrees / ScreenHeight;};

@interface HTDrawerViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isOnMainView;  // mainView是否在中间显示

@property (nonatomic, strong) UIView *contentView;
@end

@implementation HTDrawerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (UIView*)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        // 背景图片
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = [UIImage imageNamed:@"bg_drawer"];
        [_contentView addSubview:imageView];
    }
    return _contentView;
}
- (UIView*)tapView
{
    if (!_tapView) {
        _tapView = [[UIView alloc] initWithFrame:CGRectMake(kMainViewTransX, 0, ScreenWidth - kMainViewTransX, ScreenHeight)];
        _tapView.backgroundColor = [UIColor clearColor];
        _tapView.userInteractionEnabled = NO;
    }
    return _tapView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init contentView
    [self.view addSubview:self.contentView];
    
    //create left controller
    UIViewController *leftControl = [[UIViewController alloc]init];
    leftControl.view.backgroundColor = [UIColor clearColor];
    self.leftControl = leftControl;
    [self.contentView addSubview:self.leftControl.view];
    //create right controller
    UIViewController *rightControl = [[UIViewController alloc]init];
    rightControl.view.backgroundColor = [UIColor clearColor];
    self.righControl = rightControl;
    [self.contentView addSubview:self.righControl.view];
    
    [self setup];

    // Setup animation
    [self setupAnimation];

    [self showMainView];
}

- (void) setup
{
    [self.contentView addSubview:self.leftControl.view];
    [self.contentView addSubview:self.mainControl.view];
    [self.leftControl.view addSubview:self.tapView];
    
    UITapGestureRecognizer *sideslipTapGes= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handeTap:)];
    [sideslipTapGes setNumberOfTapsRequired:1];
    [self.tapView addGestureRecognizer:sideslipTapGes];
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handeTap:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.leftControl.view addGestureRecognizer:swipe];
}

#pragma mark - 单击手势
-(void)handeTap:(UITapGestureRecognizer *)tap
{
    if (NO == self.isOnMainView)
        [self showMainView];
}

#pragma mark - 展示主视图
//恢复位置
-(void)showMainView
{

    [UIView animateWithDuration:kDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {

         self.leftControl.view.alpha = 1;
         CATransform3D leftTransform = self.leftControl.view.layer.transform;
         leftTransform = CATransform3DTranslate(leftTransform, kLeftViewTransX , 0, 0);
         leftTransform = CATransform3DScale(leftTransform, 0.9, 0.9, 1);
         self.leftControl.view.layer.transform = leftTransform;

         
        self.leftControl.view.alpha = 0;
        CATransform3D rightTransform = CATransform3DIdentity;
        rightTransform = CATransform3DRotate(rightTransform, 0, 0, 1, 0);
        self.mainControl.view.layer.transform = rightTransform;
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

     }completion:^(BOOL finished) {

    }];
    
    self.isOnMainView = YES;
    self.mainControl.view.userInteractionEnabled = YES;
    self.tapView.userInteractionEnabled = NO;
     NSLog(@"显示 main 视图");
}

//显示左视图
-(void)showLeftView
{
    CATransform3D leftTransform = CATransform3DIdentity;
    leftTransform = CATransform3DTranslate(leftTransform, kLeftViewTransX , 0, 0);
    leftTransform = CATransform3DScale(leftTransform, 0.8, 0.8, 1);
    self.leftControl.view.layer.transform = leftTransform;
//    self.leftControl.view.alpha = 0;
    
    [UIView animateWithDuration:kDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.leftControl.view.alpha = 1;
         CATransform3D leftTransform = self.leftControl.view.layer.transform;
         leftTransform = CATransform3DScale(leftTransform, 1.25, 1.25, 1);
         leftTransform = CATransform3DTranslate(leftTransform, -kLeftViewTransX , 0, 0);
         self.leftControl.view.layer.transform = leftTransform;
         
         CATransform3D rightTransform = CATransform3DIdentity;
         rightTransform = CATransform3DTranslate(rightTransform, 30, 0, 0);
         rightTransform = CATransform3DRotate(rightTransform, MainViewDegreesToRadians(kMainViewRotate), 0, 1, 0);
         rightTransform = CATransform3DScale(rightTransform, 0.5, MainViewScaleY(ScreenHeight - kMainViewScaleY), 1);
         self.mainControl.view.layer.transform = rightTransform;
         
     }completion:^(BOOL finished) {
   
    }];
    
    self.isOnMainView = NO;
    self.mainControl.view.userInteractionEnabled = NO;
    self.tapView.userInteractionEnabled = YES;
}

#pragma mark - animation

- (void)setupAnimation
{
    // Setup mainControl.view to transform
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = 1.0 / 600;
    self.contentView.layer.sublayerTransform = perspectiveTransform;
    
    CGPoint anchorPoint = CGPointMake(1, 0.5);
    CGFloat newX = self.mainControl.view.width * anchorPoint.x;
    CGFloat newY = self.mainControl.view.height * anchorPoint.y;
    self.mainControl.view.layer.position = CGPointMake(newX, newY);
    self.mainControl.view.layer.anchorPoint = anchorPoint;
}

@end
