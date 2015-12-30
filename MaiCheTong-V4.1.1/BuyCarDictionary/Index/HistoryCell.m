//
//  HistoryCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//
#import "HistoryCell.h"
#import "UIImageView+WebCache.h"


#define HistoryIconWidth 90
#define HistoryIconHeight 60

#define CompareGap 10
#define SmallBtnSide 20

@interface HistoryCell()
@property (nonatomic,weak) UIImageView *historyCellIcon;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UIView *priceView;
@property (nonatomic,weak) UILabel *priceLabel;
@property (nonatomic,weak) UIView *reducePriceView;
@property (nonatomic,weak) UIImageView *arrowImage;
@property (nonatomic,weak) UILabel *reducePriceLabel;
@property (nonatomic,weak) UIView *seperateLine;
@end


@implementation HistoryCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //头像
        UIImageView *historyCellIcon = [[UIImageView alloc]init];
        self.historyCellIcon = historyCellIcon;
        [self addSubview:historyCellIcon];
        
        //名字label
        UILabel *nameLabel = [[UILabel alloc]init];
        
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = MainBlackColor;
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        //价格view
        UIView *priceView = [[UIView alloc]init];
        
        priceView.contentMode = UIViewContentModeLeft;
        
        self.priceView = priceView;
        [self addSubview:priceView];
        
        UILabel *priceLabel = [[UILabel alloc]init];
        priceLabel.textAlignment = NSTextAlignmentLeft;
        priceLabel.font = [UIFont systemFontOfSize:16];
        priceLabel.textColor = MainFontGrayColor;
        self.priceLabel = priceLabel;;
        [priceView addSubview:priceLabel];
        
        
        //降价view
        UIView *reducePriceView = [[UIView alloc]init];
        reducePriceView.contentMode = UIViewContentModeLeft;
        self.reducePriceView = reducePriceView;
        [priceView addSubview:reducePriceView];
        
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
        
        
        //分割线
        
        UIView *seperateLine = [[UIView alloc]init];
        seperateLine.backgroundColor = MainLineGrayColor;
        self.seperateLine = seperateLine;
        
        [self addSubview:seperateLine];
    }
    return self;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(historyCellClick:)]) {
        [self.delegate historyCellClick:self];
    }
}


- (void)setHistoryCellDict:(NSDictionary *)historyCellDict {
    _historyCellDict = historyCellDict;
    
    self.historyCellIcon.frame = CGRectMake(0, 5, HistoryIconWidth, HistoryIconHeight);
    
    self.nameLabel.frame = CGRectMake(HistoryIconWidth + CompareGap, 0, ScreenWidth - HistoryIconWidth, HistoryIconWidth * 0.5);
    
    [self.historyCellIcon sd_setImageWithURL:[NSURL URLWithString:historyCellDict[@"imgPath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    
    self.nameLabel.text = historyCellDict[@"name"];
    self.priceLabel.text = historyCellDict[@"guidePrice"];
    self.priceView.frame = CGRectMake(HistoryIconWidth + CompareGap, self.height * 0.5, self.width - HistoryIconWidth, self.height * 0.5);
    
    NSDictionary *attrs = @{NSFontAttributeName : self.priceLabel.font};
    CGFloat priceLabelW = [historyCellDict[@"guidePrice"] boundingRectWithSize:CGSizeMake(self.width * 0.8, self.priceLabel.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.width;
    
    self.priceLabel.frame = CGRectMake(0, 0, priceLabelW, self.priceView.height);
    
    self.reducePriceView.frame = CGRectMake(self.priceLabel.width, 0, self.priceView.width * 0.3 , self.priceView.height);
    
    
    self.arrowImage.frame = CGRectMake(CompareGap, self.reducePriceView.height - 15 - 10, 20, 15);
    
    self.reducePriceLabel.frame = CGRectMake(CGRectGetMaxX(self.arrowImage.frame), 0,self.reducePriceView.width * 0.9 , self.reducePriceView.height);
    
    self.seperateLine.frame = CGRectMake(0, self.height - 1, ScreenWidth, 1);
    self.reducePriceLabel.text = [NSString stringWithFormat:@"%@",historyCellDict[@"hq"]];
    
    NSString *str = [NSString stringWithFormat:@"%@",historyCellDict[@"hq"]];
    
    //判断字典里面返回的为空值
    if (str.length <= 0 || str == nil || str == NULL || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || historyCellDict[@"hq"] == nil) {
        self.arrowImage.hidden = YES;
        self.reducePriceLabel.hidden = YES;
    } else {
        self.arrowImage.hidden = NO;
        self.reducePriceLabel.hidden = NO;
        self.arrowImage.image = [UIImage imageNamed:@"chexun_sale"];
    }
    
}


@end
