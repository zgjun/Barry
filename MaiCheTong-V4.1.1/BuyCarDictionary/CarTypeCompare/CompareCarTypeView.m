//
//  CompareCarTypeView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-15.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CompareCarTypeView.h"
#import "NoHighLightBtn.h"
#import "UIImage+Extension.h"
#import "CompareButton.h"
#import "UIImageView+WebCache.h"

#define GapWidth 15

@interface CompareCarTypeView()
@property (nonatomic,weak) UILabel *carTypeName;
@property (nonatomic,weak) UIImageView *carImage;
@property (nonatomic,weak) UIImageView *imageView;
@property (nonatomic,weak) NoHighLightBtn *reduceBtn;

@end

@implementation CompareCarTypeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc]init];
        self.imageView = imageView;
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage resizableImageWithName:@"checun_pkbox"];
        [self addSubview:imageView];
        
        UIImageView *carImage = [[UIImageView alloc]init];
        self.carImage = carImage;
        [self.imageView addSubview:carImage];
        
        
        UILabel *carTypeName = [[UILabel alloc]init];
        carTypeName.font = [UIFont systemFontOfSize:12];
        carTypeName.numberOfLines = -1;
        carTypeName.textColor = MainFontGrayColor;
        carTypeName.textAlignment = NSTextAlignmentCenter;
        self.carTypeName = carTypeName;
        [self.imageView addSubview:carTypeName];
        
        
        NoHighLightBtn *reduceBtn = [[NoHighLightBtn alloc]init];
        [reduceBtn setBackgroundImage:[UIImage imageNamed:@"chexun_deletebut"] forState:UIControlStateNormal];
        self.reduceBtn = reduceBtn;
        [reduceBtn addTarget:self action:@selector(reduceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:reduceBtn];
    }
    return self;
}

- (void)reduceBtnClick:(NoHighLightBtn *)btn {
    if ([self.delegate respondsToSelector:@selector(compareReduceBtnClick:)]) {
        [self.delegate compareReduceBtnClick:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 10, self.width - GapWidth, self.height - 10);
    CGFloat carImageH = self.imageView.height * 0.4;
    CGFloat carImageW = carImageH * 1.5;
    CGFloat carImageX = (self.imageView.width - carImageW) * 0.5;
    self.carImage.frame = CGRectMake(carImageX, 5, carImageW, carImageH);
    
    self.carTypeName.frame = CGRectMake(0, CGRectGetMaxY(self.carImage.frame), self.imageView.width, self.imageView.height * 0.6 - 5);
    self.reduceBtn.frame = CGRectMake(self.width - 25, 0, 23, 23);
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    self.carTypeName.text = dataDict[@"carTypeName"];
    
    CGFloat tipLabelX = self.carTypeName.x;
    
    CGFloat tipLabelY = self.carTypeName.y;
    
    CGSize maxSize = CGSizeMake(self.carTypeName.width, MAXFLOAT);
    
    CGSize tipLabelSize = [dataDict[@"carTypeName"] sizeWithFont:self.carTypeName.font constrainedToSize:maxSize];
    
    self.carTypeName.frame = (CGRect){{tipLabelX,tipLabelY},tipLabelSize};
    
    [self.carImage sd_setImageWithURL:[NSURL URLWithString:dataDict[@"carTypeImage"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    
}

@end
