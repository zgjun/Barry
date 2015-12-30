//
//  CSContentCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-6.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSContentCell.h"



#define CSContentCellGap 10
#define CSSpliteHeight 10
#define CSRowHeight ((self.height - CSSpliteHeight) / 3)

#define FouesImageHeight 10

@interface CSContentCell()

@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UILabel *speedBoxLabel;
@property (nonatomic,weak) UILabel *oilLabel;
@property (nonatomic,weak) UIView *priceView;
@property (nonatomic,weak) UILabel *priceLabel;
@property (nonatomic,weak) UILabel *lowPrice;
@property (nonatomic,weak) UILabel *fouesLabel;
@property (nonatomic,weak) UIView *fouesImageBg;
@property (nonatomic,weak) UIView *fouesImage;


@property (nonatomic,weak) UIView *bottomLine;
@property (nonatomic,weak) UIView *centerLine;

@end

@implementation CSContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = MainWhiteColor;
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.textColor = MainBlackColor;
        nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        
        UILabel *speedBoxLabel = [[UILabel alloc]init];
        speedBoxLabel.textAlignment = NSTextAlignmentLeft;
        speedBoxLabel.font = [UIFont systemFontOfSize:12];
        speedBoxLabel.textColor = MainFontGrayColor;
        self.speedBoxLabel = speedBoxLabel;
        [self addSubview:speedBoxLabel];
        
        UILabel *oilLabel = [[UILabel alloc]init];
        oilLabel.font = [UIFont systemFontOfSize:12];
        oilLabel.textAlignment = NSTextAlignmentRight;
        oilLabel.textColor = MainFontGrayColor;
        self.oilLabel = oilLabel;
        [self addSubview:oilLabel];
        
        //价格视图
        UIView *priceView = [[UIView alloc]init];
        priceView.backgroundColor = [UIColor clearColor];
        self.priceView = priceView;
        [self addSubview:priceView];
        
        
        UILabel *priceLabel = [[UILabel alloc]init];
        priceLabel.font = [UIFont systemFontOfSize:14];
        priceLabel.textAlignment = NSTextAlignmentLeft;
        priceLabel.textColor = MainFontGrayColor;
        self.priceLabel = priceLabel;
        [priceView addSubview:priceLabel];
        
        //价格之间的分割线
        UIView *centerLine = [[UIView alloc]init];
        self.centerLine = centerLine;
        centerLine.backgroundColor = MainFontGrayColor;
        [priceView addSubview:centerLine];
        
        UILabel *lowPrice = [[UILabel alloc]init];
        lowPrice.font = [UIFont systemFontOfSize:14];
        lowPrice.textColor = MainFontRedColor;
        lowPrice.textAlignment = NSTextAlignmentLeft;
        self.lowPrice = lowPrice;
        [priceView addSubview:lowPrice];
        
        
        UILabel *fouesLabel = [[UILabel alloc]init];
        fouesLabel.font = [UIFont systemFontOfSize:12];
        fouesLabel.textColor = MainFontGrayColor;
        self.fouesLabel = fouesLabel;
        [self addSubview:fouesLabel];
        
        UIView *fouesImageBg = [[UIView alloc]init];
        fouesImageBg.backgroundColor = MainLineGrayColor;
        self.fouesImageBg = fouesImageBg;
        [self addSubview:fouesImageBg];
        
        UIView *fouesImage = [[UIView alloc]init];
        fouesImage.backgroundColor = MainGoldenColor;
        self.fouesImage = fouesImage;
        [self addSubview:fouesImage];
        
        //分割线
        NSString *backgroudpath = [[NSBundle mainBundle] pathForResource:@"chexun_dotted-line" ofType:@"png"];
        
        
        UIView *bottomLine = [[UIView alloc]init];
        
        UIImage  *backgroudImage = [UIImage imageWithContentsOfFile:backgroudpath];
        bottomLine.backgroundColor=[UIColor colorWithPatternImage:backgroudImage] ;
        self.bottomLine = bottomLine;
        [self addSubview:bottomLine];
    }
    return self;
}

- (void)setCellDict:(NSDictionary *)cellDict {
    _cellDict = cellDict;
    
    
    NSString *nameStr = [NSString stringWithFormat:@"%@ %@",cellDict[@"yearName"],cellDict[@"name"]];
    
    self.nameLabel.text = nameStr;
    self.speedBoxLabel.text = cellDict[@"speedBox"];
    self.oilLabel.text = [NSString stringWithFormat:@"工信部油耗：%.1f",[cellDict[@"combinedConsumption"] floatValue]];
    
    self.fouesLabel.text = @"关注度";
    
    self.priceView.frame = CGRectMake(ScreenWidth - 5 - 130, 40, 130, 40);
    
    
    
    NSString *priceStr = [NSString stringWithFormat:@"%.2f万",[cellDict[@"guidePrice"] floatValue]];
    CGSize priceMaxSize = CGSizeMake(130, 40);
    NSDictionary *priceAttrs = @{NSFontAttributeName : self.priceLabel.font};
    CGSize priceSize = [priceStr boundingRectWithSize:priceMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:priceAttrs context:nil].size;
    self.priceLabel.frame = CGRectMake(0, 0, priceSize.width, 40);
    
    //分割线的frame
    self.centerLine.frame = CGRectMake(CGRectGetMaxX(self.priceLabel.frame) + 2, (40 - priceSize.height) * 0.5, 1, priceSize.height);
    
    
    NSString *lowPriceStr = [NSString stringWithFormat:@"%.2f万",[cellDict[@"MinPrice"] floatValue]];
    
    CGSize lowPriceMaxSize = CGSizeMake(130, 40);
    
    NSDictionary *lowPriceAttrs = @{NSFontAttributeName : self.lowPrice.font};
    CGSize lowPriceSize = [lowPriceStr boundingRectWithSize:lowPriceMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:lowPriceAttrs context:nil].size;
    self.lowPrice.frame = CGRectMake(CGRectGetMaxX(self.centerLine.frame) + 2, 0, lowPriceSize.width, self.priceView.height);
    
    self.priceLabel.text = priceStr;
    self.lowPrice.text = lowPriceStr;
    
    CGFloat yhPrice = [cellDict[@"guidePrice"] floatValue] - [cellDict[@"MinPrice"] floatValue];
    if (yhPrice <= 0.01 || [cellDict[@"MinPrice"] floatValue] == 0) {
        self.lowPrice.hidden = YES;
        self.centerLine.hidden = YES;
    } else {
        self.lowPrice.hidden = NO;
        self.centerLine.hidden = NO;
    }
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bottomLine.frame = CGRectMake(0, self.height - 1, ScreenWidth, 1);
    
    self.nameLabel.frame = CGRectMake(CSContentCellGap, CSSpliteHeight, self.width - CSContentCellGap, CSRowHeight);
    
    self.speedBoxLabel.frame = CGRectMake(CSContentCellGap, CGRectGetMaxY(self.nameLabel.frame), 50, CSRowHeight);
    
    self.oilLabel.frame = CGRectMake(CGRectGetMaxX(self.speedBoxLabel.frame), CGRectGetMaxY(self.nameLabel.frame), 100, CSRowHeight);
    
//    self.priceLabel.frame = CGRectMake(CGRectGetMaxX(self.oilLabel.frame), CGRectGetMaxY(self.nameLabel.frame), self.width / 3 - CSContentCellGap, CSRowHeight);
    
    self.fouesLabel.frame = CGRectMake(CSContentCellGap, CGRectGetMaxY(self.speedBoxLabel.frame), 40, CSRowHeight);
    
    self.fouesImageBg.frame = CGRectMake(CGRectGetMaxX(self.fouesLabel.frame) + CSContentCellGap, CGRectGetMaxY(self.speedBoxLabel.frame) + (CSRowHeight - 5) * 0.5 ,120, 5);
    
    CGFloat fouesImageW = [self.cellDict[@"pvCount"] integerValue] * 1.5;
    
    
    self.fouesImage.frame = CGRectMake(CGRectGetMaxX(self.fouesLabel.frame) + CSContentCellGap, CGRectGetMaxY(self.speedBoxLabel.frame) + (CSRowHeight - 5) * 0.5 ,fouesImageW, 5);
    
//    self.lowPrice.frame = CGRectMake(CGRectGetMaxX(self.fouesImageBg.frame), CGRectGetMaxY(self.speedBoxLabel.frame),self.width / 3 - CSContentCellGap, CSRowHeight);
    
    
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //通知代理切换控制器
    if ([self.delegate respondsToSelector:@selector(cSContentCellClick:)]) {
        [self.delegate cSContentCellClick:self];
    }
}

@end
