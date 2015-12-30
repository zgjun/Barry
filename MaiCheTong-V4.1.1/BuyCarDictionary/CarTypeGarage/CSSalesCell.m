//
//  CSSalesCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CSSalesCell.h"
#import "HTTPHelper.h"
#import "UIImageView+WebCache.h"
#import "TimeTool.h"


#define CSSalesGap 10
#define ImageWidth 90
#define ImageHeight 60
@interface CSSalesCell()


@property (nonatomic,weak) UIImageView *iconImage;

@property (nonatomic,weak) UILabel *salesLabel;

@property (nonatomic,weak) UILabel *timeLabel;
@end

@implementation CSSalesCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        //创建子视图
        UIImageView *iconImage = [[UIImageView alloc]init];
        self.iconImage = iconImage;
        [self addSubview:iconImage];
        
        UILabel *salesLabel = [[UILabel alloc]init];
        salesLabel.textColor = MainBlackColor;
        salesLabel.numberOfLines = -1;
        salesLabel.font = [UIFont systemFontOfSize:16];
        self.salesLabel  = salesLabel;
        [self addSubview:salesLabel];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.textColor = MainFontGrayColor;
        timeLabel.font = [UIFont systemFontOfSize:14];
        self.timeLabel = timeLabel;
        [self addSubview:timeLabel];
    }
    return self;
}

- (void)setSalesDict:(NSDictionary *)salesDict {
    _salesDict = salesDict;
    
    
    NSString *titleString = [HTTPHelper StringDecode:salesDict[@"title"]];
    
    //设置内容
    NSString *urlStr = [NSString stringWithFormat:@"%@",salesDict[@"newsImg"]];
    
    
    urlStr =  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)urlStr, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"load1"]];
    
    //标题
    self.salesLabel.text = titleString;
    
    NSString *time = [NSString stringWithFormat:@"%@",salesDict[@"createtime"]];
    
    self.timeLabel.text = [TimeTool returnStringTime:time];
    
    //设置frame
    self.iconImage.frame = CGRectMake(10, CSSalesGap,ImageWidth , ImageHeight);
    
    CGSize titleMaxSize = CGSizeMake(ScreenWidth - 2 * CSSalesGap - ImageWidth, 60);
    NSString *titleStr = [NSString stringWithFormat:@"%@",titleString];
    NSDictionary *titleAttrs = @{NSFontAttributeName : self.salesLabel.font};
    CGSize titleSize = [titleStr boundingRectWithSize:titleMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:titleAttrs context:nil].size;
    self.salesLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImage.frame) + CSSalesGap,CSSalesGap, titleSize.width, titleSize.height);
    
    self.timeLabel.frame = CGRectMake(ScreenWidth - 80, 90 - 20 - 10, 80, 20);
}

//点击
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(cSSalesCellClick:)]) {
        [self.delegate cSSalesCellClick:self];
    }
}

@end
