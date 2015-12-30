//
//  CSImageShowController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSImageContentController : UITableViewController
@property (nonatomic,strong) NSMutableArray *contentArr;

/**导航数据*/
@property (nonatomic,strong) NSArray *navTittles;

@property (nonatomic,strong) NSString *seriesId;

- (void)loadDataWithType:(NSString *)albumType;

@end
