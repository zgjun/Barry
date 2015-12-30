//
//  ContainerView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-27.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "ContainerView.h"
#import "UIImageView+WebCache.h"
#define SelfWidth self.bounds.size.width
#define SelfHeight self.bounds.size.height
#define ContainerViewGap 10


@interface ContainerView()
@property (nonatomic,weak) UIImageView *iconView;
@property (nonatomic,weak) UILabel *nameLabel;



@end

@implementation ContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //设置图标
        UIImageView *iconView = [[UIImageView alloc]init];
        self.iconView = iconView;
        [self addSubview:iconView];
        
        //设置名称
        UILabel *nameLabel = [[UILabel alloc]init];
        self.nameLabel = nameLabel;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake(SelfHeight * 0.2, 0, SelfHeight * 0.6, SelfHeight * 0.6);
    
    self.nameLabel.frame = CGRectMake(0, self.iconView.bounds.size.height, SelfWidth, SelfHeight * 0.4);
}


- (void)setBrandsInfo:(NSDictionary *)brandsInfo {
    _brandsInfo = brandsInfo;
    
    self.nameLabel.text = brandsInfo[@"brandName"];
    
    [self.iconView sd_setImageWithURL:brandsInfo[@"logo"] placeholderImage:[UIImage imageNamed:@"load0"]];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //发出通知让控制器来modal
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BrandContainerClick" object:self.brandsInfo];
}


@end
