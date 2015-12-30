//
//  CompareCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CompareCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+Deal.h"


#define CompareGap 10
#define SmallBtnSide 40

@interface CompareCell()
@property (nonatomic,weak) UIImageView *compareIcon;
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *guidePriceLabel;
//@property (nonatomic,weak) UILabel *lowPriceLabel;
//@property (nonatomic,weak) UILabel *reducePriceLabel;
@property (nonatomic,weak) UIView *seperateLine;
@property (nonatomic,weak) UIButton *compareBtn;

@property (nonatomic,assign) NSInteger selectCount;
@end

@implementation CompareCell

- (instancetype)initWithSelectCount:(NSInteger)selectCount {
    if (self = [super init]) {
        self.selectCount = selectCount;
        
        //头像
        UIImageView *compareIcon = [[UIImageView alloc]init];
        self.compareIcon = compareIcon;
        [self addSubview:compareIcon];
        
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.numberOfLines = -1;
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        
        //降价
//        UILabel *reducePriceLabel = [[UILabel alloc]init];
//        reducePriceLabel.font = [UIFont systemFontOfSize:12];
//        reducePriceLabel.textColor = MainFontGrayColor;
//        self.reducePriceLabel = reducePriceLabel;
//        [self addSubview:reducePriceLabel];
//        
//        //最低价
//        UILabel *lowPriceLabel = [[UILabel alloc]init];
//        lowPriceLabel.font = [UIFont systemFontOfSize:12];
//        lowPriceLabel.textColor = MainFontRedColor;
//        self.lowPriceLabel = lowPriceLabel;
//        [self addSubview:lowPriceLabel];
        
        //指导价
        UILabel *guidePriceLabel = [[UILabel alloc]init];
        guidePriceLabel.font = [UIFont systemFontOfSize:12];
        guidePriceLabel.textColor = MainFontGrayColor;
        self.guidePriceLabel = guidePriceLabel;
        [self addSubview:guidePriceLabel];
        
        UIButton *compareBtn = [[UIButton alloc]init];
        
        [compareBtn setBackgroundImage:[UIImage imageNamed:@"chexun_cancelbut"] forState:UIControlStateNormal];
        [compareBtn setBackgroundImage:[UIImage imageNamed:@"chexun_selectedbut"] forState:UIControlStateSelected];
        self.compareBtn = compareBtn;
        [compareBtn addTarget:self action:@selector(compareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:compareBtn];
        
        //分割线
        UIView *seperateLine = [[UIView alloc]init];
        seperateLine.backgroundColor = MainLineGrayColor;
        self.seperateLine = seperateLine;
        
        [self addSubview:seperateLine];
    }
    return self;
}


- (void)compareBtnClick:(UIButton *)btn {
    if (self.selectCount >= 5 && btn.selected == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"亲，请注意" message:@"最多只能选择5款车同时进行对比" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    btn.selected = !btn.selected;
    
    self.isSelected = btn.selected;
    
    //通知代理来改变点击的状态
    if ([self.delegate respondsToSelector:@selector(compareCellClick:)]) {
        [self.delegate compareCellClick:self];
    }
}

- (void)setIsSelected:(NSInteger)isSelected {
    _isSelected = isSelected;
    self.compareBtn.selected = isSelected;
}

- (void)setCompareDict:(NSDictionary *)compareDict {
    _compareDict = compareDict;
    
    [self.compareIcon sd_setImageWithURL:[NSURL URLWithString:compareDict[@"carTypeImage"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    
    id seriesName = compareDict[@"carSeriesName"];
    NSString *seriesNameStr = (seriesName != nil) ? seriesName : @"";
    
    NSString *title;
    if (seriesNameStr.length == 0) {
        title = [NSString stringWithFormat:@"%@",compareDict[@"carTypeName"]];
    } else {
        title = [NSString stringWithFormat:@"%@ %@",compareDict[@"carSeriesName"],compareDict[@"carTypeName"]];
    }
    
    self.titleLabel.text = title;
    
    
    self.guidePriceLabel.text = [NSString stringWithFormat:@"%.2f万",[compareDict[@"carTypePrice"] floatValue]];
    
//    self.lowPriceLabel.text = [NSString stringWithFormat:@"%.2f万",[compareDict[@"carTypeLowPrice"] floatValue]];
//    
//    if ([compareDict[@"carTypePrice"] floatValue] == [compareDict[@"carTypeLowPrice"] floatValue]) {
//        self.reducePriceLabel.hidden = YES;
//        self.reducePriceLabel.text = [NSString stringWithFormat:@"0万"];
//    } else {
//        self.reducePriceLabel.hidden = NO;
//        CGFloat redeuceValue = [compareDict[@"carTypePrice"] floatValue] - [compareDict[@"carTypeLowPrice"] floatValue];
//        self.reducePriceLabel.text = [NSString stringWithFormat:@"降%.2f万",redeuceValue];
//        
//    }
    
    
    //设置frame
    self.compareIcon.frame = CGRectMake(0, CompareGap * 0.5, 80, 60);
    
//    self.titleLabel.frame = CGRectMake(80 + CompareGap, 5, ScreenWidth - 80 - 40 - CompareGap, 30);
    
    CGSize titleMaxSize = CGSizeMake(ScreenWidth - 2 * CompareGap - 80 - 40, 50);
    
    NSDictionary *titleAttrs = @{NSFontAttributeName : self.titleLabel.font};
    
    CGSize titleSize = [title boundingRectWithSize:titleMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:titleAttrs context:nil].size;
    
    self.titleLabel.frame = CGRectMake(80 + CompareGap,5, titleSize.width, titleSize.height);
    
    
//    self.reducePriceLabel.frame = CGRectMake(80 + CompareGap, CGRectGetMaxY(self.titleLabel.frame), 80, 30);
    
    self.guidePriceLabel.frame = CGRectMake(80 + CompareGap,  CGRectGetMaxY(self.titleLabel.frame), 60, 30);
    
//    self.lowPriceLabel.frame = CGRectMake(CGRectGetMaxX(self.guidePriceLabel.frame),  CGRectGetMaxY(self.titleLabel.frame), 60, 30);
    self.compareBtn.frame = CGRectMake(ScreenWidth - CompareGap - SmallBtnSide, (70 - SmallBtnSide) * 0.5, SmallBtnSide, SmallBtnSide);
    
    self.seperateLine.frame = CGRectMake(0, 70, ScreenWidth, 1);
}



@end
