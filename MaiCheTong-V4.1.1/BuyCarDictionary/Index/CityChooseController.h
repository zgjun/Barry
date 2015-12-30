//
//  CityChooseController.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-17.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CityChooseController;

@protocol CityChooseControllerDelegate <NSObject>

- (void)didCityTableRowClick:(CityChooseController *)cityVc infoDict:(NSDictionary *)infoDict;

@end

@interface CityChooseController : UIViewController

@property (nonatomic,weak) id<CityChooseControllerDelegate> cityDelegate;

@end
