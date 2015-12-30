//
//  CTContentCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-8.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CTContentCell.h"
#import "HTTPHelper.h"
#import <CoreLocation/CoreLocation.h>


#define CTGap 10
#define BottomBtnHeight 30

#define BottomBtnWidth ((ScreenWidth - 4 * CTGap) / 3)

@interface CTContentCell()

@property (nonatomic,weak) UILabel *dealerNameLabel;

@property (nonatomic,weak) UIImageView *fourSImage;

@property (nonatomic,weak) UILabel *soldRangeLabel;

@property (nonatomic,weak) UIImageView *locationImage;

@property (nonatomic,weak) UILabel *distanceLabel;

@property (nonatomic,weak) UIView *seperateLine;

@property (nonatomic,weak) UILabel *addressLabel;

@property (nonatomic,weak) UIButton *phoneBtn;

@property (nonatomic,weak) UIButton *tryDriveBtn;

@property (nonatomic,weak) UIButton *lowPriceBtn;

@property (nonatomic,weak) UIView *firstLine;

@property (nonatomic,weak) UIView *secondLine;

//地理编码
@property(nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic,assign) CGFloat currentLatitude;

@property (nonatomic,assign) CGFloat currentLongtitude;

@end

@implementation CTContentCell

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //创建子视图
        UILabel *dealerNameLabel = [[UILabel alloc]init];
        dealerNameLabel.font = [UIFont systemFontOfSize:16];
        dealerNameLabel.textColor = MainBlackColor;
        self.dealerNameLabel = dealerNameLabel;
        [self addSubview:dealerNameLabel];
        
        UIImageView *fourSImage = [[UIImageView alloc]init];
        self.fourSImage = fourSImage;
        [self addSubview:fourSImage];
        
        UILabel *soldRangeLabel = [[UILabel alloc]init];
        soldRangeLabel.font = [UIFont systemFontOfSize:12];
        soldRangeLabel.textColor = MainFontGrayColor;
        self.soldRangeLabel = soldRangeLabel;
        [self addSubview:soldRangeLabel];
        
        UIImageView *locationImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_models_locationicon"]];
        self.locationImage = locationImage;
        [self addSubview:locationImage];
        
        UILabel *distanceLabel = [[UILabel alloc]init];
        distanceLabel.textColor = MainFontGrayColor;
        distanceLabel.font = [UIFont systemFontOfSize:12];
        self.distanceLabel = distanceLabel;
        [self addSubview:distanceLabel];
        
        //分割线
        UIView *seperateLine = [[UIView alloc]init];
        seperateLine.backgroundColor = MainLineGrayColor;
        self.seperateLine = seperateLine;
        [self addSubview:seperateLine];
        
        UILabel *addressLabel = [[UILabel alloc]init];
        addressLabel.numberOfLines = -1;
        addressLabel.textColor = MainFontGrayColor;
        addressLabel.font = [UIFont systemFontOfSize:14];
        self.addressLabel = addressLabel;
        [self addSubview:addressLabel];
        
        //电话咨询
        UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        phoneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        phoneBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [phoneBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [phoneBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
        [phoneBtn setImage:[UIImage imageNamed:@"chexun_models_phoneicon2"] forState:UIControlStateNormal];
        phoneBtn.imageView.contentMode = UIViewContentModeCenter;
        self.phoneBtn = phoneBtn;
        
        [phoneBtn addTarget:self action:@selector(phoneBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:phoneBtn];
        
        UIView *firstLine = [[UIView alloc]init];
        firstLine.backgroundColor = MainBackGroundColor;
        self.firstLine = firstLine;
        [self addSubview:firstLine];
        
        //预约试驾
        UIButton *tryDriveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tryDriveBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        tryDriveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [tryDriveBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [tryDriveBtn setTitle:@"预约试驾" forState:UIControlStateNormal];
        [tryDriveBtn setImage:[UIImage imageNamed:@"chexun_models_drivingbut"] forState:UIControlStateNormal];
        self.tryDriveBtn = tryDriveBtn;
        [tryDriveBtn addTarget:self action:@selector(tryDriveBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tryDriveBtn];
        
        UIView *secondLine = [[UIView alloc]init];
        secondLine.backgroundColor = MainBackGroundColor;
        self.secondLine = secondLine;
        [self addSubview:secondLine];
        
        //询最低价
        UIButton *lowPriceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        lowPriceBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        lowPriceBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [lowPriceBtn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [lowPriceBtn setTitle:@"询最低价" forState:UIControlStateNormal];
        [lowPriceBtn setImage:[UIImage imageNamed:@"chexun_models_consulticon_2"] forState:UIControlStateNormal];
        self.lowPriceBtn = lowPriceBtn;
        [lowPriceBtn addTarget:self action:@selector(lowPriceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:lowPriceBtn];
        
    }
    return self;
}
//电话咨询
- (void)phoneBtnClick {
    if ([self.delegate respondsToSelector:@selector(cTContentPhoneClick:)]) {
        [self.delegate cTContentPhoneClick:self.dealerDict];
    }
}

//预约试驾
- (void)tryDriveBtnClick {
    if ([self.delegate respondsToSelector:@selector(cTContentTryDriveClick:)]) {
        [self.delegate cTContentTryDriveClick:self.dealerDict];
    }
}

//询最低价
- (void)lowPriceBtnClick {
    if ([self.delegate respondsToSelector:@selector(cTContentLowPriceClick:)]) {
        [self.delegate cTContentLowPriceClick:self.dealerDict];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.phoneBtn.frame = CGRectMake(CTGap, self.height - BottomBtnHeight - CTGap, BottomBtnWidth, BottomBtnHeight);
    self.firstLine.frame = CGRectMake(self.width / 3, self.height - BottomBtnHeight - CTGap, 1, BottomBtnHeight);
    self.tryDriveBtn.frame = CGRectMake(CGRectGetMaxX(self.phoneBtn.frame) + CTGap, self.height - BottomBtnHeight - CTGap, BottomBtnWidth, BottomBtnHeight);
    self.secondLine.frame = CGRectMake(self.width * 2 / 3, self.height - BottomBtnHeight - CTGap, 1, BottomBtnHeight);
    self.lowPriceBtn.frame = CGRectMake(CGRectGetMaxX(self.tryDriveBtn.frame) + CTGap, self.height - BottomBtnHeight - CTGap,BottomBtnWidth, BottomBtnHeight);
    
}


- (void)setDealerDict:(NSDictionary *)dealerDict {
    _dealerDict = dealerDict;
    
    self.fourSImage.frame = CGRectMake(CTGap, CTGap + 3, 18, 14);
    
    NSString *addressStr = [HTTPHelper StringDecode:dealerDict[@"companyAddress"]];
    
    CGSize dealerMaxSize = CGSizeMake(self.width * 0.6, MAXFLOAT);
    CGSize dealerNameSize = [dealerDict[@"dealerShortName"] sizeWithFont:self.dealerNameLabel.font constrainedToSize:dealerMaxSize];
    self.dealerNameLabel.frame = (CGRect){{CGRectGetMaxX(self.fourSImage.frame) + CTGap,CTGap},dealerNameSize};
    
    
    self.soldRangeLabel.frame = CGRectMake(self.width * 0.6, CTGap, 40, self.dealerNameLabel.height);
    
    self.locationImage.frame = CGRectMake(CGRectGetMaxX(self.soldRangeLabel.frame) + 5, CTGap + 5, 8, 10);
    self.distanceLabel.frame = CGRectMake(CGRectGetMaxX(self.locationImage.frame), CTGap, 65, 20);
    self.seperateLine.frame = CGRectMake(CTGap, CGRectGetMaxY(self.dealerNameLabel.frame) + CTGap, self.width - 2 * CTGap, 1);
    
    NSDictionary *addressAttrs = @{NSFontAttributeName : self.addressLabel.font};
    CGSize addressMaxSize = CGSizeMake(self.width - 2 * CTGap, MAXFLOAT);
    CGSize addressSize = [addressStr boundingRectWithSize:addressMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:addressAttrs context:nil].size;
    
    
    self.addressLabel.frame = (CGRect){{CTGap,CGRectGetMaxY(self.seperateLine.frame) + CTGap},addressSize.width,60};
    
    self.dealerNameLabel.text = dealerDict[@"dealerShortName"];
    self.fourSImage.image = [UIImage imageNamed:@"chexun_4sicon"];
    self.soldRangeLabel.text = @"售全国";
    CGFloat distance = 0.0;
    if (dealerDict[@"Distance"] != nil) {
        distance = [dealerDict[@"Distance"] floatValue] / 1000;
        
    }
    
    if ([dealerDict[@"Latitude"] isEqual:@""] || [dealerDict[@"Longitude"] isEqual:@""]) {
        
        [self gecode:addressStr];
        
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1fKM",distance];
    }
    
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

@end
