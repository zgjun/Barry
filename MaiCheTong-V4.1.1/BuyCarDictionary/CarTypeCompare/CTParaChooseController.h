//
//  CTParaChooseController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-21.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CTParaChooseController;

@protocol CTParaChooseControllerDelegate <NSObject>

- (void)cTParaChooseBgClick;

- (void)cTParaChooseButtonClick:(NSInteger)sectionValue btnTag:(NSInteger)btnTag;

@end

@interface CTParaChooseController : UIViewController

@property (nonatomic,weak) id<CTParaChooseControllerDelegate> delegate;

@end
