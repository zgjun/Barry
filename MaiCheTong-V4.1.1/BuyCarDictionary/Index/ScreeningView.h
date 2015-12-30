//
//  ScreeningView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-15.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>


#define CenterGap 14
#define BetweenGap 10
#define UpDownGap 18

#define ButtonNum 4
#define BtnWidth ((ScreenWidth - (ButtonNum + 1) * BetweenGap) / ButtonNum)
#define BtnHeight 27

@class ScreeningView;

@protocol ScreeningViewDelegate <NSObject>

- (void)screeningViewBtnClick:(NSString *)selectedId SectionValue:(NSInteger)sectionValue;

@end

@interface ScreeningView : UIView

@property (nonatomic,strong) NSArray *buttonInfo;

@property (nonatomic,strong) NSString *carTypeStr;

@property (nonatomic,strong) NSString *selectedTypeId;

@property (nonatomic,assign) NSInteger sectionValue;

@property (nonatomic,weak) NSArray *selectedArr;

@property (nonatomic,weak) id<ScreeningViewDelegate> delegate;

@end
