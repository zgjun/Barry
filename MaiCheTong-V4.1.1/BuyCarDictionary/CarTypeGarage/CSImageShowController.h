//
//  CSImageShowController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-16.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSImageShowController;

@protocol CSImageShowControllerDelegate <NSObject>

@end

@interface CSImageShowController : UIViewController
@property (nonatomic,weak) id<CSImageShowControllerDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)carTitle seriesId:(NSString *)seriesId;

@end
