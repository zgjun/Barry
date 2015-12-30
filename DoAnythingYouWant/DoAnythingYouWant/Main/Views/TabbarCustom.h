//
//  TabbarCustom.h
//  DoAnythingYouWant
//
//  Created by zgjun on 15/12/24.
//  Copyright © 2015年 barry. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void  (^TabJumpBlock)(NSInteger index);

@interface TabbarCustom : UIView

/*设置tabbar上面的按钮*/
@property (nonatomic,strong) NSMutableArray *tabbarItems;

@property (nonatomic,copy) TabJumpBlock tabJumpBlock;

@end
