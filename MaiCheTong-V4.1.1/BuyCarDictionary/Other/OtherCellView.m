//
//  OtherCellView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-15.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "OtherCellView.h"

#define UpLeftGap 25
#define WidthAndHeight 50
#define NameLabelHeight 30

@interface OtherCellView()
@property (nonatomic,weak) UIImageView *imageView;
@property (nonatomic,weak) UILabel *nameLabel;
@end

@implementation OtherCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc]init];
        self.imageView = imageView;
        [self addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = MainFontGrayColor;
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
    }
    return self;
}

- (void)setDataInfo:(NSDictionary *)dataInfo {
    _dataInfo = dataInfo;
    self.imageView.image = [UIImage imageNamed:dataInfo[@"iconName"]];
    
    self.nameLabel.text = dataInfo[@"name"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake((self.width - WidthAndHeight) * 0.5, UpLeftGap, WidthAndHeight, WidthAndHeight);
    
    self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame), self.width, NameLabelHeight);
    
}
@end
