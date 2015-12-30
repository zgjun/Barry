//
//  MapDetailController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-3-6.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "MapDetailController.h"
#import "AnnotationView.h"
#import "Annotation.h"
#import <MapKit/MapKit.h>


#define MapGap 10

@interface MapDetailController ()<MKMapViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) MKMapView *contentView;

@property (nonatomic,strong) NSDictionary *dealerDict;

@property (nonatomic,assign) CGFloat currentLatitude;

@property (nonatomic,assign) CGFloat currentLongtitude;

@property (nonatomic,assign) CGFloat latitude;

@property (nonatomic,assign) CGFloat longitude;

@end

@implementation MapDetailController

- (CGFloat)currentLatitude {
    NSString *currentLa = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityLatitude];
    if (currentLa == nil) {
        _currentLatitude = 39.99749624;
    } else {
        _currentLatitude = [currentLa floatValue];
    }
    return _currentLatitude;
}

- (CGFloat)currentLongtitude {
    NSString *currentLo = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityLongitude];
    if (currentLo == nil) {
        _currentLongtitude = 116.33187772;
    } else {
        _currentLongtitude = [currentLo floatValue];
    }
    return _currentLongtitude;
}

- (instancetype)initWithDealerDict:(NSDictionary *)dealerDict {
    if (self = [super init]) {
        self.dealerDict = dealerDict;
    }
    return self;
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
    /*
    self.navigationItem.title = @"经销商";
    
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
    
    //设置右边的分享按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    shareBtn.hidden = YES;
    
    [shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchDown];
    
    shareBtn.frame = CGRectMake(0, 0, 40, 30);
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
    
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -10;
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer1, rightBtn];
     */
    //导航视图
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    
    navView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:navView];
    
    
    
    //返回按钮
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_backarrow_black"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    [navView addSubview:backBtn];
    
    //设置右边的分享按钮
//    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    [shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchDown];
//    
//    shareBtn.frame = CGRectMake(ScreenWidth - 50, 20, 44, 44);
//    [shareBtn setImage:[UIImage imageNamed:@"chexun_shareicon"] forState:UIControlStateNormal];
//    shareBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//    
//    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    
//    [navView addSubview:shareBtn];
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"经销商";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    [self createChildViews];
    
    //添加一个大头针
    [self addAnnotation];
    
}

- (void)addAnnotation {
    Annotation *tg = [[Annotation alloc] init];
//    tg.title = @"xxx大饭店";
//    tg.subtitle = @"全场一律15折，会员20折";
    tg.icon = @"chexun_4sicon2";
    
//    MyLog(@"dealerDict=%@",self.dealerDict);
    
    self.latitude = [self.dealerDict[@"Latitude"] floatValue];
    self.longitude = [self.dealerDict[@"Longitude"] floatValue];
    tg.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    [self.contentView addAnnotation:tg];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(tg.coordinate, 1000, 1000);
    
    //重新设置地图视图的显示区域
    [self.contentView setRegion:viewRegion animated:YES];
}

- (void)createChildViews {
    //头视图
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, 50)];
    headView.backgroundColor = MainWhiteColor;
    
    [self.view addSubview:headView];
    
    UIImageView *foursImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_4sicon"]];
    foursImage.frame = CGRectMake(MapGap, 15, 18, 14);
    [headView addSubview:foursImage];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(foursImage.frame) + MapGap, MapGap, ScreenWidth * 0.45, 24)];
    nameLabel.textColor = MainBlackColor;
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.text = self.dealerDict[@"dealerShortName"];
    [headView addSubview:nameLabel];
    
    UILabel *soldCountry = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + MapGap, MapGap, 50, 24)];
    soldCountry.textColor = MainFontGrayColor;
    soldCountry.font = [UIFont systemFontOfSize:16];
    soldCountry.text = @"售全国";
    [headView addSubview:soldCountry];
    
    UILabel *department = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(soldCountry.frame) + MapGap, MapGap, 70, 24)];
    department.textColor = MainFontGrayColor;
    department.font = [UIFont systemFontOfSize:16];
    department.text = @"认证商户";
    [headView addSubview:department];
    
    
    //内容视图
    MKMapView *contentView = [[MKMapView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame), ScreenWidth, ScreenHeight - 64 - 100)];
    self.contentView = contentView;
    contentView.delegate = self;
    
    [self.view addSubview:contentView];
    
    
    
    //脚视图
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 50, ScreenWidth, 50)];
    footView.backgroundColor = MainGoldenColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forwardBtnClick)];
    [footView addGestureRecognizer:tap];
    [self.view addSubview:footView];
    
    UILabel *forwardLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth * 0.5 - 80 - 30, 0, 80, 50)];
    forwardLabel.text = @"开始导航";
    forwardLabel.textColor = [UIColor whiteColor];
    forwardLabel.font = [UIFont systemFontOfSize:20];
    [footView addSubview:forwardLabel];
    
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth * 0.5 - 30, 0, 160, 50)];
    distanceLabel.font = [UIFont systemFontOfSize:20];
    distanceLabel.textAlignment = NSTextAlignmentLeft;
    distanceLabel.textColor = [UIColor whiteColor];
    CGFloat distance = [self.dealerDict[@"Distance"] floatValue] / 1000;
    distanceLabel.text = [NSString stringWithFormat:@"（距离 %.1fkm）",distance];
    
    [footView addSubview:distanceLabel];
    
//    UIButton *forwardBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 80 - 10, 5, 80, 40)];
//    
//    [forwardBtn setTitle:@"导航" forState:UIControlStateNormal];
//    
//    [forwardBtn addTarget:self action:@selector(forwardBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    
//    [forwardBtn setBackgroundImage:[UIImage imageNamed:@"chexun_models_cancelbut"] forState:UIControlStateNormal];
//    
//    [footView addSubview:forwardBtn];
    
}


///分享经销商
- (void)forwardBtnClick {
    
    
    //弹出actionsheet进行选择分享到哪
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  
                                  initWithTitle:@"导航"
                                  
                                  delegate:self
                                  
                                  cancelButtonTitle:@"取消"
                                  
                                  destructiveButtonTitle:nil
                                  
                                  otherButtonTitles:@"用系统自带地图进行导航", @"用百度地图进行导航",nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [actionSheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    
    if (buttonIndex == 0) {
        
        
        [self systemBegin];
        
    }else if (buttonIndex == 1) {
        
        
        [self baiduBegin];
        
    }
}

- (void)systemBegin {
    NSString *string = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f",self.currentLatitude,self.currentLongtitude,self.latitude,self.longitude] ;
    [[UIApplication sharedApplication]  openURL:[NSURL URLWithString:string]];
}

- (void)baiduBegin {
    NSString *string = [NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving&src=chuxun|maichetong",self.currentLatitude,self.currentLongtitude,self.latitude,self.longitude];
    
    string = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)string, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    NSURL *url = [NSURL URLWithString:string];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication]  openURL:url];
    } else {
        //转跳到百度地图的下载链接
        NSURL *urlStore = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/bai-du-tu-yu-yin-dao-hang/id452186370?mt=8"];
        [[UIApplication sharedApplication]openURL:urlStore];
    }
    
    [[UIApplication sharedApplication]  openURL:url];
    
}


//- (void)shareBtnClick {
//    
//}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(Annotation *)annotation
{
    // 返回nil就会按照系统的默认做法
    if (![annotation isKindOfClass:[Annotation class]]) return nil;
    
    // 1.获得大头针控件
    AnnotationView *annoView = [AnnotationView annotationViewWithMapView:mapView];
    
    // 2.传递模型
    annoView.annotation = annotation;
    
    return annoView;
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
