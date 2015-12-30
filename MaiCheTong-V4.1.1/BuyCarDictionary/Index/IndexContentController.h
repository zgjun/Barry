//
//  IndexContentController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-4-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndexContentController;

@protocol IndexContentControllerDelegate <NSObject>

- (void)indexContentScroll:(IndexContentController *)indexTableController isup:(BOOL)isup;

- (void)didChangeInfoDict:(NSDictionary *)navBarInfoDict;

@end

@interface IndexContentController : UITableViewController

@property (nonatomic,weak) id<IndexContentControllerDelegate> mydelegate;

- (void)loadDataWithLevel:(NSInteger)carLevel;

- (instancetype)initWithCarLevel:(NSInteger)carLevel SuperView:(UIView *)superView;

@end
