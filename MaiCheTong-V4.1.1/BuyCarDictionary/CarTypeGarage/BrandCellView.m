//
//  BrandCellView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-8.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "BrandCellView.h"
#import "UIImageView+WebCache.h"
#define NameLabelHeight 40
#define ImageWidth (self.width - NameLabelHeight - 10)


@interface BrandCellView()

@property (nonatomic,weak) UIImageView *imageView;

@property (nonatomic,weak) UILabel *nameLabel;
@end

@implementation BrandCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = MainWhiteColor;
        
        UIImageView *imageView = [[UIImageView alloc]init];
        self.imageView = imageView;
        [self addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        self.nameLabel = nameLabel;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:nameLabel];
        
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:dataDict[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load0"]];
    
    self.nameLabel.text = dataDict[@"name"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(NameLabelHeight * 0.5, 10, ImageWidth, ImageWidth);
    
//    MyLog(@"ImageWidth=%.2f",ImageWidth);
    self.nameLabel.frame = CGRectMake(5, self.height - NameLabelHeight, self.width - 5, NameLabelHeight);
    
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(brandCellViewClick:)]) {
        [self.delegate brandCellViewClick:self];
    }

}




@end
