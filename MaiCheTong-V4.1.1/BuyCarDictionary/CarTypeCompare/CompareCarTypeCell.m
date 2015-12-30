//
//  CompareCarTypeCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-1-25.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CompareCarTypeCell.h"


#define CSContentCellGap 10
#define CSSpliteHeight 10
#define CSRowHeight ((self.height - CSSpliteHeight) / 3)

#define FouesImageHeight 10
#define SmallBtnSide 40

@interface CompareCarTypeCell()

@property (nonatomic,weak) UIView *spliteView;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UILabel *priceLabel;
@property (nonatomic,weak) UIButton *selectedBtn;

@property (nonatomic,strong) NSMutableArray *compareArrM;

@end

@implementation CompareCarTypeCell

- (NSMutableArray *)compareArrM {
    _compareArrM = [NSMutableArray array];
    
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    //先读取之前的历史记录
    _compareArrM = [[NSMutableArray alloc]initWithContentsOfFile:fileName];
    
    return _compareArrM;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = MainWhiteColor;
        
        UIView *spliteView = [[UIView alloc]init];
        self.spliteView = spliteView;
        spliteView.backgroundColor = MainBackGroundColor;
        [self addSubview:spliteView];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.textColor = MainBlackColor;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        
        
        UILabel *priceLabel = [[UILabel alloc]init];
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.textAlignment = NSTextAlignmentLeft;
        priceLabel.textColor = MainFontGrayColor;
        self.priceLabel = priceLabel;
        [self addSubview:priceLabel];
        
        //选中按钮
        UIButton *selectedBtn = [[UIButton alloc]init];
        [selectedBtn setBackgroundImage:[UIImage imageNamed:@"chexun_cancelbut"] forState:UIControlStateNormal];
        [selectedBtn setBackgroundImage:[UIImage imageNamed:@"chexun_selectedbut"] forState:UIControlStateSelected];
        
        [selectedBtn addTarget:self action:@selector(selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.selectedBtn = selectedBtn;
        [self addSubview:selectedBtn];
        
        
    }
    return self;
}

- (void)selectedBtnClick:(UIButton *)btn {
    
    NSMutableArray *compareTemp = self.compareArrM;
    if (compareTemp.count >= 10 && btn.selected == NO) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"亲，请注意" message:@"最多只能添加10款车进行对比选择" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alert show];
        
        return;
        
    }
    btn.selected = !btn.selected;
    self.isSelected = btn.selected;
    
    if ([self.delegate respondsToSelector:@selector(compareCarTypeSelectedClick:)]) {
        [self.delegate compareCarTypeSelectedClick:self];
    }
    
    
}

- (void)setCellDict:(NSDictionary *)cellDict {
    _cellDict = cellDict;
    self.nameLabel.text = cellDict[@"name"];
    CGFloat priceValue = [cellDict[@"guidePrice"] floatValue];
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f万元",priceValue];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.spliteView.frame = CGRectMake(0, 0, self.width, CSSpliteHeight);
    
    self.nameLabel.frame = CGRectMake(CSContentCellGap, CSSpliteHeight + CSContentCellGap, self.width - CSContentCellGap - SmallBtnSide, CSRowHeight);
    
    self.priceLabel.frame = CGRectMake(CSContentCellGap, CGRectGetMaxY(self.nameLabel.frame), 100, CSRowHeight);
    
    self.selectedBtn.frame = CGRectMake(ScreenWidth - CSContentCellGap - SmallBtnSide, (80 - SmallBtnSide) * 0.5, SmallBtnSide, SmallBtnSide);
    
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    self.selectedBtn.selected = self.isSelected;
}



@end
