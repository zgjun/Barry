//
//  RPriceContentController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-4.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPriceContentController : UITableViewController

@property (nonatomic,strong) __block NSMutableArray *contentArr;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;


- (void)loadDataWithLevel:(NSString *)carLevel;

@end
