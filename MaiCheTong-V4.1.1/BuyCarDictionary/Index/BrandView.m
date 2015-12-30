//
//  BrandView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-3.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "BrandView.h"
#import "AFNetworking.h"
#import "BrandControl.h"
#import "ContainerView.h"
#define BrandControlWidth 10

@interface BrandView()<UIScrollViewDelegate>
@property (nonatomic,weak) UIScrollView *brandScrollView;
@property (nonatomic,weak) BrandControl *brandControl;

@property (nonatomic,assign) NSInteger page;
@end

@implementation BrandView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //添加一个滚动视图
        UIScrollView *brandScrollView = [[UIScrollView alloc]init];
        self.brandScrollView = brandScrollView;
        brandScrollView.delegate = self;
        brandScrollView.bounces = NO;
        brandScrollView.showsHorizontalScrollIndicator = NO;
        brandScrollView.pagingEnabled = YES;
        [self addSubview:brandScrollView];
        //添加一个页码控件
        BrandControl *brandControl = [[BrandControl alloc]init];
        brandControl.userInteractionEnabled = NO;
        
        [self addSubview:brandControl];
        self.brandControl = brandControl;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //设置各个子控件的frame
    self.brandScrollView.frame = self.bounds;
    self.brandControl.frame = CGRectMake((ScreenWidth - BrandControlWidth) / 2, BrandHeight + 3, BrandControlWidth, 10);
    
}

//- (void)brandViewSetting {
//    //从数据库获取汽车品牌数据
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    NSString *urlStr = @"http://api.tool.chexun.com/mobile/buyCarBrandInfo.do";
//    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        self.brands = responseObject;
//        [self createContainerView];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        MyLog(@"%@",error);
//    }];
//    
//}

- (void)setBrands:(NSArray *)brands {
    _brands = brands;
    [self createContainerView];
}

- (void)createContainerView {
    self.brandControl.numberOfPages = (self.brands.count / BrandsNum);
    self.brandControl.currentPage = 0;
    self.brandScrollView.contentSize = CGSizeMake(self.brands.count * BrandWidth, 0);
    for (int i = 0; i < self.brands.count; i++) {
        ContainerView *containerView = [[ContainerView alloc]init];
        containerView.brandsInfo = self.brands[i];
        containerView.frame = CGRectMake(i * BrandWidth, 0, BrandWidth, BrandHeight);
        containerView.backgroundColor = MainWhiteColor;
        [self.brandScrollView addSubview:containerView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 根据scrollView的滚动位置决定pageControl显示第几页
    CGFloat scrollW = scrollView.frame.size.width;
    int page = (scrollView.contentOffset.x + scrollW * 0.5) / scrollW;
    self.brandControl.currentPage = page;
    self.page = page;
}


@end
