//
//  CarTypeScreenView.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-9.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ButtonNum 3

#define CenterGap 14
#define BetweenGap 10
#define UpDownGap 18

#define BtnWidth ((ScreenWidth - (ButtonNum + 1) * BetweenGap) / ButtonNum)
#define BtnHeight 30

@class CarTypeScreenView;

@protocol CarTypeScreenViewDelegate <NSObject>

- (void)cTParaChooseViewBtnClick:(NSString *)selectTitle SectionValue:(NSInteger)sectionValue selectedValue:(NSInteger)selectedValue;

@end

@interface CarTypeScreenView : UIView
@property (nonatomic,strong) NSArray *params;

@property (nonatomic,assign) NSInteger sectionValue;

@property (nonatomic,assign) NSInteger selectedValue;

@property (nonatomic,weak) id<CarTypeScreenViewDelegate> delegate;

@end
