//
//  GuideDetailController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-29.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "GuideDetailController.h"
#import "WXApi.h"


@interface GuideDetailController ()<UIActionSheetDelegate,UIGestureRecognizerDelegate>
{
    enum WXScene _scene;
}

@property (nonatomic,strong) NSDictionary *contentDict;

@end

@implementation GuideDetailController


- (instancetype)initWithContentDict:(NSDictionary *)contentDict {
    if (self = [super init]) {
        self.contentDict = contentDict;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
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
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
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
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchDown];
    
    shareBtn.frame = CGRectMake(ScreenWidth - 50, 20, 44, 44);
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [navView addSubview:shareBtn];

    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"导购详情";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //加载webView
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    NSURL *url = [NSURL URLWithString:self.contentDict[@"url"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

///分享经销商
- (void)shareBtnClick {
    
    
    //弹出actionsheet进行选择分享到哪
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  
                                  initWithTitle:@"分享"
                                  
                                  delegate:self
                                  
                                  cancelButtonTitle:@"取消"
                                  
                                  destructiveButtonTitle:nil
                                  
                                  otherButtonTitles:@"分享给朋友", @"分享到朋友圈",nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [actionSheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    
    if (buttonIndex == 0) {
        
        _scene = WXSceneSession;
        
        [self shareApp];
        
    }else if (buttonIndex == 1) {
        
        _scene = WXSceneTimeline;
        
        [self shareApp];
        
    }
}

- (void)shareApp {
    WXMediaMessage *message = [WXMediaMessage message];
    NSString *title = self.contentDict[@"title"];
    message.title = title;
    //    message.description = @"一款针对买车用户量身打造的购车工具类APP。能够帮助用户查看车辆价格、经销商、车型参数等信息；提供优惠信息与团购活动，并可以报名参与团购和询问车辆最低价。";
    [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.contentDict[@"url"];
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    [WXApi sendReq:req];
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}


@end
