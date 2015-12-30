//
//  ScreeningView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-15.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "ScreeningView.h"
#import "ScreeningContentBtn.h"
#import "AFNetworking.h"



@interface ScreeningView()

@property (nonatomic,weak) ScreeningContentBtn *currentBtn;



@property (nonatomic,strong) __block  NSString *count;

@end


@implementation ScreeningView


- (void)setButtonInfo:(NSArray *)buttonInfo {
    _buttonInfo = buttonInfo;
    
    
    //创建按钮并设置frame
    for (int i = 0; i < buttonInfo.count; i++) {
        ScreeningContentBtn *btn = [[ScreeningContentBtn alloc]init];
        NSDictionary *dict = buttonInfo[i];
        
        [btn setTitle:dict[@"typeName"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.sectionNum = self.sectionValue;
        btn.typeId = dict[@"typeId"];
        
//        [btn setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
        
        //设置按钮是否可用
        for (int j = 0; j < self.selectedArr.count; j++) {
            if ([self.selectedArr[j] isEqualToString:btn.typeId]) {
                btn.enabled = YES;
                break;
                
            } else {
                btn.enabled = NO;
            }
        }
        
        [btn setBackgroundImage:[UIImage imageNamed:@"chexun_button3"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"chexun_button1"] forState:UIControlStateSelected];
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setTitleColor:MainFontGrayColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //设置frame
        NSInteger row = i % ButtonNum;
        NSInteger col = i / ButtonNum;
        
        CGFloat btnX = BetweenGap + row * (BtnWidth + BetweenGap);
        CGFloat btnY = col * (BtnHeight + CenterGap);
        
        btn.frame = CGRectMake(btnX, btnY, BtnWidth, BtnHeight);
        
        NSString *unUsedNum = [NSString stringWithFormat:@"-1"];
        
        
        
        if ([btn.typeId integerValue] == [self.selectedTypeId integerValue]) {
            
            if ([self.selectedTypeId isEqual:unUsedNum]) {
                btn.enabled = YES;
            }
            self.currentBtn = btn;
            btn.selected = YES;
            
        }

        [self addSubview:btn];
    }
    
    
}

- (void)btnClick:(ScreeningContentBtn *)btn {
    
    //不限的typeid=-1
    
    NSString *unUsedNum = [NSString stringWithFormat:@"%@",@(-1)];
    if (btn == self.currentBtn) {
        btn.selected = !btn.selected;
        
        if ([self.delegate respondsToSelector:@selector(screeningViewBtnClick:SectionValue:)]) {
            if (btn.selected) {
                [self.delegate screeningViewBtnClick:btn.typeId SectionValue:btn.sectionNum];
                
            } else {
                [self.delegate screeningViewBtnClick:unUsedNum SectionValue:btn.sectionNum];
            }
        }
        
    } else {
        self.currentBtn.selected = NO;
        
        btn.selected = YES;
        
        self.currentBtn = btn;
        
        self.selectedTypeId = btn.typeId;
        
        if ([self.delegate respondsToSelector:@selector(screeningViewBtnClick:SectionValue:)]) {
            [self.delegate screeningViewBtnClick:btn.typeId SectionValue:btn.sectionNum];
        }

    }
}



@end
