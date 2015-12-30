//
//  CSMarkeyController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IntBlock)(NSInteger);

@interface CSMarketController : UITableViewController

@property (nonatomic,copy) IntBlock marketBlock;


- (instancetype)initWithContentDict:(NSDictionary *)contentDict;

@end
