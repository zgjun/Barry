//
//  CanBuyCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CanBuyCell.h"
#import "UIImageView+WebCache.h"


#define CompareGap 10
#define SmallBtnSide 40

@interface CanBuyCell()
@property (nonatomic,weak) UIImageView *canBuyIcon;
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *priceLabel;
@property (nonatomic,weak) UIView *seperateLine;
@property (nonatomic,weak) UIButton *canBuyBtn;

@property (nonatomic,assign) NSInteger selectCount;

@end

@implementation CanBuyCell

- (instancetype)initWithSelectCount:(NSInteger)selectCount {
    if (self = [super init]) {
        self.selectCount = selectCount;
        
        //头像
        UIImageView *canBuyIcon = [[UIImageView alloc]init];
        self.canBuyIcon = canBuyIcon;
        [self addSubview:canBuyIcon];
        
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textColor = MainBlackColor;
        titleLabel.numberOfLines = -1;
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        
        UILabel *priceLabel = [[UILabel alloc]init];
        self.priceLabel = priceLabel;
        priceLabel.textColor = MainFontGrayColor;
        [self addSubview:priceLabel];
        
        UIButton *canBuyBtn = [[UIButton alloc]init];
        
        [canBuyBtn setBackgroundImage:[UIImage imageNamed:@"chexun_cancelbut"] forState:UIControlStateNormal];
        [canBuyBtn setBackgroundImage:[UIImage imageNamed:@"chexun_selectedbut"] forState:UIControlStateSelected];
        [canBuyBtn setBackgroundImage:[UIImage imageNamed:@"chexun_cancelbut"] forState:UIControlStateDisabled];
        self.canBuyBtn = canBuyBtn;
        [canBuyBtn addTarget:self action:@selector(canBuyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:canBuyBtn];
        
        UIView *seperateLine = [[UIView alloc]init];
        seperateLine.backgroundColor = MainLineGrayColor;
        self.seperateLine = seperateLine;
        
        [self addSubview:seperateLine];
    }
    return self;
}


- (void)canBuyBtnClick:(UIButton *)btn {
    
    if (self.selectCount >= 10 && btn.selected == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"亲，请注意" message:@"最多只能添加10款车进行对比选择" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    btn.selected = !btn.selected;
    
    self.isSelected = !self.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(canBuyCellClick:)]) {
        [self.delegate canBuyCellClick:self];
    }
}

- (void)setIsSelected:(NSInteger)isSelected {
    _isSelected = isSelected;
    
    self.canBuyBtn.selected = self.isSelected;
}

- (void)setCanBuyDict:(NSDictionary *)canBuyDict {
    _canBuyDict = canBuyDict;
    
    
    [self.canBuyIcon sd_setImageWithURL:[NSURL URLWithString:canBuyDict[@"carTypeImage"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    
    NSString *title = [NSString stringWithFormat:@"%@ %@",canBuyDict[@"carSeriesName"],canBuyDict[@"carTypeName"]];
    
    self.titleLabel.text = title;
    
    self.priceLabel.text =  [NSString stringWithFormat:@"%.2f万元",[canBuyDict[@"carTypePrice"] floatValue]];
    
    
    //设置frame
    
    
    self.canBuyIcon.frame = CGRectMake(0, CompareGap * 0.5, 80, 60);
    
    CGSize titleMaxSize = CGSizeMake(ScreenWidth - 2 * CompareGap - 80 - 40, MAXFLOAT);
    
    NSDictionary *titleAttrs = @{NSFontAttributeName : self.titleLabel.font};
    
    CGSize titleSize = [title boundingRectWithSize:titleMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:titleAttrs context:nil].size;
    
    self.titleLabel.frame = CGRectMake(80 + CompareGap,5, titleSize.width, titleSize.height);
    
//    self.titleLabel.frame = CGRectMake(80 + CompareGap, 0, ScreenWidth - 80 - 40 - CompareGap, 30);
    
    self.priceLabel.frame = CGRectMake(80 + CompareGap, CGRectGetMaxY(self.titleLabel.frame), 100, 30);
    
    self.canBuyBtn.frame = CGRectMake(ScreenWidth - CompareGap - SmallBtnSide, (70 - SmallBtnSide) * 0.5, SmallBtnSide, SmallBtnSide);
    
    self.seperateLine.frame = CGRectMake(0, 70, ScreenWidth, 1);
    
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    
}

@end
