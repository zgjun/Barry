//
//  RPriceController.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPriceController;

@protocol RPriceControllerDelegate <NSObject>

@end

@interface RPriceController :UIViewController

@property (nonatomic,weak) id<RPriceControllerDelegate> delegate;

@end
