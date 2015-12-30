//
//  IWComposeVivew.m
//  7期微博
//
//  Created by teacher on 14-8-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "OtherAdviceView.h"

@interface OtherAdviceView()
// 提示内容容器
@property(nonatomic, weak)UILabel *label;
@end

@implementation OtherAdviceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textColor = [UIColor lightGrayColor];
        label.font = self.font;
        [self addSubview:label];
        self.label = label;
        
        // 注册一个通知, 当textview文本发生变化的时候就会发送通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textChagne) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textChagne
{
    // 判断textView是否有文字, 如果有隐藏label,如果没有显示label
    self.label.hidden = (self.text.length != 0);
    
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    // 1.设置显示的提示文本
    self.label.text = _placeholder;
    // 2.计算label的frame
    [self setLabelFont];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    
    self.label.textColor = _placeholderColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.x = 5;
    self.label.y = 5;
}


- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    // 设置提示label的字体
    self.label.font = font;
    // 2.计算label的frame
    [self setLabelFont];

}

- (void)setLabelFont
{
    // 2.计算label的frame
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGSize labelMaxSize = CGSizeMake(screenWidth, MAXFLOAT);
    CGSize labelSize = [_placeholder sizeWithFont:self.label.font constrainedToSize:labelMaxSize];
    self.label.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
    
}
@end
