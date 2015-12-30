//
//  GuideContentCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-17.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "GuideContentCell.h"
#import "UIImageView+WebCache.h"
#import "TimeTool.h"
#define IconWidth 110
#define IconHeight 80


@interface GuideContentCell()
@property (nonatomic,weak) UIImageView *icon;
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *timeLabel;
@property (nonatomic,weak) UIView *bottomLine;
@end

@implementation GuideContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *icon = [[UIImageView alloc]init];
        self.icon = icon;
        [self addSubview:icon];
        
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = MainBlackColor;
        titleLabel.numberOfLines = -1;
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        
        UILabel *timeLabel = [[UILabel alloc]init];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.textColor = MainFontGrayColor;
        timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel = timeLabel;
        [self addSubview:timeLabel];
        
        //下面的竖线
        UIView *bottomLine = [[UIView alloc]init];
        bottomLine.backgroundColor = MainBackGroundColor;
        self.bottomLine = bottomLine;
        [self addSubview:bottomLine];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.icon.frame = CGRectMake(0, 0, IconWidth, IconHeight);
    
    self.timeLabel.frame = CGRectMake(IconWidth + 10, self.height - 30, ScreenWidth - IconWidth - 30, 20);
    
    self.bottomLine.frame = CGRectMake(0, self.height - 1, self.width, 1);
    
    
}

- (void)setContentDict:(NSDictionary *)contentDict {
    _contentDict = contentDict;
    CGFloat titleLabelX = IconWidth + 10;
    
    CGFloat titleLabelY = 10;
    
    CGSize maxSize = CGSizeMake(self.width - IconWidth - 15, MAXFLOAT);
    
    NSDictionary *attrs = @{NSFontAttributeName : self.titleLabel.font};
    CGSize titleSize = [contentDict[@"title"] boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    self.titleLabel.frame = (CGRect){{titleLabelX,titleLabelY},titleSize};
    
    
    [self.icon sd_setImageWithURL:[NSURL URLWithString:contentDict[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    
    self.titleLabel.text = contentDict[@"title"];
    
    self.timeLabel.text = contentDict[@"date"];
    
    
//    self.timeLabel.text = [TimeTool returnSampleTime:contentDict[@"date"]];
    
    
    
    
    
}

@end
