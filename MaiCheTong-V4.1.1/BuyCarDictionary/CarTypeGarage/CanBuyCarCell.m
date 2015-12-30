//
//  CanBuyCarCell.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-3.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CanBuyCarCell.h"
#import "NoHighLightBtn.h"
#import "UIImageView+WebCache.h"
#define CanBuyCarCellGap 10
#define PriceLabelHeight 25

@interface CanBuyCarCell()
@property (nonatomic,strong) NSDictionary *canBuyCarDict;

@property (nonatomic,weak) UIImageView *carIcon;

@property (nonatomic,weak) UILabel *nameLabel;

@property (nonatomic,weak) NoHighLightBtn *compareBtn;

@property (nonatomic,weak) UILabel *guideContentLabel;

@property (nonatomic,weak) UILabel *lowContentLabel;

@property (nonatomic,weak) UIImageView *vLine;

@property (nonatomic,weak) UILabel *guideTitleLabel;

@property (nonatomic,weak) UILabel *lowTitleLabel;

@property (nonatomic,strong) NSMutableArray *compareArrM;


@end

@implementation CanBuyCarCell

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

- (instancetype)initWithCanBuyCarDict:(NSDictionary *)canBuyCarDict {
    if (self = [super init]) {
        
        
        //创建子控件
        UIImageView *carIcon = [[UIImageView alloc]init];
        self.carIcon = carIcon;
        [self addSubview:carIcon];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.numberOfLines = -1;
        self.nameLabel = nameLabel;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nameLabel];
        
        UIImageView *vLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_models_verticalline"]];
        self.vLine = vLine;
        [self addSubview:vLine];
        vLine.hidden = YES;
        
        NoHighLightBtn *compareBtn = [[NoHighLightBtn alloc]init];
        self.compareBtn = compareBtn;
        [compareBtn setImage:[UIImage imageNamed:@"chexun_models_addicon"] forState:UIControlStateNormal];
        [compareBtn setImage:[UIImage imageNamed:@"chexun_models_cancelicon_gray"] forState:UIControlStateSelected];
        compareBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [compareBtn setTitleColor:MainBlackColor forState:UIControlStateNormal];
        [compareBtn setTitleColor:MainLineGrayColor forState:UIControlStateSelected];
        [compareBtn setTitle:@"对比" forState:UIControlStateNormal];
        [compareBtn setTitle:@"取消" forState:UIControlStateSelected];
//        [compareBtn addTarget:self action:@selector(compareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:compareBtn];
        //不显示对比按钮
        compareBtn.hidden = YES;
        
        //指导价
        UILabel *guideTitleLabel = [[UILabel alloc]init];
        self.guideTitleLabel = guideTitleLabel;
        guideTitleLabel.textColor = MainFontGrayColor;
        guideTitleLabel.text = @"指导价：";
        guideTitleLabel.font = [UIFont systemFontOfSize:12];
        guideTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:guideTitleLabel];
        
        UILabel *guideContentLabel = [[UILabel alloc]init];
        self.guideContentLabel = guideContentLabel;
        guideContentLabel.textColor = MainFontGrayColor;
        guideContentLabel.font = [UIFont systemFontOfSize:12];
        guideContentLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:guideContentLabel];
        
        //最低价
        UILabel *lowTitleLabel = [[UILabel alloc]init];
        self.lowTitleLabel = lowTitleLabel;
        lowTitleLabel.text = @"最低价：";
        lowTitleLabel.textColor = MainFontRedColor;
        lowTitleLabel.font = [UIFont systemFontOfSize:12];
        lowTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:lowTitleLabel];
        
        UILabel *lowContentLabel = [[UILabel alloc]init];
        self.lowContentLabel = lowContentLabel;
        lowContentLabel.textColor = MainFontRedColor;
        lowContentLabel.font = [UIFont systemFontOfSize:12];
        lowContentLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:lowContentLabel];
        
        
        self.canBuyCarDict = canBuyCarDict;
        
        
        //设置子控件的frame
        [self childsFrame];
        
    }
    return self;
}


/*
- (void)compareBtnClick:(NoHighLightBtn *)btn {
    
    NSMutableArray *compareTemp = self.compareArrM;
    
    if (compareTemp.count >= 10 && btn.selected == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"亲，请注意" message:@"最多只能添加10款车进行对比选择" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    btn.selected = !btn.selected;
    
    if (btn.selected == YES) {
        //添加
        NSString *carTypeId = [NSString stringWithFormat:@"%@",self.canBuyCarDict[@"id"]];
        
        NSString *carTypeName = [NSString stringWithFormat:@"%@",self.canBuyCarDict[@"name"]];
        
        NSString *carTypeImage = [NSString stringWithFormat:@"%@",self.canBuyCarDict[@"imgPath"]];
        
        NSString *carTypePrice = [NSString stringWithFormat:@"%@",self.canBuyCarDict[@"price"]];
        
        NSString *carTypeLowPrice = [NSString stringWithFormat:@"%@",self.canBuyCarDict[@"MinPrice"]];
        
        
        
        NSDictionary *carTypeInfo = @{@"carTypeId":carTypeId,@"carTypeName":carTypeName,@"carTypeImage":carTypeImage,@"carTypePrice":carTypePrice,@"carTypeLowPrice":carTypeLowPrice,@"compareState":@0};
        
        [compareTemp addObject:carTypeInfo];
        
    } else {
        //减少
        for (int i = 0; i < compareTemp.count; i++) {
            
            NSDictionary *dict = compareTemp[i];
            
            NSString *carTypeId = [NSString stringWithFormat:@"%@",self.canBuyCarDict[@"id"]];
            
            if ([dict[@"carTypeId"] isEqual: carTypeId]) {
                
                [compareTemp removeObject:dict];
                
                break;
                
            }
            
        }
    }
    
    if (compareTemp.count == 0) {
        
        //清除文件
        
        [self cleanCompareCars];
        
        
    } else {
        
        //写入新数据
        
        [self writeNewData:compareTemp];
    }
    
    //通知代理修改PK按钮上面的数值
    if ([self.delegate respondsToSelector:@selector(canBuyCarCellSelected)]) {
        [self.delegate canBuyCarCellSelected];
    }
    
}
 */

- (void)writeNewData:(NSMutableArray *)compareTemp {
    //从沙盒里面读取历史数据
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接文件名
    NSString *fileName = [docDir stringByAppendingPathComponent:@"compareCars.plist"];
    
    [compareTemp writeToFile:fileName atomically:YES];
}

- (void)cleanCompareCars {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:@"compareCars.plist"];
    BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
    if (bRet) {
        NSError *err;
        [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
    }
}

- (void)childsFrame {
    self.carIcon.frame = CGRectMake(0, CanBuyCarCellGap * 2, 60, 40);
    
    NSString *carName = [NSString stringWithFormat:@"%@ %@ %@款 %@",self.canBuyCarDict[@"brand"],self.canBuyCarDict[@"seriesName"],self.canBuyCarDict[@"yearName"],self.canBuyCarDict[@"name"]];
    CGFloat maxWidth = ScreenWidth - 70;
    NSDictionary *attrs = @{NSFontAttributeName : self.nameLabel.font};
    CGSize carNameZ = [carName boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.carIcon.frame) + CanBuyCarCellGap, CanBuyCarCellGap, carNameZ.width, 35);
    
//    self.vLine.frame = CGRectMake(ScreenWidth - 60 + 3, CanBuyCarCellGap, 1, 50);
    
//    self.compareBtn.frame = CGRectMake(CGRectGetMaxX(self.vLine.frame) + 5, CanBuyCarCellGap, 50, 45);
    self.guideTitleLabel.frame =  CGRectMake(CGRectGetMaxX(self.carIcon.frame) + CanBuyCarCellGap, CGRectGetMaxY(self.nameLabel.frame), 48, PriceLabelHeight);
    
    self.guideContentLabel.frame = CGRectMake(CGRectGetMaxX(self.guideTitleLabel.frame), CGRectGetMaxY(self.nameLabel.frame), 50, PriceLabelHeight);
    
    self.lowTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.guideContentLabel.frame), CGRectGetMaxY(self.nameLabel.frame), 48, PriceLabelHeight);
    
    self.lowContentLabel.frame = CGRectMake(CGRectGetMaxX(self.lowTitleLabel.frame), CGRectGetMaxY(self.nameLabel.frame), 50, PriceLabelHeight);
}


- (void)setCanBuyCarDict:(NSDictionary *)canBuyCarDict {
    _canBuyCarDict = canBuyCarDict;
    
    [self.carIcon sd_setImageWithURL:[NSURL URLWithString:canBuyCarDict[@"imgPath"]] placeholderImage:[UIImage imageNamed:@"load1"]];
    
    
    NSString *carName = [NSString stringWithFormat:@"%@ %@款 %@",canBuyCarDict[@"seriesName"],canBuyCarDict[@"yearName"],canBuyCarDict[@"name"]];
    
    self.nameLabel.text = carName;
    
    self.guideContentLabel.text = [NSString stringWithFormat:@"%.2f万",[canBuyCarDict[@"price"] floatValue]];
    
    self.lowContentLabel.text = [NSString stringWithFormat:@"%.2f万",[canBuyCarDict[@"MinPrice"] floatValue]];
    
    for (int i = 0; i < self.compareArrM.count; i++) {
        NSDictionary *dict = self.compareArrM[i];
        if ([canBuyCarDict[@"id"] integerValue] == [dict[@"carTypeId"] integerValue]) {
            self.compareBtn.selected = YES;
            break;
        }
    }
}

@end
