//
//  OtherController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "OtherController.h"
#import "OtherCellView.h"
#import "OtherSettingController.h"
#import "OtherFriendHelpController.h"
#import "OtherBuyCarController.h"
#import "OtherLowPriceController.h"
#import "OtherShakeQueryController.h"
#import "OtherFourSController.h"
#import "MBProgressHUD+GJ.h"
#import "MainTabBarController.h"
#import "CTCompareController.h"

@interface OtherController ()

@property (nonatomic,strong) NSArray *viewInfo;

@end

@implementation OtherController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //导航视图
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    
    navView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:navView];
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"其他";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    
    self.collectionView.frame = CGRectMake(0, 43, ScreenWidth, ScreenHeight - 64);
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"otherCell"];
    
    self.collectionView.backgroundColor = MainBackGroundColor;
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    
    //创建数组
    NSDictionary *friendHelpCar = @{@"iconName" : @"chexun_friendsicon" ,@"name" : @"朋友帮选车"};
    
    NSDictionary *calculator = @{@"iconName" : @"chexun_jissuanqi" ,@"name" : @"购车计算器"};
    
    NSDictionary *lowPrice = @{@"iconName" : @"chexunr_consulticon" ,@"name" : @"询最低价"};
    
    NSDictionary *noSearch = @{@"iconName" : @"chexun_yaohaoicon" ,@"name" : @"摇号查询"};
    
    NSDictionary *foursShop = @{@"iconName" : @"chexun_4sicon2" ,@"name" : @"附近4S店"};
    
    NSDictionary *carCompare = @{@"iconName" : @"chexun_pkicon_orange" ,@"name" : @"车型对比"};
    
    NSDictionary *setting = @{@"iconName" : @"chexun_moreicon" ,@"name" : @"设置"};
    
    self.viewInfo = @[friendHelpCar,calculator,lowPrice,noSearch,foursShop,carCompare,setting];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    MainTabBarController *tab = (MainTabBarController *)self.tabBarController;
    tab.tabBarView.hidden = NO;
    
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.viewInfo.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"otherCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    OtherCellView *otherCellView = [[OtherCellView alloc]initWithFrame:cell.bounds];
    
    otherCellView.backgroundColor = MainWhiteColor;
    
    otherCellView.dataInfo = self.viewInfo[indexPath.row];
    
    [cell.contentView addSubview:otherCellView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{//朋友帮选车
            OtherFriendHelpController *otherFriendHelpVc = [[OtherFriendHelpController alloc]init];
            [self.navigationController pushViewController:otherFriendHelpVc animated:YES];
            break;
        }
        case 1:{//购车计算器
            OtherBuyCarController *otherBuyCarVc = [[OtherBuyCarController alloc]init];
            [self.navigationController pushViewController:otherBuyCarVc animated:YES];
            break;
        }
        case 2:{//询最低价
            OtherLowPriceController *lowPriceVc = [[OtherLowPriceController alloc]init];
            [self.navigationController pushViewController:lowPriceVc animated:YES];
            break;
        }
        case 3:{//摇号查询
            OtherShakeQueryController *shakeQueryVc = [[OtherShakeQueryController alloc]init];
            [self.navigationController pushViewController:shakeQueryVc animated:YES];
            break;
        }
        case 4:{//附近4S店
            OtherFourSController *fourSVc = [[OtherFourSController alloc]init];
            [self.navigationController pushViewController:fourSVc animated:YES];
            break;
        }
        case 5: {//车型对比
            CTCompareController *compareVc = [[CTCompareController alloc]init];
            [self.navigationController pushViewController:compareVc animated:YES];
            break;
        }
        case 6: {//设置
            OtherSettingController *otherSettingVc = [[OtherSettingController alloc]init];
            [self.navigationController pushViewController:otherSettingVc animated:YES];
            break;
        }
        default:
            break;
    }
}


@end
