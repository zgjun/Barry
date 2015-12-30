//
//  CarTypeCellView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-2.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "CarTypeCellView.h"

#import "UIImageView+WebCache.h"

#define CarTypeCellWidth 130
#define CarTypeCellHeight 135
#define CarTypeIconHeight 85
#define CarTypeNameHeight 25
#define CarTypePriceHeight (CarTypeCellHeight - CarTypeIconHeight - CarTypeNameHeight)

@interface CarTypeCellView()

@property (nonatomic,weak) UIImageView *icon;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UIView *priceView;
@property (nonatomic,weak) UILabel *priceLabel;
@property (nonatomic,weak) UIView *reducePriceView;
@property (nonatomic,weak) UIImageView *arrowImage;
@property (nonatomic,weak) UILabel *reducePriceLabel;
@end

@implementation CarTypeCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //图片
        UIImageView *icon = [[UIImageView alloc] init];
        
        icon.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:icon];
        self.icon = icon;
        //名字label
        UILabel *nameLabel = [[UILabel alloc]init];
        
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:14];
        
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        //价格view
        UIView *priceView = [[UIView alloc]init];
        
        priceView.contentMode = UIViewContentModeCenter;
        
        self.priceView = priceView;
        [self addSubview:priceView];
        
        UILabel *priceLabel = [[UILabel alloc]init];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.font = [UIFont systemFontOfSize:12];
        
        
        self.priceLabel = priceLabel;
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        [priceView addSubview:priceLabel];
        
        
        //降价view
        UIView *reducePriceView = [[UIView alloc]init];
        self.reducePriceView = reducePriceView;
        [priceView addSubview:reducePriceView];
        
        UIImageView *arrowImage = [[UIImageView alloc]init];
        arrowImage.contentMode = UIViewContentModeCenter;
        
        self.arrowImage = arrowImage;
        [reducePriceView addSubview:arrowImage];
        UILabel *reducePriceLabel = [[UILabel alloc]init];
        
        
        reducePriceLabel.font = [UIFont systemFontOfSize:12];
        reducePriceLabel.textAlignment = NSTextAlignmentLeft;
        reducePriceLabel.textColor = MainFontRedColor;
        self.reducePriceLabel = reducePriceLabel;
        [reducePriceView addSubview:reducePriceLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.icon.frame = CGRectMake(0, 0, self.width, CarTypeIconHeight);
    
    self.nameLabel.frame = CGRectMake(0, CarTypeIconHeight, self.width, CarTypeNameHeight);
    
    
}

- (void)setDataDict:(NSDictionary *)dataDict {
    
    _dataDict = dataDict;
    
    NSString *imagePath = dataDict[@"imgPath"];
    
    //判断字典里面返回的为空值
    if (imagePath == NULL) {
        self.icon.image = [UIImage imageNamed:@"load1"];
    } else {
        
        [self.icon sd_setImageWithURL:[NSURL URLWithString:dataDict[@"imgPath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    }
    
    self.nameLabel.text = dataDict[@"name"];
    self.priceLabel.text = dataDict[@"guidePrice"];
    self.reducePriceLabel.text = dataDict[@"hq"];
    
    
    NSString *str = [NSString stringWithFormat:@"%@",dataDict[@"hq"]];
    
    //判断字典里面返回的为空值
    if (str.length <= 0 || str == nil || str == NULL || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || dataDict[@"hq"] == nil) {
        self.arrowImage.hidden = YES;
        self.reducePriceLabel.hidden = YES;
        self.priceView.frame = CGRectMake(0, CarTypeIconHeight + CarTypeNameHeight, self.width, CarTypePriceHeight);
        
        self.priceLabel.frame = CGRectMake(0, 0, self.priceView.width , self.priceView.height);
    } else {
        self.arrowImage.image = [UIImage imageNamed:@"chexun_sale"];
        self.priceView.frame = CGRectMake(0, CarTypeIconHeight + CarTypeNameHeight, self.width, CarTypePriceHeight);
        
        self.priceLabel.frame = CGRectMake(0, 0, self.priceView.width * 0.75 , self.priceView.height);
        
        self.reducePriceView.frame = CGRectMake(self.priceLabel.width, 0, self.priceView.width * 0.4 , self.priceView.height);
        
        self.arrowImage.frame = CGRectMake(0, 0, 20, self.reducePriceView.height);
        
        self.reducePriceLabel.frame = CGRectMake(20 + 3, 0,self.reducePriceView.width - 10 , self.reducePriceView.height);
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(carTypeCellViewClick:)]) {
        [self.delegate carTypeCellViewClick:self];
    }
}

@end
