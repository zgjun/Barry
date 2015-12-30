//
//  AppDelegate.m
//  BuyCarDictionary
//
//  Created by zgjun on 14/11/24.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarController.h"
//#import "ADMediaController.h"
#import "ADImageController.h"
//#import "BMapKit.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "UMFeedback.h"
#import "MobClick.h"

#import "UIImageView+WebCache.h"

@interface AppDelegate ()<BMKGeneralDelegate>

@property (nonatomic,strong) BMKMapManager  *BMKMgr;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    //设置定位功能
    self.BMKMgr = [[BMKMapManager alloc]init];
    BOOL ret = [self.BMKMgr start:@"CpdORmF841ljmr5qSoXUEmsE" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!%d",ret);
    } else {
        NSLog(@"manager start success!");
    }
    
//    MainTabBarController *mainTabBarVc = [[MainTabBarController alloc]init];
//    self.window.rootViewController = mainTabBarVc;
    
//    ADMediaController *adVc = [[ADMediaController alloc]init];
//    self.window.rootViewController = adVc;
    
    ADImageController *adVc = [[ADImageController alloc]init];
    self.window.rootViewController = adVc;
    
    //让启动页睡1s
     [NSThread sleepForTimeInterval:1.0];
    
    [self.window makeKeyAndVisible];
    
    //设置状态栏颜色
//    UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
//    statusView.backgroundColor = MainGoldenColor;
//    [self.window addSubview:statusView];
    
//     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
    
    
    //向友盟用户反馈注册
    [UMFeedback setAppkey:@"4f13abc55270153cce000002"];
    [UMFeedback setLogEnabled:YES];
    [[UMFeedback sharedInstance] setFeedbackViewController:[UMFeedback feedbackViewController] shouldPush:YES];
    
    //向友盟统计注册
    [MobClick startWithAppkey:@"4f13abc55270153cce000002" reportPolicy:REALTIME channelId:@""];
    
    //向微信注册
    [WXApi registerApp:@"wxc8f90f7a33335a08" withDescription:@"买车通"];
    
    
    return YES;
}

- (void)onGetNetworkState:(int)iError {

}

- (void)onGetPermissionState:(int)iError {
    if (iError == BMKErrorPermissionCheckFailure) {
        
    } else {
        MyLog(@"授权成功");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //发出通知，能出键盘
    NSNotification *notification = [NSNotification notificationWithName:@"applicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // 清除内存中的图片缓存
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    [mgr cancelAll];
    [mgr.imageCache clearMemory];
}
@end
