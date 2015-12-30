//
//  BrandView.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-3.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BrandsNum 5
#define BrandWidth (ScreenWidth / BrandsNum)
#define BrandHeight BrandWidth
#define BrandsGap 10

@interface BrandView : UIView

@property (nonatomic,strong) NSArray *brands;

@end
