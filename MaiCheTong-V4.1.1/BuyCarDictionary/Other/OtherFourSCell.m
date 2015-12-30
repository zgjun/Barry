//
//  OtherFourSCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherFourSCell.h"
#import "HTTPHelper.h"
#import <CoreLocation/CoreLocation.h>

#define SpliteViewHeight 10
#define CTGap 10

@interface OtherFourSCell()

@property (nonatomic,weak) UIView *spliteView;

@property (nonatomic,weak) UILabel *dealerNameLabel;

@property (nonatomic,weak) UIView *brandView;

@property (nonatomic,weak) UIImageView *fourSImage;

@property (nonatomic,weak) UILabel *soldRangeLabel;


@property (nonatomic,weak) UILabel *distanceLabel;

@property (nonatomic,weak) UIView *seperateLine;

@property (nonatomic,weak) UILabel *addressLabel;

@property (nonatomic,weak) UILabel *phoneLabel;

@property (nonatomic,weak) UIButton *dealerActiveBtn;

@property (nonatomic,weak) UIView *dealerActiveView;

@property (nonatomic,weak) UIImageView *arrowImage;

//地理编码
@property(nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic,assign) CGFloat currentLatitude;

@property (nonatomic,assign) CGFloat currentLongtitude;
@end



@implementation OtherFourSCell

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


- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //设置子视图
        //添加分割线
        UIView *spliteView = [[UIView alloc]init];
        self.spliteView = spliteView;
        spliteView.backgroundColor = MainBackGroundColor;
        [self addSubview:spliteView];
        
        UIImageView *fourSImage = [[UIImageView alloc]init];
        self.fourSImage = fourSImage;
        [self addSubview:fourSImage];
        
        UILabel *dealerNameLabel = [[UILabel alloc]init];
        dealerNameLabel.font = [UIFont systemFontOfSize:16];
        dealerNameLabel.textColor = MainBlackColor;
        self.dealerNameLabel = dealerNameLabel;
        [self addSubview:dealerNameLabel];
        
        UIView *brandView = [[UIView alloc]init];
        self.brandView = brandView;
        [self addSubview:brandView];
        
        UILabel *distanceLabel = [[UILabel alloc]init];
        distanceLabel.textColor = MainFontGrayColor;
        distanceLabel.font = [UIFont systemFontOfSize:12];
        self.distanceLabel = distanceLabel;
        [self addSubview:distanceLabel];
        
        UILabel *phoneLabel = [[UILabel alloc]init];
        phoneLabel.numberOfLines = -1;
        phoneLabel.textColor = MainFontGrayColor;
        phoneLabel.font = [UIFont systemFontOfSize:12];
        self.phoneLabel = phoneLabel;
        [self addSubview:phoneLabel];
        
        UILabel *addressLabel = [[UILabel alloc]init];
        addressLabel.numberOfLines = -1;
        addressLabel.textColor = MainFontGrayColor;
        addressLabel.font = [UIFont systemFontOfSize:12];
        self.addressLabel = addressLabel;
        [self addSubview:addressLabel];
        
        
        //活动视图
        UIView *dealerActiveView = [[UIView alloc]init];
        dealerActiveView.backgroundColor = [UIColor whiteColor];
        self.dealerActiveView = dealerActiveView;
        [self addSubview:dealerActiveView];
        //活动按钮
        UIButton *dealerActiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dealerActiveBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        dealerActiveBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        dealerActiveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [dealerActiveBtn setTitleColor:MainFontRedColor forState:UIControlStateNormal];
        self.dealerActiveBtn = dealerActiveBtn;
        //活动按钮添加事件
        [dealerActiveBtn addTarget:self action:@selector(dealerActiveBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [dealerActiveView addSubview:dealerActiveBtn];
        
        UIImageView *arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_liftarrow"]];
        self.arrowImage = arrowImage;
        [dealerActiveView addSubview:arrowImage];
        
        UIView *seperateLine = [[UIView alloc]init];
        seperateLine.backgroundColor = MainLineGrayColor;
        self.seperateLine = seperateLine;
        
        [self addSubview:seperateLine];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.spliteView.frame = CGRectMake(0, 0, ScreenWidth, SpliteViewHeight);
}

- (void)setDealerDict:(NSDictionary *)dealerDict {
    _dealerDict = dealerDict;
    
    if ([dealerDict[@"companyType"] integerValue] == 0) {
        self.fourSImage.hidden = YES;
        CGSize dealerMaxSize = CGSizeMake(ScreenWidth * 0.6, MAXFLOAT);
        NSDictionary *dealerAttrs = @{NSFontAttributeName : self.dealerNameLabel.font};
        CGSize dealerSize = [dealerDict[@"dealerShortName"] boundingRectWithSize:dealerMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dealerAttrs context:nil].size;
        self.dealerNameLabel.frame = CGRectMake(CTGap,CTGap + SpliteViewHeight, dealerSize.width, dealerSize.height);
        
        self.distanceLabel.frame = CGRectMake(ScreenWidth - 12 - 60 - CTGap + 15, CTGap + SpliteViewHeight, 60, 20);
        
    } else {
        self.fourSImage.hidden = NO;
        self.fourSImage.frame = CGRectMake(CTGap, CTGap + SpliteViewHeight + 3, 18, 14);
        
        CGSize dealerMaxSize = CGSizeMake(ScreenWidth * 0.6, MAXFLOAT);
        NSDictionary *dealerAttrs = @{NSFontAttributeName : self.dealerNameLabel.font};
        CGSize dealerSize = [dealerDict[@"dealerShortName"] boundingRectWithSize:dealerMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dealerAttrs context:nil].size;
        self.dealerNameLabel.frame = CGRectMake(CGRectGetMaxX(self.fourSImage.frame) + CTGap,CTGap + SpliteViewHeight, dealerSize.width, dealerSize.height);
        
        
        self.distanceLabel.frame = CGRectMake(ScreenWidth - 12 - 60 - CTGap + 15, CTGap + SpliteViewHeight, 60, 20);
    }
    
    NSString *soldStr = dealerDict[@"BrandList"];
    if (soldStr.length != 0) {
        NSArray *soldArr = [soldStr componentsSeparatedByString:@"、"];
        NSInteger soldNum = soldArr.count;
        CGFloat brandViewH = 0;
        
        if (soldNum <= 4 && soldNum > 0) {
            brandViewH = 30;
        } else if (soldNum > 4 && soldNum <= 8) {
            brandViewH = 60;
        } else if (soldNum > 8) {
            brandViewH = 90;
        }
        
        self.brandView.frame = CGRectMake(0, CGRectGetMaxY(self.dealerNameLabel.frame), ScreenWidth, brandViewH);
        
        //创建brandView的子视图
        
        for (int i = 0; i < soldNum; i++) {
            NSInteger soldCol = i % 4;
            NSInteger soldRow = i / 4;
            CGFloat brandX = soldCol * 80 + 10;
            CGFloat brandY = soldRow * 30 + 10;
            CGFloat brandW = 70;
            CGFloat brandH = 20;
            UIImageView *bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(brandX, brandY, brandW, brandH)];
            bgImage.image = [UIImage imageNamed:@"checun_addbox"];
            [self.brandView addSubview:bgImage];
            
            
            UILabel *brandLabel = [[UILabel alloc]init];
            brandLabel.textAlignment = NSTextAlignmentCenter;
            brandLabel.backgroundColor = [UIColor clearColor];
            brandLabel.textColor = MainFontGrayColor;
            brandLabel.font = [UIFont systemFontOfSize:12];
            [bgImage addSubview:brandLabel];
            
            brandLabel.frame = CGRectMake(0, 0, brandW, brandH);
            
            NSString *brandName = soldArr[i];
            brandLabel.text = brandName;
        }
        
        //电话
        CGSize phoneMaxSize = CGSizeMake(ScreenWidth - 2 * CTGap, MAXFLOAT);
        NSString *phoneStr = [NSString stringWithFormat:@"电话：%@",dealerDict[@"salePhone"]];
        
        NSDictionary *phoneAttrs = @{NSFontAttributeName : self.phoneLabel.font};
        
        CGSize phoneSize = [phoneStr boundingRectWithSize:phoneMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:phoneAttrs context:nil].size;
        
        self.phoneLabel.frame = CGRectMake(CTGap,CGRectGetMaxY(self.brandView.frame) + CTGap, phoneSize.width, phoneSize.height);
    } else {
        //电话
        CGSize phoneMaxSize = CGSizeMake(ScreenWidth - 2 * CTGap, MAXFLOAT);
        NSString *phoneStr = [NSString stringWithFormat:@"电话：%@",dealerDict[@"salePhone"]];
        
        NSDictionary *phoneAttrs = @{NSFontAttributeName : self.phoneLabel.font};
        
        CGSize phoneSize = [phoneStr boundingRectWithSize:phoneMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:phoneAttrs context:nil].size;
        
        self.phoneLabel.frame = CGRectMake(CTGap,CGRectGetMaxY(self.dealerNameLabel.frame) + CTGap, phoneSize.width, phoneSize.height);
    }
    
    //地址
    NSString *addressString = [HTTPHelper StringDecode:dealerDict[@"companyAddress"]];
    CGSize addressMaxSize = CGSizeMake(ScreenWidth - 2 * CTGap, MAXFLOAT);
    NSString *addressStr = [NSString stringWithFormat:@"地址：%@",addressString];
    NSDictionary *addressAttrs = @{NSFontAttributeName : self.addressLabel.font};
    CGSize addressSize = [addressStr boundingRectWithSize:addressMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:addressAttrs context:nil].size;
    
    self.addressLabel.frame = CGRectMake(CTGap,CGRectGetMaxY(self.phoneLabel.frame) + CTGap, addressSize.width, addressSize.height);
    
    
    //活动按钮
    if ([dealerDict[@"NewsID"] integerValue] != 0) {
        self.dealerActiveView.hidden = NO;
        self.dealerActiveBtn.hidden = NO;
        self.arrowImage.hidden = NO;
        self.dealerActiveView.frame = CGRectMake(0, CGRectGetMaxY(self.addressLabel.frame) + CTGap, ScreenWidth, 30);
        self.dealerActiveBtn.frame = CGRectMake(CTGap, 0, ScreenWidth - 40, 30);
        self.arrowImage.frame = CGRectMake(CGRectGetMaxX(self.dealerActiveBtn.frame), 18, 5, 8);
        NSString *activeTitle = [HTTPHelper StringDecode:dealerDict[@"NewsTitle"]];
        [self.dealerActiveBtn setTitle:activeTitle forState:UIControlStateNormal];
    } else {
        self.dealerActiveView.hidden = YES;
        self.dealerActiveBtn.hidden = YES;
        self.arrowImage.hidden = YES;
    }
    
    self.seperateLine.frame = CGRectMake(0, self.height - 1, ScreenWidth, 1);
    
    
    self.dealerNameLabel.text = dealerDict[@"dealerShortName"];
    self.fourSImage.image = [UIImage imageNamed:@"chexun_4sicon"];
    CGFloat distance = [dealerDict[@"Distance"] floatValue] / 1000;
    if ([dealerDict[@"Latitude"] isEqual:@""] || [dealerDict[@"Longitude"] isEqual:@""]) {
        
        [self gecode:addressString];
        
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1fkm",distance];
    }
    self.phoneLabel.text = [NSString stringWithFormat:@"电话：%@",dealerDict[@"salePhone"]];
    self.addressLabel.text = addressStr;
}

- (void)gecode:(NSString *)address {
    ;
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        // 地理编码完成就会自动调用
        
        // 有相关信息
        CLPlacemark *pm = [placemarks firstObject];
        // 设置经纬度信息
        CLLocationCoordinate2D coordinate = pm.location.coordinate;
        //        self.latitude = coordinate.latitude;
        //        self.longtitude = coordinate.longitude;
        
        //计算两地的距离
        CLLocation *current = [[CLLocation alloc]initWithLatitude:self.currentLatitude longitude:self.currentLongtitude];
        CLLocation *now = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        CGFloat distance = [current distanceFromLocation:now];
        
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1fKM",distance / 1000];
        
    }];
}



- (void)dealerActiveBtnClick {
    //通知代理
    if ([self.delegate respondsToSelector:@selector(activeBtnClick:)]) {
        [self.delegate activeBtnClick:self.dealerDict[@"News3gUrl"]];
    }
}
@end
