//
//  AppDelegate.h
//  BuyCarDictionary
//
//  Created by zgjun on 14/11/24.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder<UIApplicationDelegate,
UIAlertViewDelegate, WXApiDelegate>


@property (strong, nonatomic) UIWindow *window;

@end

