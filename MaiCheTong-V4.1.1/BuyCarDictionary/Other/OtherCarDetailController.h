//
//  OtherCarDetailController.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-13.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <UIKit/UIKit.h>


//@class OtherCarDetailController;
//
//@protocol OtherCarDetailDelegate <NSObject>
//
//- (void)otherCarDetailSelected:(NSDictionary *)carTypeDict;
//
//@end

@interface OtherCarDetailController : UIViewController

//@property (nonatomic,weak) id<OtherCarDetailDelegate> delegate;

- (instancetype)initWithCarSeriesId:(NSString *)carSeriesId carSeriesName:(NSString *)carSeriesName;

@end
