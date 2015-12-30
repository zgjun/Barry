//
//  ADMediaController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-10.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ADMediaController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"

#import "MainTabBarController.h"

@interface ADMediaController ()

@property (nonatomic,strong) MPMoviePlayerController *mpVc;

@property (nonatomic,strong) NSString *urlStr;

@property (nonatomic,strong) MainTabBarController *tabBarVc;

@end

@implementation ADMediaController

- (NSString *)urlStr {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.tool.chexun.com/mobile/buyCarAdv.do"]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (data != nil) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        _urlStr = dict[@"sourceUrl"];
    } else {
        return nil;
    }
    
    return _urlStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    MPMoviePlayerController *mpVc = [[MPMoviePlayerController alloc]init];
    
    mpVc.contentURL = [[NSBundle mainBundle] URLForResource:@"chexun.mp4" withExtension:nil];
    [mpVc setFullscreen:YES];
    mpVc.view.frame = self.view.bounds;
    mpVc.controlStyle = MPMovieControlStyleNone;
    self.mpVc = mpVc;
    [self.view addSubview:mpVc.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:mpVc];
    
    //添加跳过按钮
    UIButton *jumpBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 56, 10, 46, 30)];
    [jumpBtn setBackgroundImage:[UIImage imageNamed:@"chexun_ad_sikpicon"] forState:UIControlStateNormal];
//    [jumpBtn setBackgroundColor:[UIColor lightGrayColor]];
    jumpBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [jumpBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [jumpBtn addTarget:self action:@selector(jumpBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpBtn];
    
    
    //添加详情按钮
    UIButton *infoBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 46, 30)];
    infoBtn.hidden = YES;
//    [infoBtn setBackgroundColor:[UIColor lightGrayColor]];
    [infoBtn setBackgroundImage:[UIImage imageNamed:@"chexun_ad_sikpicon"] forState:UIControlStateNormal];
    infoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [infoBtn setTitle:@"详情" forState:UIControlStateNormal];
    
    [infoBtn addTarget:self action:@selector(infoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:infoBtn];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mpVc play];
    //预加载主控制器
    MainTabBarController *tabBarVc = [[MainTabBarController alloc]init];
    self.tabBarVc = tabBarVc;
}

- (void)infoBtnClick {
//    NSString *url = @"http://3g.chexun.com";
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
     
                         animated:YES];
    
    [self.mpVc pause];
    
    NSString *url;
    
    if ([self.urlStr hasPrefix:@"http://"]) {
        url = self.urlStr;
    } else {
        url = [NSString stringWithFormat:@"http://%@",self.urlStr];
    }
    
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow
     
                         animated:YES];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    
    [self jumpBtnClick];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    [self jumpBtnClick];
    
}

- (void)jumpBtnClick {
    
    [self.mpVc pause];
    
    [self.mpVc.view removeFromSuperview];
    
    self.mpVc = nil;
    
    [self.view removeFromSuperview];
    
    self.view = nil;
    
    [self loadMainTabVc];
    
}

- (void)loadMainTabVc {
    UIApplication *application = [UIApplication sharedApplication];
    application.keyWindow.rootViewController = self.tabBarVc;
    
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
