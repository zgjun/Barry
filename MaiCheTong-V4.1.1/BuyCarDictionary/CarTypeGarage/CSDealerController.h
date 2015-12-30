//
//  CSDealerController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-5.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^IntBlock)(NSInteger);
@interface CSDealerController : UITableViewController

@property (nonatomic,assign) NSInteger markNo;

@property (nonatomic,copy) IntBlock dealerBlock;

- (instancetype)initWithContentDict:(NSDictionary *)contentDict;

@end
