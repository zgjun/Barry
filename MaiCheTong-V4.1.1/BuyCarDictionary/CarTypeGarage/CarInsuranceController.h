//
//  CarInsuranceController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-30.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CarInsuranceController;

@protocol CarInsuranceControllerDelegate <NSObject>

- (void)carInsuranceControllerDictM:(NSMutableDictionary *)insuranceDictM allInsurance:(CGFloat)allInsurance;

- (void)carInsuranceControllerSwitch:(NSMutableDictionary *)insuranceDictM allInsurance:(CGFloat)allInsurance;

@end


@interface CarInsuranceController : UIViewController

@property (nonatomic,weak) id<CarInsuranceControllerDelegate> delegate;

- (instancetype)initWithInsuranceDictM:(NSMutableDictionary *)insuranceDictM pureValue:(CGFloat)pureValue familySites:(NSInteger)familySites;

@end
