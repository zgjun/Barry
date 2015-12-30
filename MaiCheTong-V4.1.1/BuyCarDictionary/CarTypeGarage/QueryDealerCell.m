//
//  QueryDealerCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "QueryDealerCell.h"
#import "HTTPHelper.h"
#define QueryDealerGap 10
#define SmallBtnSide 40

@interface QueryDealerCell()

@property (nonatomic,weak) UIImageView *fourSImage;
@property (nonatomic,weak) UILabel *dealerNameLabel;
@property (nonatomic,weak) UILabel *soldRangeLabel;
@property (nonatomic,weak) UILabel *addressLabel;
@property (nonatomic,weak) UIButton *compareBtn;
@end

@implementation QueryDealerCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *fourSImage = [[UIImageView alloc]init];
        self.fourSImage = fourSImage;
        [self addSubview:fourSImage];
        
        UILabel *dealerNameLabel = [[UILabel alloc]init];
        dealerNameLabel.font = [UIFont systemFontOfSize:16];
        dealerNameLabel.textColor = MainBlackColor;
        self.dealerNameLabel = dealerNameLabel;
        [self addSubview:dealerNameLabel];
        
        UILabel *soldRangeLabel = [[UILabel alloc]init];
        soldRangeLabel.font = [UIFont systemFontOfSize:12];
        soldRangeLabel.textColor = MainFontGrayColor;
        self.soldRangeLabel = soldRangeLabel;
        [self addSubview:soldRangeLabel];
        
        UILabel *addressLabel = [[UILabel alloc]init];
        addressLabel.numberOfLines = -1;
        addressLabel.textColor = MainFontGrayColor;
        addressLabel.font = [UIFont systemFontOfSize:12];
        self.addressLabel = addressLabel;
        [self addSubview:addressLabel];
        
        UIButton *compareBtn = [[UIButton alloc]init];
        [compareBtn setBackgroundImage:[UIImage imageNamed:@"chexun_cancelbut"] forState:UIControlStateNormal];
        [compareBtn setBackgroundImage:[UIImage imageNamed:@"chexun_selectedbut"] forState:UIControlStateSelected];
        self.compareBtn = compareBtn;
        [compareBtn addTarget:self action:@selector(compareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:compareBtn];
    }
    return self;
}


- (void)setQueryDict:(NSMutableDictionary *)queryDict {
    _queryDict = queryDict;
    
    if ([queryDict[@"isMemberUser"] integerValue] == 1) {
        self.compareBtn.selected = YES;
    } else {
        self.compareBtn.selected = NO;
    }
    
    if ([queryDict[@"companyType"] integerValue] == 0) {
        self.fourSImage.hidden = YES;
        CGSize dealerMaxSize = CGSizeMake(ScreenWidth * 0.6, MAXFLOAT);
        NSDictionary *dealerAttrs = @{NSFontAttributeName : self.dealerNameLabel.font};
        CGSize dealerSize = [queryDict[@"dealerShortName"] boundingRectWithSize:dealerMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dealerAttrs context:nil].size;
        self.dealerNameLabel.frame = CGRectMake(QueryDealerGap,QueryDealerGap, dealerSize.width, dealerSize.height);
        
        self.soldRangeLabel.frame = CGRectMake(ScreenWidth * 0.6, QueryDealerGap, 40, self.dealerNameLabel.height);
        self.compareBtn.frame = CGRectMake(ScreenWidth - QueryDealerGap - SmallBtnSide, (70 - SmallBtnSide) * 0.5, SmallBtnSide, SmallBtnSide);
        
    } else {
        self.fourSImage.hidden = NO;
        self.fourSImage.frame = CGRectMake(QueryDealerGap, QueryDealerGap + 3, 18, 14);
        
        CGSize dealerMaxSize = CGSizeMake(ScreenWidth * 0.6, MAXFLOAT);
        NSDictionary *dealerAttrs = @{NSFontAttributeName : self.dealerNameLabel.font};
        CGSize dealerSize = [queryDict[@"dealerShortName"] boundingRectWithSize:dealerMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dealerAttrs context:nil].size;
        self.dealerNameLabel.frame = CGRectMake(CGRectGetMaxX(self.fourSImage.frame) + QueryDealerGap,QueryDealerGap, dealerSize.width, dealerSize.height);
        
        self.soldRangeLabel.frame = CGRectMake(ScreenWidth * 0.6, QueryDealerGap, 40, self.dealerNameLabel.height);
        
        self.compareBtn.frame = CGRectMake(ScreenWidth - QueryDealerGap - SmallBtnSide, (70 - SmallBtnSide) * 0.5, SmallBtnSide, SmallBtnSide);
    }
    
    //地址
    NSString *addressString = [HTTPHelper StringDecode:queryDict[@"companyAddress"]];
    
    CGSize addressMaxSize = CGSizeMake(ScreenWidth - 2 * QueryDealerGap - SmallBtnSide, MAXFLOAT);
    NSString *addressStr = [NSString stringWithFormat:@"地址：%@",addressString];
    NSDictionary *addressAttrs = @{NSFontAttributeName : self.addressLabel.font};
    CGSize addressSize = [addressStr boundingRectWithSize:addressMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:addressAttrs context:nil].size;
    
    self.addressLabel.frame = CGRectMake(QueryDealerGap,CGRectGetMaxY(self.dealerNameLabel.frame) + QueryDealerGap, addressSize.width, addressSize.height);
    
    self.dealerNameLabel.text = queryDict[@"dealerShortName"];
    self.fourSImage.image = [UIImage imageNamed:@"chexun_4sicon"];
    self.soldRangeLabel.text = @"售全国";
    self.addressLabel.text = addressStr;
    
}

///经销商选中按钮
- (void)compareBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    [self.queryDict setObject:@(btn.selected) forKey:@"isMemberUser"];
    
    
    //通知代理来改变点击的状态
    if ([self.delegate respondsToSelector:@selector(queryCellClick:QueryBtn:)]) {
        [self.delegate queryCellClick:self QueryBtn:btn];
    }
}

@end
