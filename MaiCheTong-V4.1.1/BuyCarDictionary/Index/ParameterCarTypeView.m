//
//  ParameterCarTypeView.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-12-29.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "ParameterCarTypeView.h"
#import "NoHighLightBtn.h"
#import "UIImage+Extension.h"
#import "CompareButton.h"
#define GapWidth 15

@interface ParameterCarTypeView()
@property (nonatomic,weak) UILabel *carTypeName;
@property (nonatomic,weak) CompareButton *compareBtn;
@property (nonatomic,weak) UIImageView *imageView;
@property (nonatomic,weak) NoHighLightBtn *reduceBtn;

@property (nonatomic,strong) NSMutableArray *compareArrM;

@end

@implementation ParameterCarTypeView

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
        UIImageView *imageView = [[UIImageView alloc]init];
        self.imageView = imageView;
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage resizableImageWithName:@"chexun_models_addbut_hengban"];
        [self addSubview:imageView];
        
        
        UILabel *carTypeName = [[UILabel alloc]init];
        carTypeName.font = [UIFont systemFontOfSize:12];
        carTypeName.numberOfLines = -1;
        carTypeName.textAlignment = NSTextAlignmentCenter;
        self.carTypeName = carTypeName;
        [self.imageView addSubview:carTypeName];
        
        CompareButton *compareBtn = [[CompareButton alloc]init];
        [compareBtn setImage:[UIImage imageNamed:@"chexun_pk_addicon"] forState:UIControlStateNormal];
        [compareBtn setImage:[UIImage imageNamed:@"chexun_models_cancelicon"] forState:UIControlStateSelected];
        //chexun_models_cancelicon
        [compareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [compareBtn setTitle:@"添加对比" forState:UIControlStateNormal];
        [compareBtn setTitle:@"取消对比" forState:UIControlStateSelected];
        compareBtn.imageView.contentMode = UIViewContentModeCenter;
        compareBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.compareBtn = compareBtn;
        [compareBtn addTarget:self action:@selector(compareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:compareBtn];
        
        NoHighLightBtn *reduceBtn = [[NoHighLightBtn alloc]init];
        [reduceBtn setBackgroundImage:[UIImage imageNamed:@"chexun_deletebut"] forState:UIControlStateNormal];
        self.reduceBtn = reduceBtn;
        [reduceBtn addTarget:self action:@selector(reduceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:reduceBtn];
    }
    return self;
}

- (void)compareBtnClick:(NoHighLightBtn *)btn {
    
    NSMutableArray *compareTemp = [NSMutableArray arrayWithArray:self.compareArrM];
    
    if (compareTemp.count >= 10 && btn.selected == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"亲，请注意" message:@"最多只能添加10款车进行对比选择" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    btn.selected = !btn.selected;
    
    if (btn.selected == YES) {
        //添加
        NSString *carTypeId = [NSString stringWithFormat:@"%@",self.dataDict[@"carTypeId"]];
        
        NSString *carTypeName = [NSString stringWithFormat:@"%@",self.dataDict[@"carTypeName"]];
        
        NSString *carTypeImage = [NSString stringWithFormat:@"%@",self.dataDict[@"carTypeImage"]];
        
        NSString *carTypePrice = [NSString stringWithFormat:@"%@",self.dataDict[@"carTypePrice"]];
        
        NSString *carTypeLowPrice = [NSString stringWithFormat:@"%@",self.dataDict[@"carTypeLowPrice"]];
        
        NSDictionary *carTypeInfo = @{@"carTypeId":carTypeId,@"carTypeName":carTypeName,@"carTypeImage":carTypeImage,@"carTypePrice":carTypePrice,@"carTypeLowPrice":carTypeLowPrice,@"compareState":@0,@"carSeriesId":self.dataDict[@"carSeriesId"],@"carSeriesName":self.dataDict[@"carSeriesName"]};
        
        [compareTemp addObject:carTypeInfo];
        
        if (compareTemp.count == 0) {
            //清除文件
            [self cleanCompareCars];
        } else {
            //写入新数据
            [self writeNewData:compareTemp];
        }
        
    } else {
        //减少
        for (int i = 0; i < compareTemp.count; i++) {
            
            NSDictionary *dict = compareTemp[i];
            
            if ([dict[@"carTypeId"] integerValue] == [self.dataDict[@"carTypeId"] integerValue]) {
                [compareTemp removeObject:dict];
                if (compareTemp.count == 0) {
                    //清除文件
                    [self cleanCompareCars];
                } else {
                    //写入新数据
                    [self writeNewData:compareTemp];
                }
                break;
            }
            
        }
    }
    
    //通知代理
    if ([self.delegate respondsToSelector:@selector(parameterAddBtnClick:)]) {
        [self.delegate parameterAddBtnClick:self];
    }
    
}

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
- (void)reduceBtnClick:(NoHighLightBtn *)btn {
    if ([self.delegate respondsToSelector:@selector(parameterReduceBtnClick:)]) {
        [self.delegate parameterReduceBtnClick:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 10, self.width - GapWidth, self.height - 10);
    self.carTypeName.frame = CGRectMake(0, 0, self.imageView.width, self.imageView.height * 0.6);
    self.compareBtn.frame = CGRectMake(0, self.imageView.height * 0.6, self.imageView.width, self.imageView.height * 0.4);
    self.reduceBtn.frame = CGRectMake(self.width - 25, 0, 23, 23);
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    
    self.carTypeName.text = dataDict[@"carTypeName"];
    
    CGFloat tipLabelX = 0;
    
    CGFloat tipLabelY = 0;
    
    CGSize maxSize = CGSizeMake(self.width, MAXFLOAT);
    
    CGSize tipLabelSize = [dataDict[@"value"] sizeWithFont:self.carTypeName.font constrainedToSize:maxSize];
    
    self.carTypeName.frame = (CGRect){{tipLabelX,tipLabelY},tipLabelSize};
    
    for (int i = 0; i < self.compareArrM.count; i++) {
        NSDictionary *dict = self.compareArrM[i];
        if ([dataDict[@"carTypeId"] integerValue] == [dict[@"carTypeId"] integerValue]) {
            self.compareBtn.selected = YES;
            break;
        }
    }
    
}

@end
