//
//  ChooseBrandController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChooseBrandController;

@protocol ChooseBrandControllerDelegate <NSObject>

- (void)chooseBrandClick:(NSString *)brandId;

@end

@interface ChooseBrandController : UITableViewController

@property (nonatomic,weak) id<ChooseBrandControllerDelegate> delegate;

@end
