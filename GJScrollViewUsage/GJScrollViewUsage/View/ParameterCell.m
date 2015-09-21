//
//  ParameterCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-29.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "ParameterCell.h"


@interface ParameterCell()
@property (nonatomic,weak) UILabel *showTitle;
@property (nonatomic,weak) UIView *rightLine;
@property (nonatomic,weak) UIView *bottomLine;

@property (nonatomic,strong) NSString *indicator;
@end

@implementation ParameterCell

- (instancetype)initWithFrame:(CGRect)frame indicator:(NSString *)indicator {
    if (self = [super initWithFrame:frame]) {
        self.indicator = indicator;
        //create child views
        UILabel *showTitle = [[UILabel alloc]init];
        showTitle.textAlignment = NSTextAlignmentCenter;
        showTitle.font = [UIFont systemFontOfSize:12];
        showTitle.numberOfLines = -1;
        self.showTitle = showTitle;
        [self addSubview:showTitle];
        //the right vertical line
        UIView *rightLine = [[UIView alloc]init];
        rightLine.backgroundColor = MainBackGroundColor;
        self.rightLine = rightLine;
        [self addSubview:rightLine];
        //the bottom line
        UIView *bottomLine = [[UIView alloc]init];
        bottomLine.backgroundColor = MainBackGroundColor;
        self.bottomLine = bottomLine;
        [self addSubview:bottomLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.showTitle.frame = CGRectMake(0, 0, self.width, self.height);
    self.rightLine.frame = CGRectMake(self.width - 1, 0, 1, self.height);
    self.bottomLine.frame = CGRectMake(0, self.height - 1, self.width, 1);
    
}

- (void)setContentStr:(NSString *)contentStr {
    _contentStr = contentStr;
    self.showTitle.text = contentStr;
    
    CGFloat tipLabelX = 0;
    
    CGFloat tipLabelY = 0;
    
    CGSize maxSize = CGSizeMake(self.width, MAXFLOAT);
    
    CGSize tipLabelSize = [contentStr sizeWithFont:self.showTitle.font constrainedToSize:maxSize];
    
    self.showTitle.frame = (CGRect){{tipLabelX,tipLabelY},tipLabelSize};
}

- (void)setIsAll:(BOOL)isAll {
    _isAll = isAll;
    if (_isAll == YES) {
        self.showTitle.textColor = MainGoldenColor;
    } else {
        self.showTitle.textColor = [UIColor blackColor];
    }
    
    if ([self.indicator isEqualToString:@"title"]) {
        self.showTitle.textColor = [UIColor blackColor];
    }
    
}

@end
