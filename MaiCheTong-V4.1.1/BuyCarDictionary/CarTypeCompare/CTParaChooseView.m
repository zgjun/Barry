//
//  CTParaChooseView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-21.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CTParaChooseView.h"


@interface CTParaChooseView()
@property (nonatomic,weak) UIButton *currentBtn;

@end

@implementation CTParaChooseView

- (void)setParams:(NSArray *)params {
    _params = params;
    
    //创建按钮并设置frame
    for (int i = 0; i < params.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        NSString *btnTitle = params[i];
        
        if (btnTitle.length >= 5) {
            btn.titleLabel.font = [UIFont systemFontOfSize:11];
        } else {
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
        }
        
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        
        
        [btn setBackgroundImage:[UIImage imageNamed:@"chexun_button3"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"chexun_button1"] forState:UIControlStateHighlighted];
        [btn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //设置frame
        NSInteger row = i % ButtonNum;
        NSInteger col = i / ButtonNum;
        
        CGFloat btnX = BetweenGap + row * (BtnWidth + BetweenGap);
        CGFloat btnY = col * (BtnHeight + CenterGap);
        
        btn.frame = CGRectMake(btnX, btnY, BtnWidth, BtnHeight);
        
        [self addSubview:btn];
    }
    
    
}

- (void)btnClick:(UIButton *)btn {
    
    if (btn == self.currentBtn) return;
    
    self.currentBtn.selected = NO;
    
    btn.selected = YES;
    
    self.currentBtn = btn;
    
    
    if ([self.delegate respondsToSelector:@selector(cTParaChooseViewBtnClick:SectionValue:)]) {
        [self.delegate cTParaChooseViewBtnClick:btn.tag SectionValue:self.sectionValue];
    }
}



@end
