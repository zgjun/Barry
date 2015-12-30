//
//  BaseTabBarController.h
//  DoAnythingYouWant
//
//  Created by zgjun on 15/12/24.
//  Copyright © 2015年 barry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TabbarCustom;



@interface BaseTabBarController : UITabBarController

@property (nonatomic,strong) TabbarCustom *tabbarCustom;

@property (nonatomic,assign) CGRect tabbarBounds;





@end
