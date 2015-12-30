//
//  CarTypeScreenView.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-9.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarTypeScreenView.h"

@interface CarTypeScreenView()
@property (nonatomic,weak) UIButton *currentBtn;
@end

@implementation CarTypeScreenView

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
        [btn setBackgroundImage:[UIImage imageNamed:@"chexun_button1"] forState:UIControlStateSelected];
        
        [btn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //设置frame
        NSInteger row = i % ButtonNum;
        NSInteger col = i / ButtonNum;
        
        CGFloat btnX = BetweenGap + row * (BtnWidth + BetweenGap);
        CGFloat btnY = col * (BtnHeight + CenterGap) + UpDownGap;
        
        btn.frame = CGRectMake(btnX, btnY, BtnWidth, BtnHeight);
        
        
        if (btn.tag == self.selectedValue) {
            [self btnClick:btn];
        }
        
        [self addSubview:btn];
    }
    
    
}

- (void)btnClick:(UIButton *)btn {
    
    if (btn == self.currentBtn) return;
    
    self.currentBtn.selected = NO;
    
    btn.selected = YES;
    
    self.currentBtn = btn;
    
    
    if ([self.delegate respondsToSelector:@selector(cTParaChooseViewBtnClick:SectionValue: selectedValue:)]) {
        [self.delegate cTParaChooseViewBtnClick:btn.titleLabel.text SectionValue:self.sectionValue selectedValue:btn.tag];
    }
}


@end
