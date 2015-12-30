//
//  ChooseSectionController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChooseSectionController;

@protocol ChooseSectionControllerDelegate <NSObject>

- (void)chooseSectionClick:(NSString *)sectionId;

@end

@interface ChooseSectionController : UITableViewController

@property (nonatomic,weak) id<ChooseSectionControllerDelegate> delegate;

- (instancetype)initWithSectionArr:(NSArray *)sectionArr;

@end
