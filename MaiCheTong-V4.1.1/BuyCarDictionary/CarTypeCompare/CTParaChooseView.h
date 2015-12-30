//
//  CTParaChooseView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-21.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ButtonNum 4

#define CenterGap 14
#define BetweenGap 10
#define UpDownGap 18

#define BtnWidth ((ScreenWidth - (ButtonNum + 1) * BetweenGap) / ButtonNum)
#define BtnHeight 30

@class CTParaChooseView;

@protocol CTParaChooseViewDelegate <NSObject>

- (void)cTParaChooseViewBtnClick:(NSInteger)btnTag SectionValue:(NSInteger)sectionValue;

@end

@interface CTParaChooseView : UIView

@property (nonatomic,strong) NSArray *params;

@property (nonatomic,assign) NSInteger sectionValue;

@property (nonatomic,weak) id<CTParaChooseViewDelegate> delegate;
@end
