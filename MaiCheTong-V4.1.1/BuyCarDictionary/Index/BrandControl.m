//
//  BrandControl.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-2.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "BrandControl.h"

@interface BrandControl()
@property (nonatomic,strong) UIImage *activeImage;
@property (nonatomic,strong) UIImage *inactiveImage;
@end

@implementation BrandControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.activeImage = [UIImage imageNamed:@"chexun_home_pricebut"] ;
        self.inactiveImage = [UIImage imageNamed:@"chexun_home_indicator"] ;
    }
    return self;
}

-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIView *dot = [self.subviews objectAtIndex:i];
        if (i == self.currentPage) {
            UIImageView *activeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 4, 4)];
            activeImageView.image = self.activeImage;
            [dot addSubview:activeImageView];
        } else {
            UIImageView *inactiveImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 4, 4)];
            inactiveImageView.image = self.inactiveImage;
            [dot addSubview:inactiveImageView];
        }
    }
}
-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}

@end
