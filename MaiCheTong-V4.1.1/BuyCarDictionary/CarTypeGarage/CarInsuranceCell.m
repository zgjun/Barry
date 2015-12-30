//
//  CarInsuranceCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-31.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CarInsuranceCell.h"
#define CellHeight 44

@interface CarInsuranceCell()<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,strong) NSDictionary *insuranceDict;

@property (nonatomic,weak) UILabel *titleLabel;

@property (nonatomic,weak) UITextField *contentField;

@property (nonatomic,weak) UILabel *rightLabel;

@property (nonatomic,weak) UISwitch *showSwitch;

@property (nonatomic,assign) BOOL isChoose;

@property (nonatomic,strong) NSArray *contentArr;

@end

@implementation CarInsuranceCell

- (instancetype)initWithInsuranceDict:(NSDictionary *)insuranceDict isChoose:(BOOL)isChoose contentArr:(NSArray *)contentArr {
    if (self = [super init]) {
        self.insuranceDict = insuranceDict;
        self.contentArr = contentArr;
        
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.textColor = MainBlackColor;
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.text = insuranceDict[@"title"];
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        
        self.isChoose = isChoose;
        if (!isChoose) {
            UILabel *contentLabel = [[UILabel alloc]init];
            contentLabel.textAlignment = NSTextAlignmentRight;
            contentLabel.textColor = MainBlackColor;
            contentLabel.font = [UIFont systemFontOfSize:16];
            contentLabel.text = [NSString stringWithFormat:@"%.0f元",[insuranceDict[@"content"] floatValue]];
            self.contentLabel = contentLabel;
            [self addSubview:contentLabel];
        } else {
            UITextField *contentField = [[UITextField alloc]init];
            contentField.delegate = self;
            contentField.textColor = MainBlackColor;
            UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 150)];
            
            inputView.backgroundColor = MainBackGroundColor;
            contentField.inputView = inputView;
            //选择视图
            UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:inputView.bounds];
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [inputView addSubview:pickerView];
            
            self.contentField = contentField;
            contentField.text = [NSString stringWithFormat:@"%.0f",[insuranceDict[@"content"] floatValue]];
            contentField.delegate = self;
            
            contentField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            
            contentField.background = [UIImage imageNamed:@"chexun_inputbox"];
            
            contentField.textAlignment = NSTextAlignmentRight;
            [self addSubview:contentField];
            
            UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 25)];
            self.rightLabel = rightLabel;
            
            rightLabel.font = [UIFont systemFontOfSize:16];
            
            rightLabel.textColor = MainBlackColor;
            
            rightLabel.text = @"元";
            
            contentField.rightViewMode = UITextFieldViewModeAlways;
            
            contentField.rightView = rightLabel;
        }
        
        
        UISwitch *showSwitch = [[UISwitch alloc]init];

        [showSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        if ([insuranceDict[@"insuranceShow"] integerValue] == 1) {
            showSwitch.on = YES;
            self.contentField.enabled = YES;
            self.contentField.textColor = MainBlackColor;
            self.rightLabel.textColor = MainBlackColor;
            self.contentLabel.textColor = MainBlackColor;
        } else {
            showSwitch.on = NO;
            self.contentField.enabled = NO;
            self.contentField.textColor = MainLineGrayColor;
            self.rightLabel.textColor = MainLineGrayColor;
            self.contentLabel.textColor = MainLineGrayColor;
            
        }
        
        self.showSwitch = showSwitch;
        [self addSubview:showSwitch];
    }
    return self;
}

- (void)switchAction:(UISwitch *)switchBtn {
    BOOL isButtonOn = [switchBtn isOn];
    
    if (isButtonOn) {
        if (self.isChoose) {
            self.contentField.enabled = YES;
            self.contentField.textColor = MainBlackColor;
            self.rightLabel.textColor = MainBlackColor;
        } else {
            self.contentLabel.enabled = YES;
        }
    } else {
        if (self.isChoose) {
            self.contentField.enabled = NO;
            self.contentField.textColor = MainLineGrayColor;
            self.rightLabel.textColor = MainLineGrayColor;
        } else {
            self.contentLabel.enabled = NO;
        }
    }
    
    //通知代理
    if ([self.delegate respondsToSelector:@selector(carInsuranceCellSwitch:rowValue:)]) {
        [self.delegate carInsuranceCellSwitch:isButtonOn rowValue:self.rowValue];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    self.titleLabel.frame = CGRectMake(0, 0, ScreenWidth * 0.5, CellHeight);
    
    self.contentLabel.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame), 0, 80, CellHeight);
    
    self.contentField.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame), 7, 80, 30);
    
    
    self.showSwitch.frame = CGRectMake(ScreenWidth - 50 - 10, 7, 50, CellHeight);
    
}

#pragma mark - 数据源方法
/**
 *  一共有多少列
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/**
 *  第component列显示多少行
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.contentArr.count;
}

#pragma mark - 代理方法
/**
 *  第component列的第row行显示什么文字
 */

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView *contentView = [[UIView alloc]init];
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *dict = self.contentArr[row];
    
//    MyLog(@"%@",dict[@"showText"]);
    
    contentLabel.text = dict[@"showText"];
    
    [contentView addSubview:contentLabel];
    
    return contentView;
}

/**
 *  选中了第component列的第row行
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDictionary *dict = self.contentArr[row];
    self.contentField.text = [NSString stringWithFormat:@"%@",dict[@"value"]];
    
    //通知代理
    if ([self.delegate respondsToSelector:@selector(carInsuranceCellChangeValue:component:)]) {
        [self.delegate carInsuranceCellChangeValue:self.rowValue component:row];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}


@end
