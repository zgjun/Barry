//
//  CSDealerDetailController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-11.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSDealerDetailController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "HTTPHelper.h"
#import "CSSalesCell.h"
#import "QueryLowPriceController.h"
#import "OnlyBookController.h"
#import "WXApi.h"
#import "CSSaleController.h"
#import "MapDetailController.h"
#import "MJRefresh.h"


#define BottomBtnWidth 137
#define BottomBtnHeight 35
#define Hgap ((ScreenWidth - BottomBtnWidth * 2) / 3)
#define Vgap (49 - 35) * 0.5

#define DealerDetailGap 10


@interface CSDealerDetailController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,CSSalesCellDelegate,UIGestureRecognizerDelegate>
{
    enum WXScene _scene;
}

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSString *dealerID;

@property (nonatomic,strong) NSDictionary *dealerDict;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) NSMutableArray *dealerNews;

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,assign) NSInteger pageIndex;

@property (nonatomic,assign) NSInteger pageSize;

@property (nonatomic,strong) OnlyBookController *onlyBookVc;

@property (nonatomic,strong) QueryLowPriceController *queryVc;

@property (nonatomic,strong) CSSaleController *saleVc;

@property (nonatomic,strong) MapDetailController *mapDetailVc;

@property (nonatomic,weak) UIView *noActiveView;
@end

@implementation CSDealerDetailController

- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}


- (instancetype)initWithDealerDict:(NSDictionary *)dealerDict {
    
    if (self = [super init]) {
        _scene = WXSceneTimeline;
        self.dealerID = dealerDict[@"dealerId"];
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
//添加上拉加载更多
- (void)pushRefresh {
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreStatus)];
    
    // 隐藏状态
    //self.tableView.footer.stateHidden = YES;
    
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=5; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"shuaxin%zd", i]];
        [refreshingImages addObject:image];
    }
    self.tableView.gifFooter.refreshingImages = refreshingImages;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [shareBtn setImage:[UIImage imageNamed:@"chexun_shareicon"] forState:UIControlStateNormal];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [navView addSubview:shareBtn];
    
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
    
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 49)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"DealerDetailCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 49, ScreenWidth, 49)];
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
    
    //专享预约
    
    UIButton *bookBtn = [[UIButton alloc]initWithFrame:CGRectMake(Hgap, Vgap, BottomBtnWidth, BottomBtnHeight)];
    [bookBtn setTitle:@"专享预约" forState:UIControlStateNormal];
    [bookBtn setTitleColor:MainGoldenColor forState:UIControlStateNormal];
//    [bookBtn setImage:[UIImage imageNamed:@"chexun_models_vipicon"] forState:UIControlStateNormal];
    [bookBtn setBackgroundImage:[UIImage imageNamed:@"chexun_button2"] forState:UIControlStateNormal];
    [bookBtn addTarget:self action:@selector(bookBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:bookBtn];
    
    //询更低价
    UIButton *queryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    queryBtn.frame = CGRectMake(BottomBtnWidth + 2 * Hgap,Vgap, BottomBtnWidth, BottomBtnHeight);
//    [queryBtn setImage:[UIImage imageNamed:@"chexun_models_consulticon"] forState:UIControlStateNormal];
    [queryBtn setBackgroundImage:[UIImage imageNamed:@"chexun_button1"] forState:UIControlStateNormal];
    [queryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [queryBtn setTitle:@"询最低价" forState:UIControlStateNormal];
    [queryBtn addTarget:self action:@selector(queryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:queryBtn];
    //初始化相关数据
    self.pageIndex = 1;
    self.pageSize = 10;
    
    //添加下拉加载更多
    [self pushRefresh];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
}

- (void)loadMoreStatus {
    self.pageIndex = self.pageIndex + 1;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersShopNoticeByTypeAndPage.ashx?dealerID=%@&type=2&seriesID=%@&cityID%@&pageIndex=%@&pageSize=%@",self.dealerID,self.dealerDict[@"seriesId"],self.cityId,@(self.pageIndex),@(self.pageSize)];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    __weak CSDealerDetailController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *arr = responseObject;
        if(arr.count > 0) {
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dict = arr[i];
                
                [myself.dealerNews addObject:dict];
            }
            
            [myself.tableView reloadData];
            [myself.tableView.gifFooter endRefreshing];
        } else {
            [myself.tableView.gifFooter endRefreshing];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MyLog(@"%@",error);
        
        [myself.tableView.gifFooter endRefreshing];
        
    }];
}


- (void)queryBtnClick {
    QueryLowPriceController *queryVc = [[QueryLowPriceController alloc]initWithDealerId:self.dealerID];
    self.queryVc = queryVc;
    [self.navigationController pushViewController:queryVc animated:YES];
}

- (void)bookBtnClick {
    OnlyBookController *onlyBookVc = [[OnlyBookController alloc]initWithDealerId:self.dealerID dealerName:self.dealerDict[@"dealerShortName"]];
    self.onlyBookVc = onlyBookVc;
    [self.navigationController pushViewController:onlyBookVc animated:YES];
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://dealer.chexun.com/api/GetDealersShopNoticeByTypeAndPage.ashx?dealerID=%@&type=2&seriesID=%@&cityID%@&pageIndex=%@&pageSize=%@",self.dealerID,self.dealerDict[@"seriesId"],self.cityId,@(self.pageIndex),@(self.pageSize)];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    __weak CSDealerDetailController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.dealerNews = [NSMutableArray arrayWithArray:responseObject];
        
        [myself.tableView reloadData];
        
        
        
        if (self.dealerNews.count == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                myself.noActiveView.hidden = NO;
                
                myself.tableView.gifFooter.hidden = YES;
            });
        }
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MyLog(@"%@",error);
        
    }];
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
    NSString *title = self.dealerDict[@"dealerShortName"];
    message.title = title;
    message.description = @"一款针对买车用户量身打造的购车工具类APP。能够帮助用户查看车辆价格、经销商、车型参数等信息；提供优惠信息与团购活动，并可以报名参与团购和询问车辆最低价。";
    [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    
    ext.webpageUrl = self.dealerDict[@"dealerUrl"];
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    [WXApi sendReq:req];
}

#pragma mark - table datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        if (self.dealerNews.count == 0) {
            return 1;
        } else {
            
            return self.dealerNews.count;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"DealerDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIImageView *foursImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_4sicon"]];
            foursImage.frame = CGRectMake(DealerDetailGap, 15, 18, 14);
            [cell.contentView addSubview:foursImage];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(foursImage.frame) + DealerDetailGap, DealerDetailGap, ScreenWidth * 0.45, 24)];
            nameLabel.textColor = MainBlackColor;
            nameLabel.font = [UIFont systemFontOfSize:16];
            nameLabel.text = self.dealerDict[@"dealerShortName"];
            [cell.contentView addSubview:nameLabel];
            
            UILabel *soldCountry = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + DealerDetailGap, DealerDetailGap, 50, 24)];
            soldCountry.textColor = MainFontGrayColor;
            soldCountry.font = [UIFont systemFontOfSize:16];
            soldCountry.text = @"售全国";
            [cell.contentView addSubview:soldCountry];
            
            UILabel *department = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(soldCountry.frame) + DealerDetailGap, DealerDetailGap, 70, 24)];
            department.textColor = MainFontGrayColor;
            department.font = [UIFont systemFontOfSize:16];
            department.text = @"认证商户";
            [cell.contentView addSubview:department];
            
            UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 43, ScreenWidth, 1)];
            spliteLine.backgroundColor = MainLineGrayColor;
            [cell.contentView addSubview:spliteLine];
            
            
        } else if (indexPath.row == 1) {
            
            UIImageView *phoneImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chenxun_phoneicon"]];
            //19 * 24
            phoneImage.frame = CGRectMake(DealerDetailGap, DealerDetailGap, 19, 24);
            [cell.contentView addSubview:phoneImage];
            
            UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneImage.frame) + DealerDetailGap, DealerDetailGap, ScreenWidth * 0.8, 24)];
            phoneLabel.text = self.dealerDict[@"salePhone"];
            phoneLabel.textColor = MainBlackColor;
            phoneLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:phoneLabel];
            
            UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 16, 5, 8)];
            
            indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
            
            [cell.contentView addSubview:indicatorImage];
        
            UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 43, ScreenWidth, 1)];
            spliteLine.backgroundColor = MainLineGrayColor;
            [cell.contentView addSubview:spliteLine];
        } else {
            UIImageView *addressImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_navigationicon"]];
            //19 * 24
            addressImage.frame = CGRectMake(DealerDetailGap, DealerDetailGap, 19, 24);
            [cell.contentView addSubview:addressImage];
            
            //地址
            UILabel *addressLabel = [[UILabel alloc]init];
            addressLabel.textColor = MainBlackColor;
            addressLabel.font = [UIFont systemFontOfSize:14];
            NSString *addressString = [HTTPHelper StringDecode:self.dealerDict[@"companyAddress"]];
            NSString *addressStr = [NSString stringWithFormat:@"地址：%@",addressString];
            addressLabel.frame = CGRectMake(CGRectGetMaxX(addressImage.frame) + DealerDetailGap,2 , ScreenWidth * 0.8, 40);
            addressLabel.numberOfLines = -1;
             addressLabel.text = addressStr;
            [cell.contentView addSubview:addressLabel];
            
            UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 16, 5, 8)];
            indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
            [cell.contentView addSubview:indicatorImage];
            
            UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 43, ScreenWidth, 1)];
            spliteLine.backgroundColor = MainLineGrayColor;
            [cell.contentView addSubview:spliteLine];
        }
    } else {
        if (self.dealerNews.count == 0) {
            
            CGFloat noActiveViewHeight = ScreenHeight - 64 - (44 * 3);
            //没有活动数据
            UIView *noActiveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, noActiveViewHeight)];
            noActiveView.hidden = YES;
            self.noActiveView = noActiveView;
            noActiveView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:noActiveView];
            
            UIImageView *noActiveImage = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 35) * 0.5, (noActiveViewHeight - 38 - 64) * 0.5, 35, 38)];
            noActiveImage.image = [UIImage imageNamed:@"chexun_tanhaoicon"];
            [noActiveView addSubview:noActiveImage];
            UILabel *noActiveLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 150) * 0.5, CGRectGetMaxY(noActiveImage.frame) + 5, 150, 30)];
            noActiveLabel.font = [UIFont systemFontOfSize:14];
            noActiveLabel.textColor = MainLineGrayColor;
            noActiveLabel.textAlignment = NSTextAlignmentCenter;
            noActiveLabel.text = @"暂无促销活动";
            [noActiveView addSubview:noActiveLabel];
            
        } else {
            CSSalesCell *salesCell = [[CSSalesCell alloc]initWithFrame:cell.bounds];
            salesCell.tag = indexPath.row;
            salesCell.salesDict = self.dealerNews[indexPath.row];
            salesCell.delegate = self;
            [cell.contentView addSubview:salesCell];
            UIView *bottomLine = [[UIView alloc]init];
            bottomLine.backgroundColor = MainLineGrayColor;
            bottomLine.frame = CGRectMake(0, cell.height - 1,ScreenWidth, 1);
            [cell.contentView addSubview:bottomLine];
        }
        
    }
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    } else {
        if (self.dealerNews.count == 0) {
            return ScreenHeight - 64 - 44 * 3;
        } else {
            
            return 80;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 30;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        UIView *secHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        secHeadView.backgroundColor = MainBackGroundColor;
        
        UILabel *secHeadLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, 30)];
        secHeadLabel.text = @"促销活动";
        
        [secHeadView addSubview:secHeadLabel];
        
        return secHeadView;
    }
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        UIWebView*callWebview =[[UIWebView alloc] init];
        
        NSString *tel = [NSString stringWithFormat:@"%@",self.dealerDict[@"salePhone"]];
        
        NSRange range = [tel rangeOfString:@"或"];
        
        if (range.location > 0 && range.location < tel.length) {
            tel = [tel substringToIndex:range.location];
        }
        
        tel = [tel stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        
        NSString *telUrl = [NSString stringWithFormat:@"tel://%@",tel];
        
        NSURL *telURL =[NSURL URLWithString:telUrl];// 貌似tel:// 或者 tel: 都行
        
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        
        //记得添加到view上
        
        [self.view addSubview:callWebview];
    } else if (indexPath.section == 0 && indexPath.row == 2 ) {
        
        
        //进入地图显示的详情页
        
        MapDetailController *mapDetailVc = [[MapDetailController alloc]initWithDealerDict:self.dealerDict];
        self.mapDetailVc = mapDetailVc;
        [self.navigationController pushViewController:mapDetailVc animated:YES];
        
    }
}

- (void)cSSalesCellClick:(CSSalesCell *)saleCell {
    
    NSDictionary *dict = saleCell.salesDict;
    
    
    CSSaleController *saleVc = [[CSSaleController alloc]initWithUrlString:dict[@"news3gUrl"]];
    self.saleVc = saleVc;
    [self.navigationController pushViewController:saleVc animated:YES];
    
}

//预加载
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == (self.pageIndex - 1) * self.pageSize + 8) {
        [self loadMoreStatus];
    }
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}




@end
