//
//  IndexContentCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "IndexContentCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"


#define CarTypeIconWidth 150
#define CarTypeIconHeight 100
#define CarTypeNameHeight 25
#define IndexContentCellGap 10
#define BrandIconSide 25
#define CarTypeIconGap ((ScreenWidth - CarTypeIconWidth * 2) * 0.25)

#define IndexContentCellSpace 3

@interface IndexContentCell()

@property (nonatomic,weak) UIImageView *icon;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UILabel *priceLabel;
@property (nonatomic,weak) UIView *reducePriceView;
@property (nonatomic,weak) UIImageView *arrowImage;
@property (nonatomic,weak) UILabel *reducePriceLabel;
@property (nonatomic,weak) UIView *brandView;
@property (nonatomic,weak) UIImageView *leftImage;
@property (nonatomic,weak) UIImageView *brandIcon;
@property (nonatomic,weak) UIImageView *rightImage;
@property (nonatomic,weak) UIImageView *brandBg;
@end

@implementation IndexContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //图片
        UIImageView *icon = [[UIImageView alloc] init];
        
        icon.contentMode = UIViewContentModeScaleAspectFit;
        self.icon = icon;
        
        [self addSubview:icon];
        
        //中间的品牌
        UIView *brandView = [[UIView alloc]init];
        self.brandView = brandView;
        [self addSubview:brandView];
        
        UIImageView *leftImage = [[UIImageView alloc]initWithImage:[UIImage resizableImageWithName:@"chexun_line"]];
        self.leftImage = leftImage;
        [brandView addSubview:leftImage];
        
        
        UIImageView *brandBg = [[UIImageView alloc]init];
        self.brandBg = brandBg;
        [brandView addSubview:brandBg];
        
        UIImageView *brandIcon = [[UIImageView alloc]init];
        
        brandIcon.layer.cornerRadius = 11;
        brandIcon.layer.masksToBounds = YES;
        
        self.brandIcon = brandIcon;
        [brandBg addSubview:brandIcon];
        
        UIImageView *rightImage = [[UIImageView alloc]initWithImage:[UIImage resizableImageWithName:@"chexun_line"]];
        self.rightImage = rightImage;
        [brandView addSubview:rightImage];
        
        
        //名字label
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.textColor = MainBlackColor;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:16];
        
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        //价格label
        
        UILabel *priceLabel = [[UILabel alloc]init];
        priceLabel.textColor = MainBlackColor;
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.font = [UIFont systemFontOfSize:12];
        
        
        self.priceLabel = priceLabel;
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:priceLabel];
        
        
        //降价view
        UIView *reducePriceView = [[UIView alloc]init];
        reducePriceView.contentMode = UIViewContentModeCenter;
        self.reducePriceView = reducePriceView;
        [self addSubview:reducePriceView];
        
        UIImageView *arrowImage = [[UIImageView alloc]init];
        arrowImage.contentMode = UIViewContentModeCenter;
        
        self.arrowImage = arrowImage;
        [reducePriceView addSubview:arrowImage];
        UILabel *reducePriceLabel = [[UILabel alloc]init];
        
        
        reducePriceLabel.font = [UIFont systemFontOfSize:16];
        reducePriceLabel.textAlignment = NSTextAlignmentLeft;
        reducePriceLabel.textColor = MainFontRedColor;
        self.reducePriceLabel = reducePriceLabel;
        [reducePriceView addSubview:reducePriceLabel];
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat lineWidth = (ScreenWidth * 0.5 - 2 * IndexContentCellGap - 2 * IndexContentCellSpace - BrandIconSide) * 0.5;
    
    self.icon.frame = CGRectMake(CarTypeIconGap, 0, CarTypeIconWidth, CarTypeIconHeight);
    
    self.brandView.frame = CGRectMake(0, CGRectGetMaxY(self.icon.frame), ScreenWidth * 0.5, BrandIconSide);
    self.leftImage.frame = CGRectMake(IndexContentCellGap, (BrandIconSide - 1) * 0.5, lineWidth , 1);
    
    self.brandBg.frame = CGRectMake((self.width - BrandIconSide) * 0.5, 0, BrandIconSide, BrandIconSide);
    
    self.brandIcon.frame = CGRectMake(1.5, 1.5, BrandIconSide - 3, BrandIconSide - 3);
    
    self.rightImage.frame = CGRectMake(CGRectGetMaxX(self.brandBg.frame) + IndexContentCellSpace, (BrandIconSide - 1) * 0.5, lineWidth, 1);
    
    
    self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.brandView.frame) + IndexContentCellSpace, self.width, CarTypeNameHeight);
    
    self.priceLabel.frame = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame) + IndexContentCellSpace, self.width, CarTypeNameHeight);
    
    self.reducePriceView.frame = CGRectMake(0, CGRectGetMaxY(self.priceLabel.frame) + IndexContentCellSpace, self.width, CarTypeNameHeight);
    
    
}

- (void)setDataDict:(NSDictionary *)dataDict {
    
    _dataDict = dataDict;
    
    NSString *imagePath = dataDict[@"imgPath"];
    
    //判断字典里面返回的为空值
    if (imagePath == NULL) {
        [self.icon sd_setImageWithURL:[NSURL URLWithString:dataDict[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    } else {
        
        [self.icon sd_setImageWithURL:[NSURL URLWithString:dataDict[@"imgPath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    }
    
    //品牌icon
    
    self.brandBg.image = [UIImage imageNamed:@"chexun_home_logobg"];
    
    
    NSString *brandPath = dataDict[@"brandLogo"];
    if (brandPath == NULL) {
        [self.brandIcon sd_setImageWithURL:[NSURL URLWithString:dataDict[@"brandImagePath"]] placeholderImage:[UIImage imageNamed:@"chexun_home_logobg"]];
    } else {
        [self.brandIcon sd_setImageWithURL:[NSURL URLWithString:brandPath] placeholderImage:[UIImage imageNamed:@"chexun_home_logobg"]];
    }
    
    CGSize nameMaxSize = CGSizeMake(ScreenWidth * 0.6, MAXFLOAT);
    NSDictionary *nameAttrs = @{NSFontAttributeName : self.nameLabel.font};
    CGSize nameSize = [dataDict[@"name"] boundingRectWithSize:nameMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:nameAttrs context:nil].size;
    
    if (nameSize.width > self.width) {
        self.nameLabel.font = [UIFont systemFontOfSize:12];
    }
    if (dataDict[@"name"] == NULL) {
        self.nameLabel.text = dataDict[@"seriesName"];
    } else {
        self.nameLabel.text = dataDict[@"name"];
    }
    
    self.priceLabel.text = dataDict[@"guidePrice"];
    self.reducePriceLabel.text = [NSString stringWithFormat:@"%@",dataDict[@"hq"]];
    
    
    NSString *str = [NSString stringWithFormat:@"%@",dataDict[@"hq"]];
    
    
    //判断字典里面返回的为空值
    if (str.length <= 0  || str == nil || str == NULL || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || dataDict[@"hq"] == nil) {
        self.arrowImage.hidden = YES;
        self.reducePriceLabel.hidden = YES;
    } else {
        self.arrowImage.image = [UIImage imageNamed:@"chexun_sale"];
        
        
        self.arrowImage.frame = CGRectMake(self.width * 0.4 - 10, (CarTypeNameHeight - 10) * 0.5, 10, 10);
        
        self.reducePriceLabel.frame = CGRectMake(self.width * 0.4 + 8, 0,self.width * 0.6 - 5 , CarTypeNameHeight);
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(carTypeCellViewClick:)]) {
        [self.delegate carTypeCellViewClick:self];
    }
}

@end
