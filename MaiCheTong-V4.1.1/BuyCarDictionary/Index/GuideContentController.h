//
//  GuideContentController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-17.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideContentController : UITableViewController

@property (nonatomic,strong) __block NSMutableArray *contentArr;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;


- (void)loadDataWithType:(NSInteger)type;

@end
