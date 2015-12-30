//
//  ADImageController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15/5/29.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ADImageController.h"
#import "AFNetworking.h"
#import "MainTabBarController.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"

@interface ADImageController()

@property (nonatomic,weak) UIImageView *adImageView;

@property (nonatomic,strong) __block NSDictionary *imageDict;

@property (nonatomic,weak) UIImageView *indicatorImage;

@property (nonatomic,strong) __block NSTimer *secondTimer;

@property (nonatomic,assign) __block NSInteger secondsCount;

@property (nonatomic,strong) NSString *imageSize;

@end

@implementation ADImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /*
     6：1334 * 750    -> 667 * 375
     6p：2208 * 1242 -> 736 * 414
     */
    
    //根据屏幕大小来判断获取什么尺寸的图片
    if (ScreenWidth <= 320 && ScreenHeight <= 480) {
        self.imageSize = @"640_960";
    } else if (ScreenWidth <= 320 && (ScreenHeight <= 568 && ScreenHeight > 480)) {
        self.imageSize = @"640_1136";
    } else if ((ScreenWidth > 320 && ScreenWidth <= 375) && (ScreenHeight <= 667 && ScreenHeight > 568)) {
        self.imageSize = @"750_1334";
    } else if ((ScreenWidth > 375 && ScreenWidth <= 414) && (ScreenHeight <= 736 && ScreenHeight > 667)) {
        self.imageSize = @"1242_2208";
    }
    
    
    [self createChildViews];
    
    //获取数据
    [self getData];
    
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarAdvPic.do?dpi=%@&type=3g",self.imageSize];
    __weak ADImageController *myself = self;
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        myself.imageDict = responseObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //广告显示
            [MobClick event:@"iOS_AD_Load_Show_Count"];
            
           //在主线程更改图片
            [myself.adImageView sd_setImageWithURL:[NSURL URLWithString:myself.imageDict[@"sourcePath"]] placeholderImage:[UIImage imageNamed:@"Default-736h"]];
            
            //impUrl已经置为空了，客户那边不能进行曝光监测！
            [myself.indicatorImage sd_setImageWithURL:[NSURL URLWithString:myself.imageDict[@"impUrl"]] placeholderImage:[UIImage imageNamed:@"chexun_logobg"]];
            
            myself.secondsCount = 5;
            
            myself.secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:myself selector:@selector(secondReduce) userInfo:nil repeats:YES];
            
            [[NSRunLoop currentRunLoop] addTimer:self.secondTimer forMode:NSRunLoopCommonModes];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MyLog(@"error:%@",error);
    }];
}

- (void)secondReduce {
    self.secondsCount--;
    
    if (self.secondsCount <= 0) {
        [self jumpBtnClick];
    }
}

- (void)createChildViews {
    
    //秒针标识视图
    UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.indicatorImage = indicatorImage;
    [self.view addSubview:indicatorImage];
    
    UIImageView *adImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    adImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTap:)];
    
    [adImageView addGestureRecognizer:tap];
    
    self.adImageView = adImageView;
    adImageView.image = [UIImage imageNamed:@"Default-736h"];
    [self.view addSubview:adImageView];
    
    
    //跳过按钮
    //添加跳过按钮
    
    UIButton *jumpBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 70, 20, 60, 30)];
    
    jumpBtn.hidden = YES;
    
    [jumpBtn setBackgroundImage:[UIImage imageNamed:@"chexun_ad_sikpicon"] forState:UIControlStateNormal];
    
    
    jumpBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [jumpBtn setTitle:@"跳过" forState:UIControlStateNormal];
    
    [jumpBtn addTarget:self action:@selector(jumpBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [adImageView addSubview:jumpBtn];
    

}

- (void)imageTap:(UITapGestureRecognizer *)gesture {
    
    //广告被点击
    [MobClick event:@"iOS_AD_Load_Click_Count"];
    
    
    NSString *url;
    
    if ([self.imageDict[@"sourceUrl"] hasPrefix:@"http://"]) {
        url = self.imageDict[@"sourceUrl"];
    } else {
        url = [NSString stringWithFormat:@"http://%@",self.imageDict[@"sourceUrl"]];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)jumpBtnClick {
    
    [self.view removeFromSuperview];
    
    self.view = nil;
    
    [self.secondTimer invalidate];
    
    [self loadMainTabVc];
    
}

- (void)loadMainTabVc {
    UIApplication *application = [UIApplication sharedApplication];
    MainTabBarController *tabBarVc = [[MainTabBarController alloc]init];
    application.keyWindow.rootViewController = tabBarVc;
    
}

@end
