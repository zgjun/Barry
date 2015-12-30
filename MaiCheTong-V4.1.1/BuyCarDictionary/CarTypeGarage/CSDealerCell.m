//
//  CSDealerCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-9.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSDealerCell.h"
#import "HTTPHelper.h"
#import <CoreLocation/CoreLocation.h>
#define SpliteViewHeight 10
#define CTGap 10

@interface CSDealerCell()

@property (nonatomic,weak) UIView *bottomLine;

@property (nonatomic,weak) UILabel *dealerNameLabel;

@property (nonatomic,weak) UIImageView *fourSImage;

//@property (nonatomic,weak) UILabel *soldRangeLabel;

//@property (nonatomic,weak) UIImageView *locationImage;

@property (nonatomic,weak) UILabel *distanceLabel;

@property (nonatomic,weak) UILabel *addressLabel;

//@property (nonatomic,weak) UILabel *phoneLabel;

@property (nonatomic,weak) UIButton *dealerActiveBtn;

@property (nonatomic,weak) UIView *dealerActiveView;

@property (nonatomic,weak) UIImageView *arrowImage;


//地理编码
@property(nonatomic, strong) CLGeocoder *geocoder;

//@property (nonatomic,assign) CGFloat latitude;
//
//@property (nonatomic,assign) CGFloat longtitude;

@property (nonatomic,assign) CGFloat currentLatitude;

@property (nonatomic,assign) CGFloat currentLongtitude;


@end



@implementation CSDealerCell

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

//type:0 表示虚线 type:1 表示实现
- (instancetype)initWithLineType:(NSInteger)lineType {
    if (self = [super init]) {
        //设置子视图
        
        UIImageView *fourSImage = [[UIImageView alloc]init];
        self.fourSImage = fourSImage;
        [self addSubview:fourSImage];
        
        UILabel *dealerNameLabel = [[UILabel alloc]init];
        dealerNameLabel.font = [UIFont systemFontOfSize:16];
        dealerNameLabel.textColor = MainBlackColor;
        self.dealerNameLabel = dealerNameLabel;
        [self addSubview:dealerNameLabel];
        
        UILabel *distanceLabel = [[UILabel alloc]init];
        distanceLabel.textColor = MainFontGrayColor;
        distanceLabel.font = [UIFont systemFontOfSize:12];
        self.distanceLabel = distanceLabel;
        [self addSubview:distanceLabel];
        
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
        
        if (lineType == 0) {
            //分割线
            NSString *backgroudpath = [[NSBundle mainBundle] pathForResource:@"chexun_dotted-line" ofType:@"png"];
            
            UIView *bottomLine = [[UIView alloc]init];
            
            UIImage  *backgroudImage = [UIImage imageWithContentsOfFile:backgroudpath];
            bottomLine.backgroundColor=[UIColor colorWithPatternImage:backgroudImage] ;
            self.bottomLine = bottomLine;
            [self addSubview:bottomLine];
        } else {
            UIView *bottomLine = [[UIView alloc]init];
            bottomLine.backgroundColor = MainLineGrayColor;
            self.bottomLine = bottomLine;
            
            [self addSubview:bottomLine];
        }
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bottomLine.frame = CGRectMake(0, self.height - 1, ScreenWidth, 1);
}

- (void)setDealerDict:(NSDictionary *)dealerDict {
    _dealerDict = dealerDict;
    
    if ([dealerDict[@"companyType"] integerValue] == 0) {
        self.fourSImage.hidden = YES;
        CGSize dealerMaxSize = CGSizeMake(ScreenWidth * 0.6, MAXFLOAT);
        NSDictionary *dealerAttrs = @{NSFontAttributeName : self.dealerNameLabel.font};
        CGSize dealerSize = [dealerDict[@"dealerShortName"] boundingRectWithSize:dealerMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dealerAttrs context:nil].size;
        self.dealerNameLabel.frame = CGRectMake(CTGap,CTGap, dealerSize.width, dealerSize.height);
        
//        self.soldRangeLabel.frame = CGRectMake(ScreenWidth * 0.6, CTGap + SpliteViewHeight, 40, self.dealerNameLabel.height);
        
//        self.locationImage.frame = CGRectMake(ScreenWidth - 65 - 12 -  CTGap, CTGap, 12, 15);
        self.distanceLabel.frame = CGRectMake(ScreenWidth - 65 - 12 * 2 -  CTGap, CTGap, 65, 20);
        
        
    } else {
        self.fourSImage.hidden = NO;
        self.fourSImage.frame = CGRectMake(CTGap, CTGap + 3, 18, 14);
        
        CGSize dealerMaxSize = CGSizeMake(ScreenWidth * 0.6, MAXFLOAT);
        NSDictionary *dealerAttrs = @{NSFontAttributeName : self.dealerNameLabel.font};
        CGSize dealerSize = [dealerDict[@"dealerShortName"] boundingRectWithSize:dealerMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dealerAttrs context:nil].size;
        self.dealerNameLabel.frame = CGRectMake(CGRectGetMaxX(self.fourSImage.frame) + CTGap,CTGap , dealerSize.width, dealerSize.height);
        
        self.distanceLabel.frame = CGRectMake(ScreenWidth - 65 - 12 * 2 -  CTGap, CTGap, 65, 20);
    }
    
    
    //地址
    NSString *addressString = [HTTPHelper StringDecode:dealerDict[@"companyAddress"]];
    
    
    CGSize addressMaxSize = CGSizeMake(ScreenWidth - 2 * CTGap, MAXFLOAT);
    NSString *addressStr = [NSString stringWithFormat:@"地址：%@",addressString];
    NSDictionary *addressAttrs = @{NSFontAttributeName : self.addressLabel.font};
    CGSize addressSize = [addressStr boundingRectWithSize:addressMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:addressAttrs context:nil].size;
    
    self.addressLabel.frame = CGRectMake(CTGap,CGRectGetMaxY(self.dealerNameLabel.frame) + CTGap, addressSize.width, addressSize.height);
    
    
    //活动按钮
    if ([dealerDict[@"NewsID"] integerValue] != 0) {
        self.dealerActiveView.hidden = NO;
        self.dealerActiveBtn.hidden = NO;
        self.arrowImage.hidden = NO;
       self.dealerActiveView.frame = CGRectMake(0, CGRectGetMaxY(self.addressLabel.frame) + 5, ScreenWidth, 30);
        self.dealerActiveBtn.frame = CGRectMake(CTGap, 0, ScreenWidth - 40, 30);
        self.arrowImage.frame = CGRectMake(CGRectGetMaxX(self.dealerActiveBtn.frame), 11, 5, 8);
        NSString *activeTitle = [HTTPHelper StringDecode:dealerDict[@"NewsTitle"]];
        [self.dealerActiveBtn setTitle:activeTitle forState:UIControlStateNormal];
    } else {
        self.dealerActiveView.hidden = YES;
        self.dealerActiveBtn.hidden = YES;
        self.arrowImage.hidden = YES;
    }
    self.dealerNameLabel.text = dealerDict[@"dealerShortName"];
    self.fourSImage.image = [UIImage imageNamed:@"chexun_4sicon"];
    
    CGFloat distance = [dealerDict[@"Distance"] floatValue] / 1000;
    if ([dealerDict[@"Latitude"] isEqual:@""] || [dealerDict[@"Longitude"] isEqual:@""]) {
        
        [self gecode:addressString];
        
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1fKM",distance];
    }
    
    self.addressLabel.text = addressStr;
}

- (void)dealerActiveBtnClick {
    //通知代理
    if ([self.delegate respondsToSelector:@selector(activeBtnClick:)]) {
        [self.delegate activeBtnClick:self.dealerDict[@"News3gUrl"]];
    }
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
