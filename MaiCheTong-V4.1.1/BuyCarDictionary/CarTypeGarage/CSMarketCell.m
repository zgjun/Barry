//
//  CSMarketCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSMarketCell.h"
#import "TimeTool.h"
#import "UIImage+Extension.h"

#define CSMarketGap 10
#define SpliteViewHeight 10

@interface CSMarketCell()
@property (nonatomic,weak) UIView *bottomLine;
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *timeLabel;
@property (nonatomic,weak) UILabel *companyLabel;
@end

@implementation CSMarketCell

- (instancetype)initWithLineType:(NSInteger)lineType {
    if (self = [super init]) {
        //创建子视图
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.numberOfLines = 2; 
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        
        UILabel *companyLabel = [[UILabel alloc]init];
        companyLabel.font = [UIFont systemFontOfSize:16];
        self.companyLabel = companyLabel;
        companyLabel.hidden = YES;
        [self addSubview:companyLabel];
        
        UILabel *timeLabel = [[UILabel alloc]init];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = MainFontGrayColor;
        timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel = timeLabel;
        [self addSubview:timeLabel];
        if (lineType == 0) {
            //分割线
            NSString *backgroudpath = [[NSBundle mainBundle] pathForResource:@"chexun_dotted-line" ofType:@"png"];
            
            UIView *bottomLine = [[UIView alloc]init];
            
            UIImage  *backgroudImage = [UIImage imageWithContentsOfFile:backgroudpath];
            bottomLine.backgroundColor=[UIColor colorWithPatternImage:backgroudImage] ;
            self.bottomLine = bottomLine;
            [self addSubview:bottomLine];
        } else {
            UIView *bottomLine = [[UIView alloc]init];
            bottomLine.backgroundColor = MainLineGrayColor;
            self.bottomLine = bottomLine;
            [self addSubview:bottomLine];
        }
    }
    return self;
}

- (void)setMarketDict:(NSDictionary *)marketDict {
    _marketDict = marketDict;
    
    NSDictionary *attrs = @{NSFontAttributeName : self.titleLabel.font};
    CGSize titleSize = [marketDict[@"title"] boundingRectWithSize:CGSizeMake(ScreenWidth - 2 * CSMarketGap, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    self.titleLabel.frame = CGRectMake(CSMarketGap, CSMarketGap, titleSize.width, titleSize.height);
    self.companyLabel.frame = CGRectMake(CSMarketGap, (200 / 3) - 30 - CSMarketGap, ScreenWidth - 2 * CSMarketGap - 80, 30);
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.companyLabel.frame), (200 / 3) - 30 - 5, 80, 30);
    
    self.titleLabel.text = marketDict[@"title"];
    
    self.timeLabel.text = [TimeTool returnSampleTime:marketDict[@"time"]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bottomLine.frame = CGRectMake(0, self.height -  1, ScreenWidth, 1);
}

@end
