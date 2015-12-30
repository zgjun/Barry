//
//  OtherSettingController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-16.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "OtherSettingController.h"
#import "MBProgressHUD+GJ.h"
#import "AFNetworking.h"
#import "OtherChexunController.h"
#import "OtherAdviceController.h"
#import "UMFeedback.h"
#import "MainTabBarController.h"
#import "WXApi.h"
#import "CityChooseController.h"

#define OtherSettingGap 10

@interface OtherSettingController ()<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,CityChooseControllerDelegate,UIAlertViewDelegate>
{
    enum WXScene _scene;
}

@property (nonatomic,strong) NSString *sdCachesPath;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) OtherChexunController *chexunVc;

@property (nonatomic,weak) UILabel *detailLabel;

@end

@implementation OtherSettingController

- (id)init{
    if(self = [super init]){
        _scene = WXSceneTimeline;
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
    
    self.view.backgroundColor = MainBackGroundColor;
    
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
    
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"设置";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, 300)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"OtherSettingCell"];
    [self.view addSubview:tableView];
    
    //动态获取缓存文件夹的路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    self.sdCachesPath = [cachesPath stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    self.detailLabel.text = city;
    
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    tab.tabBarView.hidden = YES;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return 4;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"OtherSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    UIView *lineImage = [[UIView alloc]initWithFrame:CGRectMake(cell.width * 0.05, cell.height - 1, cell.width, 1)];
     lineImage.backgroundColor = MainLineGrayColor;
    [cell.contentView addSubview:lineImage];
        
    
    //由于是静态的，直接写
    if (indexPath.section == 0 && indexPath.row == 1) {
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.05, 0, cell.width * 0.35, cell.height)];
        nameLabel.text = @"清除缓存";
        nameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.4, 0, cell.width * 0.55, cell.height)];
        
        double size = [self sizeWithPath:self.sdCachesPath] / (1024 * 1024.0);
        if (size < 0.1) {
            detailLabel.text = nil;
        } else {
            
            detailLabel.text = [NSString stringWithFormat:@"%.1fM", size];
        }
        detailLabel.font = [UIFont systemFontOfSize:14];
        detailLabel.textColor = [UIColor lightGrayColor];
        detailLabel.textAlignment = NSTextAlignmentRight;
        
        [cell.contentView addSubview:detailLabel];
        
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.05, 0, 50,44)];
        nameLabel.text = @"城市";
        nameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + 10, 0, 200, 44)];
        self.detailLabel = detailLabel;
        NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
        detailLabel.text = city;
        detailLabel.font = [UIFont systemFontOfSize:16];
        detailLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:detailLabel];
        
        
        UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 18, 5, 8)];
        indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
        indicatorImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [cell.contentView addSubview:indicatorImage];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.05, 0, cell.width * 0.25, cell.height)];
        nameLabel.text = @"意见反馈";
        nameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.3, 0, cell.width * 0.65, cell.height)];
        detailLabel.text = @"您的意见，对我们非常重要!";
        detailLabel.font = [UIFont systemFontOfSize:14];
        detailLabel.textColor = [UIColor lightGrayColor];
        detailLabel.textAlignment = NSTextAlignmentRight;
        
        [cell.contentView addSubview:detailLabel];
        
    } else if (indexPath.section == 1 &&  indexPath.row == 1) {
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.05, 0, cell.width * 0.8, cell.height)];
        nameLabel.text = @"去AppStore评个5星吧！";
        nameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 18, 5, 8)];
        
        indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
        indicatorImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [cell.contentView addSubview:indicatorImage];
    
    } else if (indexPath.section == 1 &&  indexPath.row == 2) {
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.05, 0, cell.width * 0.8, cell.height)];
        nameLabel.text = @"访问车讯官网";
        nameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 18, 5, 8)];
        
        indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
        indicatorImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [cell.contentView addSubview:indicatorImage];
        
    } else if (indexPath.section == 1 &&  indexPath.row == 3) {
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.05, 0, cell.width * 0.8, cell.height)];
        nameLabel.text = @"分享“买车通”给朋友";
        nameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 18, 5, 8)];
        
        indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
        indicatorImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [cell.contentView addSubview:indicatorImage];
        
    }
    
//    else if (indexPath.section == 1 &&  indexPath.row == 4) {
//        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.width * 0.05, 0, cell.width * 0.8, cell.height)];
//        nameLabel.text = @"版本更新";
//        nameLabel.font = [UIFont systemFontOfSize:16];
//        [cell.contentView addSubview:nameLabel];
//        
//        UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(cell.width * 0.95, 0, cell.width * 0.03, cell.height)];
//        
//        indicatorImage.image = [UIImage imageNamed:@"chexun_models_rightarroow"];
//        indicatorImage.contentMode = UIViewContentModeScaleAspectFit;
//        
//        [cell.contentView addSubview:indicatorImage];
//        
//    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                [self chooseCity];
                break;
            case 1:
                //清除缓存
                [self clearStore];
                break;
            default:
                break;
        }
        
        
    } else {
        switch (indexPath.row) {
            case 0:{//意见反馈
                [self adviceBack];
                break;
            }
            case 1:{//评星
                [self commentStar];
                break;
            }
            case 2:{//访问车讯官网
                [self visitChexun];
                break;
            }
            case 3:{//分享买车通
                [self shareBuyCar];
                break;
            }
            default:
                break;
        }
    }
}


- (void)chooseCity {
    CityChooseController *cityVc = [[CityChooseController alloc]init];
    
    cityVc.cityDelegate = self;
    
    [self.navigationController pushViewController:cityVc animated:YES];
}

- (void)didCityTableRowClick:(CityChooseController *)cityVc infoDict:(NSDictionary *)infoDict {
    
    self.detailLabel.text = infoDict[@"cityName"];
    
}

///意见反馈
- (void)adviceBack {
    [self.navigationController pushViewController:[UMFeedback feedbackViewController] animated:YES];
    self.navigationController.navigationBarHidden = NO;
}

///评星
- (void)commentStar {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/mai-che-tong/id495881398?mt=8"];
    [[UIApplication sharedApplication]openURL:url];
}

///访问车讯官网
- (void)visitChexun {
    OtherChexunController *chexunVc = [[OtherChexunController alloc]init];
    self.chexunVc = chexunVc;
    [self.navigationController pushViewController:chexunVc animated:YES];
    
    
}

///分享买车通
- (void)shareBuyCar {
    
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
    message.title = @"买车通-iPhone";
    message.description = @"一款针对买车用户量身打造的购车工具类APP。能够帮助用户查看车辆价格、经销商、车型参数等信息；提供优惠信息与团购活动，并可以报名参与团购和询问车辆最低价。";
    [message setThumbImage:[UIImage imageNamed:@"shareIcon"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = @"http://3g.chexun.com/app/maichetong.html";
    
//    ext.webpageUrl = @"https://itunes.apple.com/cn/app/mai-che-tong/id495881398?mt=8";
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    [WXApi sendReq:req];
}


///版本更新
//-(void)onCheckVersion
//{
//    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
//    NSString *currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
//    
//    NSString *URL = @"http://itunes.apple.com/lookup?id=495881398";
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    [manager POST:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dic = responseObject;
//        NSArray *infoArray = [dic objectForKey:@"results"];
//        if ([infoArray count]) {
//            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
//            NSString *lastVersion = [releaseInfo objectForKey:@"version"];
//            
//            MyLog(@"cu:%@,la:%@",currentVersion,lastVersion);
//            
//            
//            if ([currentVersion compare:lastVersion] == NSOrderedAscending) {
//                //trackViewURL = [releaseInfo objectForKey:@"trackVireUrl"];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
//                alert.tag = 10000;
//                [alert show];
//            }
//            else
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                alert.tag = 10001;
//                [alert show];
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        MyLog(@"error:%@",error);
//    }];
//}


///清除缓存
- (void)clearStore {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:@"您确定要清除缓存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
    alert.delegate = self;
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        //取消
        
    } else if (buttonIndex == 1) {
        //清除
        
        // 2.删除SDWebImage的缓存文件夹
        // 2.1创建文件管理者
        NSFileManager *manager = [NSFileManager defaultManager];
        // 2.2删除缓存文件
        BOOL success = [manager removeItemAtPath:self.sdCachesPath error:nil];
        if (success) {
            //        [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"清空缓存成功"];
            [self.tableView reloadData];
        } else {
            [MBProgressHUD showSuccess:@"清空缓存失败"];
        }
        
    }
}


- (int)sizeWithPath:(NSString *)cachesPath
{
    // 1.获取文件管理者
    NSFileManager *manger = [NSFileManager defaultManager];
    // 2.判断路径是否合法
    BOOL directory = NO; // 是否时目录
    // fileExistsAtPath 需要判断的文件路径
    // isDirectory 如果时文件夹就会赋值为YES
    BOOL exists = [manger fileExistsAtPath:cachesPath isDirectory:&directory];
    if (!exists) return 0;
    
    // 3.判断是文件还是文件夹
    if (directory) {
        // 是文件夹
        // 3.1如果是文件夹, 需要遍历累加之后返回结果
        /*
         // contentsOfDirectoryAtPath: 只能获取文件夹下面所有文件的名称, 不能获取子文件夹下的文件名称
         NSArray *contents = [manger contentsOfDirectoryAtPath:cachesPath error:nil];
         NSLog(@"contents = %@", contents);
         */
        //  subpathsOfDirectoryAtPath : 可以获取文件夹下面所有的文件以及子文件夹中的文件
        NSArray *subPaths = [manger subpathsOfDirectoryAtPath:cachesPath error:nil];
        //        NSLog(@"subPaths = %@", subPaths);
        
        // 3.1拼接全路径
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *sdCachesPath = [cachesPath stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
        // 3.2累加文件的大小
        int totalSize = 0;
        for (NSString *subpath in subPaths) {
            NSString *fullPath = [sdCachesPath stringByAppendingPathComponent:subpath];
            //             NSLog(@"fullPath = %@", fullPath);
            // 3.2.1利用文件管理者获取文件的大小
            // 判断是否是文件夹
            BOOL dir = NO;
            [manger fileExistsAtPath:fullPath isDirectory:&dir];
            if (!dir) {
                // 不是文件夹
                NSDictionary *attr = [manger attributesOfItemAtPath:fullPath error:nil];
                totalSize += [attr[NSFileSize] intValue];
            }
        }
        
        return totalSize;
        
    }else
    {
        // 是文件
        // 3.2如果时文件, 直接获取大小后返回'
        NSDictionary *attr = [manger attributesOfItemAtPath:cachesPath error:nil];
        return [attr[NSFileSize] intValue];
    }
    return 0;
    
}

    
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}

@end
