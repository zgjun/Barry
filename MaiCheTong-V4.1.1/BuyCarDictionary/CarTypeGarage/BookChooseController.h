//
//  BookChooseController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookChooseController;

@protocol BookChooseDelegate <NSObject>

- (void)bookChooseSelected:(NSString *)selectedName;

@end

@interface BookChooseController : UIViewController

@property (nonatomic,weak) id<BookChooseDelegate> delegate;

@end
