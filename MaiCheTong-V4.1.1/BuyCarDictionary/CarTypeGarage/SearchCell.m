//
//  SearchCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-5-4.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "SearchCell.h"


#define SearchCellGap 5

@interface SearchCell()

@property (nonatomic,strong) UILabel *seriesLabel;

@property (nonatomic,strong) UILabel *brandLabel;

@property (nonatomic,strong) UILabel *priceLabel;
@end

@implementation SearchCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //创建子视图
        UILabel *seriesLabel = [[UILabel alloc]init];
        seriesLabel.font = [UIFont systemFontOfSize:16];
        seriesLabel.textColor = MainBlackColor;
        seriesLabel.textAlignment = NSTextAlignmentLeft;
        self.seriesLabel = seriesLabel;
        [self addSubview:seriesLabel];
        
        UILabel *brandLabel = [[UILabel alloc]init];
        brandLabel.textColor = MainFontGrayColor;
        brandLabel.font = [UIFont systemFontOfSize:14];
        brandLabel.textAlignment = NSTextAlignmentLeft;
        self.brandLabel = brandLabel;
        [self addSubview:brandLabel];
        
        UILabel *priceLabel = [[UILabel alloc]init];
        priceLabel.textColor = MainFontGrayColor;
        priceLabel.font = [UIFont systemFontOfSize:14];
        priceLabel.textAlignment = NSTextAlignmentRight;
        self.priceLabel = priceLabel;
        [self addSubview:priceLabel];
        
        //添加分割线
        UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 59, ScreenWidth, 1)];
        spliteLine.backgroundColor = MainLineGrayColor;
        [self addSubview:spliteLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.seriesLabel.frame = CGRectMake(SearchCellGap, SearchCellGap, ScreenWidth - 2 * SearchCellGap, 30);
    self.brandLabel.frame = CGRectMake(SearchCellGap, 35, 150, 20);
    self.priceLabel.frame = CGRectMake(ScreenWidth - 150 - SearchCellGap, 35, 150, 20);
}

- (void)setContentDict:(NSDictionary *)contentDict {
    _contentDict = contentDict;
    self.seriesLabel.text = contentDict[@"name"];
    self.brandLabel.text = contentDict[@"brandName"];
    self.priceLabel.text = contentDict[@"guidePrice"];
}

@end
