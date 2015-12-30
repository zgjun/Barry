//
//  IWComposeVivew.h
//  7期微博
//
//  Created by teacher on 14-8-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherAdviceView : UITextView
/**
 * 需要显示的提示文本
 */
@property (copy, nonatomic) NSString *placeholder;
/**
 * 设置提示文本的文字颜色
 */
@property(nonatomic, strong)UIColor *placeholderColor;
@end
