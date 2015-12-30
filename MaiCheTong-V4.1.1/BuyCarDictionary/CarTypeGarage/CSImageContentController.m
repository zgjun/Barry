//
//  CSImageShowController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSImageContentController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+GJ.h"
#import "CSImageView.h"
#import "MJRefresh.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#define TabBarHeight 49
#define CSImageGap 10
#define CSImageWidth (ScreenWidth - CSImageGap) * 0.5
#define CSImageHeight CSImageWidth * 0.7

@interface CSImageContentController ()<CSImageViewDelegate,UITableViewDataSource,UITableViewDelegate,MJPhotoBrowserDelegate>

///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic , strong) __block NSMutableArray *assets;

@property (nonatomic,weak) CSImageView *currentImage;

@property (nonatomic,assign) NSInteger pageSize;

@property (nonatomic,assign) NSInteger pageNo;

@property (nonatomic,strong) NSString *albumType;

@property (nonatomic,strong) MJPhotoBrowser *photoBrowser;

@end

@implementation CSImageContentController

- (NSMutableArray *)assets {
    if (_assets == nil) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self pushRefresh];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.backgroundColor = MainBackGroundColor;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ContentCell"];
    
    //初始化相关数据
    self.pageSize = 20;
    self.pageNo = 1;
    
    
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

- (void)loadMoreStatus {
    self.pageNo = self.pageNo + 1;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarPicList.do?seriesId=%@&albumType=%@&pageNo=%@&pageSize=%@",self.seriesId,self.albumType,@(self.pageNo),@(self.pageSize)];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CSImageContentController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject[@"picList"];
        if(arr.count > 0) {
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dict = arr[i];
                [myself.assets addObject:dict[@"imagePath"]];
                
                [myself.contentArr addObject:dict];
            }
            
            [myself.tableView reloadData];
            [myself.tableView.gifFooter endRefreshing];
        } else {
            [myself.tableView.gifFooter endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
}

- (void)loadDataWithType:(NSString *)albumType {
    self.albumType = albumType;
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData:albumType];
    
}

- (void)getData:(NSString *)albumType {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.tool.chexun.com/mobile/buyCarPicList.do?seriesId=%@&albumType=%@&pageNo=%@&pageSize=%@",self.seriesId,albumType,@(self.pageNo),@(self.pageSize)];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.contentArr = [NSMutableArray arrayWithArray:responseObject[@"picList"]];
        
        if (self.assets.count > 0) {
            self.assets = [NSMutableArray array];
        }
        
        for (int i = 0; i < self.contentArr.count; i++) {
            NSDictionary *dict = self.contentArr[i];
            
            
            [self.assets addObject:dict[@"imagePath"]];
        }
        
        [self.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView: self.tableView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
}

#pragma mark - UITableView数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (self.contentArr.count % 2 ==0) {
        return self.contentArr.count * 0.5;
    } else {
        
        return self.contentArr.count * 0.5 + 1;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    if (self.contentArr.count % 2 == 0) {
        CSImageView *leftImage = [[CSImageView alloc]initWithFrame:CGRectMake(0, CSImageGap, CSImageWidth, CSImageHeight)];
        leftImage.delegate = self;
        leftImage.tag = indexPath.row * 2 + 1;
        NSDictionary *dictLeft = self.contentArr[indexPath.row * 2];
        [leftImage sd_setImageWithURL:[NSURL URLWithString:dictLeft[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
        
        [cell.contentView addSubview:leftImage];
        
        CSImageView *rightImage = [[CSImageView alloc]initWithFrame:CGRectMake(CSImageGap + CSImageWidth, CSImageGap, CSImageWidth, CSImageHeight)];
        rightImage.delegate = self;
        rightImage.tag = indexPath.row * 2 + 2;
        NSDictionary *dictRight = self.contentArr[indexPath.row * 2 + 1];
        [rightImage sd_setImageWithURL:[NSURL URLWithString:dictRight[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
        [cell.contentView addSubview:rightImage];
    } else {
        if ((indexPath.row * 2 + 1) == self.contentArr.count) {
            CSImageView *leftImage = [[CSImageView alloc]initWithFrame:CGRectMake(0, CSImageGap, CSImageWidth, CSImageHeight)];
            leftImage.delegate = self;
            leftImage.tag = indexPath.row * 2 + 1;
            NSDictionary *dictLeft = self.contentArr[indexPath.row * 2];
            [leftImage sd_setImageWithURL:[NSURL URLWithString:dictLeft[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
            [cell.contentView addSubview:leftImage];
        } else {
            CSImageView *leftImage = [[CSImageView alloc]initWithFrame:CGRectMake(0, CSImageGap, CSImageWidth, CSImageHeight)];
            leftImage.delegate = self;
            leftImage.tag = indexPath.row * 2 + 1;
            NSDictionary *dictLeft = self.contentArr[indexPath.row * 2];
            [leftImage sd_setImageWithURL:[NSURL URLWithString:dictLeft[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
            
            [cell.contentView addSubview:leftImage];
            
            CSImageView *rightImage = [[CSImageView alloc]initWithFrame:CGRectMake(CSImageGap + CSImageWidth, CSImageGap, CSImageWidth, CSImageHeight)];
            rightImage.delegate = self;
            rightImage.tag = indexPath.row * 2 + 2;
            NSDictionary *dictRight = self.contentArr[indexPath.row * 2 + 1];
            [rightImage sd_setImageWithURL:[NSURL URLWithString:dictRight[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
            [cell.contentView addSubview:rightImage];
        }
    }
    
    
    return cell;
}

#pragma mark - UITableView代理方法

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CSImageHeight + CSImageGap;
}

- (void)cSImageViewClick:(CSImageView *)cSImageView {
    
    self.currentImage = cSImageView;
    
//    [self setupPhotoBrowser:cSImageView];
    
    MJPhotoBrowser *photoBrowser = [[MJPhotoBrowser alloc]init];
    self.photoBrowser = photoBrowser;
    photoBrowser.delegate = self;
    
    NSMutableArray *tempArr = [NSMutableArray array];
    MyLog(@"assets==%@",self.assets);
    for (int i = 0; i < self.assets.count; i++ ) {
        MJPhoto *photo = [[MJPhoto alloc]init];
        photo.url = [NSURL URLWithString:self.assets[i]];
//        mjPhoto.srcImageView = self.subviews[i];
        [tempArr addObject:photo];
    }
    photoBrowser.photos = tempArr;
    photoBrowser.currentPhotoIndex = cSImageView.tag - 1;
    [self.navigationController pushViewController:photoBrowser animated:YES];

    
    
}

- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index {
    
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}




//#pragma mark - setupCell click ZLPhotoPickerBrowserViewController
//- (void) setupPhotoBrowser:(CSImageView *) cSImageView{
//    
//    // 图片游览器
//    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
//    // 传入点击图片View的话，会有微信朋友圈照片的风格
//    pickerBrowser.toView = cSImageView;
//    // 数据源/delegate
//    pickerBrowser.delegate = self;
//    pickerBrowser.dataSource = self;
//    // 是否可以删除照片
//    pickerBrowser.editing = NO;
//    // 当前选中的值
//    pickerBrowser.currentPage = cSImageView.tag - 1;
//    // 展示控制器
//    [pickerBrowser show];
//    
////    [self addChildViewController:pickerBrowser];
//}
//
//#pragma mark - select Photo Library
//- (void)selectPhotos {
//    // 创建控制器
//    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
//    // 默认显示相册里面的内容SavePhotos
//    pickerVc.status = PickerViewShowStatusCameraRoll;
//    // 选择图片的最大数
//    // pickerVc.maxCount = 4;
//    pickerVc.delegate = self;
//    [pickerVc show];
//    /**
//     *
//     传值可以用代理，或者用block来接收，以下是block的传值
//     __weak typeof(self) weakSelf = self;
//     pickerVc.callBack = ^(NSArray *assets){
//     weakSelf.assets = assets;
//     [weakSelf.tableView reloadData];
//     };
//     */
//}
//
//- (void)pickerViewControllerDoneAsstes:(NSArray *)assets{
//    [self.assets addObjectsFromArray:assets];
////    [self.tableView reloadData];
//}
//
//#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
//- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser{
//    return 1;
//}
//
//- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
//    return self.assets.count;
//}
//
//- (ZLPhotoPickerBrowserPhoto *) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
//    
//    ZLPhotoAssets *imageObj = [self.assets objectAtIndex:indexPath.row];
//    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
//    
////    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    photo.thumbImage = self.currentImage.image;
//    return photo;
//}
//
//#pragma mark - <ZLPhotoPickerBrowserViewControllerDelegate>
//- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row > [self.assets count]) return;
//    [self.assets removeObjectAtIndex:indexPath.row];
//    [self.tableView reloadData];
//}

@end
