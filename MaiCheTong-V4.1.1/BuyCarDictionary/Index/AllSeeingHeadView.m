//
//  HistoryHeadView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-2.
//  Copyright (c) 2014年 chexun. All rights reserved.
//



#import "AllSeeingHeadView.h"


@interface AllSeeingHeadView()
//@property (nonatomic,weak) UIImageView *iconImage;
@property (nonatomic,weak) UILabel *historyLabel;
@property (nonatomic,weak) UIImageView *indicatorImage;
@property (nonatomic,weak) UIView *spliteLine;
@property (nonatomic,weak) UIButton *moreBtn;

@end

@implementation AllSeeingHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = MainWhiteColor;
        
//        UIImageView *iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_home_historyicon"]];
//        iconImage.contentMode = UIViewContentModeCenter;
//        self.iconImage = iconImage;
//        [self addSubview:iconImage];
        
        UILabel *historyLabel = [[UILabel alloc]init];
        historyLabel.font = [UIFont systemFontOfSize:16];
        historyLabel.text = @"您可能喜欢的车型";
        self.historyLabel = historyLabel;
        [self addSubview:historyLabel];
        
        //更多的按钮
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [moreBtn setImage:[UIImage imageNamed:@"chexun_models_rightarroow"] forState:UIControlStateNormal];
        
        [moreBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.moreBtn = moreBtn;
        [self addSubview:moreBtn];
        
        //增加分割线
//        UIImageView *spliteLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_home_divider"]];
//        self.spliteLine = spliteLine;
//        [self addSubview:spliteLine];
        
        UIView *spliteLine = [[UIView alloc]init];
        spliteLine.backgroundColor = MainLineGrayColor;
        self.spliteLine = spliteLine;
        
        [self addSubview:spliteLine];
        
    }
    return self;
}

- (void)moreBtnClick {
    if ([self.delegate respondsToSelector:@selector(allSeeingHeadViewClick)]) {
        [self.delegate allSeeingHeadViewClick];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
//    self.iconImage.frame = CGRectMake(0, 0, self.width * 0.1, self.height - 1);
    self.historyLabel.frame = CGRectMake(5, 0, self.width * 0.4, self.height - 1);
    self.moreBtn.frame = CGRectMake(self.width * 0.5, 0, self.width * 0.48, self.height - 1);
    
    self.spliteLine.frame = CGRectMake(0, self.height - 1, self.width, 1);
}

@end
