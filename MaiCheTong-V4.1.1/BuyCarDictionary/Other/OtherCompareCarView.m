//
//  OtherCompareCarView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-15.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OtherCompareCarView.h"
#import "NoHighLightBtn.h"
#import "UIImage+Extension.h"
#import "CompareButton.h"
#import "UIImageView+WebCache.h"
#define GapWidth 15
#define CTTitleBarWidth 80
#define CellWidth (ScreenWidth - CTTitleBarWidth) * 0.5
#define CTCarTypeHeight 90

@interface OtherCompareCarView()
@property (nonatomic,weak) UILabel *carTypeName;
@property (nonatomic,weak) UIImageView *carImage;
@property (nonatomic,weak) UIImageView *imageView;
@property (nonatomic,weak) NoHighLightBtn *reduceBtn;

@property (nonatomic,weak) UIView *bgView;

@property (nonatomic,weak) CompareButton *compareBtn;

@end

@implementation OtherCompareCarView

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
        carTypeName.textAlignment = NSTextAlignmentCenter;
        self.carTypeName = carTypeName;
        [self.imageView addSubview:carTypeName];
        
        
        NoHighLightBtn *reduceBtn = [[NoHighLightBtn alloc]init];
        [reduceBtn setBackgroundImage:[UIImage imageNamed:@"chexun_deletebut"] forState:UIControlStateNormal];
        self.reduceBtn = reduceBtn;
        [reduceBtn addTarget:self action:@selector(reduceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:reduceBtn];
        
        
        //没有数据时的子视图
        UIView *bgView = [[UIView alloc]init];
        bgView.backgroundColor = MainLineGrayColor;
        self.bgView = bgView;
        [self addSubview:bgView];
        
        CompareButton *compareBtn = [[CompareButton alloc]init];
        [compareBtn setImage:[UIImage imageNamed:@"chexun_pk_addicon"] forState:UIControlStateNormal];
        [compareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [compareBtn setBackgroundColor:RandColor];
        [compareBtn setTitle:@"添加对比" forState:UIControlStateNormal];
        compareBtn.imageView.contentMode = UIViewContentModeCenter;
        compareBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.compareBtn = compareBtn;
        [compareBtn addTarget:self action:@selector(compareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:compareBtn];
        
    }
    return self;
}

- (void)compareBtnClick:(CompareButton *)compareBtn {
    if ([self.delegate respondsToSelector:@selector(otherCompareBtnClick)]) {
        [self.delegate otherCompareBtnClick];
    }
}

- (void)reduceBtnClick:(NoHighLightBtn *)btn {
    if ([self.delegate respondsToSelector:@selector(otherReduceBtnClick:)]) {
        [self.delegate otherReduceBtnClick:self];
    }
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    if (dataDict == nil) {
        self.bgView.hidden = NO;
        self.compareBtn.hidden = NO;
        self.imageView.hidden = YES;
        self.carImage.hidden = YES;
        self.reduceBtn.hidden = YES;
        self.carTypeName.hidden = YES;
        self.bgView.frame = CGRectMake(0, 10, CellWidth - GapWidth, CTCarTypeHeight - 10);
        
        self.compareBtn.frame = CGRectMake(0, (CTCarTypeHeight - 50) * 0.5, CellWidth, 50);
        
        self.imageView.frame = CGRectZero;
        
    } else {
        
        self.bgView.hidden = YES;
        self.compareBtn.hidden = YES;
        self.imageView.hidden = NO;
        self.carImage.hidden = NO;
        self.reduceBtn.hidden = NO;
        self.carTypeName.hidden = NO;
        self.imageView.frame = CGRectMake(0, 10, self.width - GapWidth, self.height - 10);
        CGFloat carImageH = self.imageView.height * 0.4;
        CGFloat carImageW = carImageH * 1.5;
        CGFloat carImageX = (self.imageView.width - carImageW) * 0.5;
        self.carImage.frame = CGRectMake(carImageX, 5, carImageW, carImageH);
        
        self.carTypeName.text = dataDict[@"carTypeName"];
        
//        CGFloat tipLabelX = self.carTypeName.x;
//        
//        CGFloat tipLabelY = self.carTypeName.y;
        
        CGSize maxSize = CGSizeMake(self.width - 20, MAXFLOAT);
        
        CGSize tipLabelSize = [dataDict[@"carTypeName"] sizeWithFont:self.carTypeName.font constrainedToSize:maxSize];
        
//        self.carTypeName.frame = (CGRect){{tipLabelX,tipLabelY},tipLabelSize};
        
        self.carTypeName.frame = CGRectMake(0, CGRectGetMaxY(self.carImage.frame), self.width - 20, tipLabelSize.height);
        self.reduceBtn.frame = CGRectMake(self.width - 25, 0, 23, 23);
        
        
        [self.carImage sd_setImageWithURL:[NSURL URLWithString:dataDict[@"carTypeImage"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    }
}
@end
