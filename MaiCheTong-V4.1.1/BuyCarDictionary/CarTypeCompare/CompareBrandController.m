//
//  GarageController.m
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import "CompareBrandController.h"
#import "AFNetworking.h"
#import "BrandCellView.h"
#import "CompareBrandDetailController.h"
#import "CTSearchController.h"
#import "MBProgressHUD.h"


#define SmallGapWidth 3
#define CarBrandIndexWidth 40
#define BrandNum (ScreenWidth < 414 ? 3 : 4)
#define BrandCellSide (ScreenWidth - SmallGapWidth * 2 - CarBrandIndexWidth) / BrandNum
#define IndexHeight 20
#define IndexGap 10

#define NavViewHeight 64

#define TabBarHeight 49

@interface CompareBrandController ()<BrandCellViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) __block NSArray *brandArrays;

@property (nonatomic,strong) __block NSString *letterStr;

@property (nonatomic,strong) __block NSArray *letters;

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,assign) CGFloat upDistance;

///指示器
@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,weak) UITableView *lettersTableView;

@end

@implementation CompareBrandController

- (NSArray *)brandArrays {
    
    if (_brandArrays == nil) {
        
        
    }
    return _brandArrays;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.navigationController.viewControllers.count == 1){
        
        //关闭主界面的右滑返回
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}



- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    
    return YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航视图
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    
    navView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:navView];
    
    
    
    //返回按钮
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_backarrow_black"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    [navView addSubview:backBtn];
    
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"选择车型";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
    self.tableView.tag = 0;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = MainBackGroundColor;
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor darkGrayColor];
    
    
    UITableView *lettersTableView = [[UITableView alloc]initWithFrame:CGRectMake(ScreenWidth - CarBrandIndexWidth, 100, CarBrandIndexWidth, ScreenHeight - 100 - 64)];
    lettersTableView.showsVerticalScrollIndicator = NO;
    self.lettersTableView = lettersTableView;
    lettersTableView.tag = 1;
    lettersTableView.dataSource = self;
    lettersTableView.delegate = self;
    [lettersTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LettersCell"];
    lettersTableView.backgroundColor = [UIColor clearColor];
    lettersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:lettersTableView];
    
    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GarageCell"];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [self getData];
}
- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlStr = @"http://api.tool.chexun.com/mobile/buyCarBrands.do";
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    __weak CompareBrandController *myself = self;
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = responseObject[0];
        myself.letterStr = dict[@"letters"];
        myself.brandArrays = dict[@"brands"];
        myself.letters = [myself.letterStr componentsSeparatedByString:@","];
        
        //把上面的品牌数组，变成二维数组
        NSMutableArray *sections = [NSMutableArray array];
        for (int i = 0; i < myself.letters.count; i++) {
            
            NSString *letter = myself.letters[i];
            NSMutableArray *cells = [NSMutableArray array];
            for (int j = 0; j < myself.brandArrays.count; j++) {
                
                NSDictionary *dictLetter = myself.brandArrays[j];
                if ([letter isEqualToString: dictLetter[@"letter"]]) {
                    
                    [cells addObject:dictLetter];
                }
            }
            
            [sections addObject:cells];
        }
        
        _brandArrays = sections;
        
        [myself.tableView reloadData];
        [myself.lettersTableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView  animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:myself.tableView  animated:YES];
        MyLog(@"%@",error);
        
    }];
}


#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        NSArray *arr = self.brandArrays[section];
        
        if (arr.count % BrandNum == 0) {
            return arr.count / BrandNum;
        } else {
            return (arr.count / BrandNum) + 1;
        }
    } else {
        return self.letters.count;
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == 0) {
        return self.brandArrays.count;
        
    } else {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 0) {
        static NSString *ID = @"GarageCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
        
        cell.contentView.backgroundColor = MainBackGroundColor;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSInteger subviewsCount = cell.contentView.subviews.count;
        
        if (subviewsCount > 0) {
            //在这里只能用上面的forin,而不能用下面的for循环
            
            for (BrandCellView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
        
        //在这里设置cell
        NSArray *arrSection = self.brandArrays[indexPath.section];
        
        if (indexPath.row * BrandNum < arrSection.count) {
            BrandCellView *leftView = [[BrandCellView alloc]init];
            leftView.delegate = self;
            leftView.dataDict = arrSection[indexPath.row * BrandNum];
            leftView.frame = CGRectMake(0, SmallGapWidth, BrandCellSide, BrandCellSide);
            [cell.contentView addSubview:leftView];
        }
        
        
        if ((indexPath.row * BrandNum + 1) < arrSection.count) {
            BrandCellView *centerView = [[BrandCellView alloc]init];
            centerView.delegate = self;
            centerView.dataDict = arrSection[indexPath.row * BrandNum + 1];
            centerView.frame = CGRectMake(BrandCellSide + SmallGapWidth, SmallGapWidth, BrandCellSide, BrandCellSide);
            [cell.contentView addSubview:centerView];
        }
        
        if ((indexPath.row * BrandNum + 2) < arrSection.count) {
            BrandCellView *rightView = [[BrandCellView alloc]init];
            rightView.delegate = self;
            rightView.dataDict = arrSection[indexPath.row * BrandNum + 2];
            rightView.frame = CGRectMake((BrandCellSide + SmallGapWidth) * 2, SmallGapWidth, BrandCellSide, BrandCellSide);
            [cell.contentView addSubview:rightView];
        }
        
        if (BrandNum > 3) {
            if ((indexPath.row * BrandNum + 3) < arrSection.count) {
                BrandCellView *rightView = [[BrandCellView alloc]init];
                rightView.delegate = self;
                rightView.dataDict = arrSection[indexPath.row * BrandNum + 3];
                rightView.frame = CGRectMake((BrandCellSide + SmallGapWidth) * 3, SmallGapWidth, BrandCellSide, BrandCellSide);
                [cell.contentView addSubview:rightView];
            }
        }
        
        
        return cell;
        
    } else {
        
        static NSString *LetterID = @"LettersCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LetterID forIndexPath:indexPath];
        
        cell.contentView.backgroundColor = MainBackGroundColor;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSInteger subviewsCount = cell.contentView.subviews.count;
        
        if (subviewsCount > 0) {
            //在这里只能用上面的forin,而不能用下面的for循环
            
            for (BrandCellView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
        
        UILabel *letterLabel = [[UILabel alloc]initWithFrame:cell.bounds];
        letterLabel.backgroundColor = [UIColor clearColor];
        letterLabel.textAlignment = NSTextAlignmentCenter;
        letterLabel.font = [UIFont systemFontOfSize:16];
        
        letterLabel.text = self.letters[indexPath.row];
        [cell.contentView addSubview:letterLabel];
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
}


#pragma mark - tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (tableView.tag == 0) {
        
        return IndexHeight;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 0) {
        return BrandCellSide + SmallGapWidth;
        
    } else {
        return CarBrandIndexWidth;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        UIView *letterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, IndexHeight)];
        letterView.backgroundColor = MainBackGroundColor;
        UILabel *letterLabel = [[UILabel alloc]initWithFrame:CGRectMake(IndexGap, 0, ScreenWidth - IndexGap, IndexHeight)];
        letterLabel.text = self.letters[section];
        letterLabel.textColor = [UIColor blackColor];
        [letterView addSubview:letterLabel];
        return letterView;
    } else {
        return nil;
    }
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return self.letters;
//}

- (void)brandCellViewClick:(BrandCellView *)brandCellView {
    
    CompareBrandDetailController *brandDetailVc = [[CompareBrandDetailController alloc]initWithBrandInfo:brandCellView.dataDict];
    
    brandDetailVc.view.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - NavViewHeight);
    
    
    [self.view addSubview:brandDetailVc.view];
    
    [self addChildViewController:brandDetailVc];
    
    [UIView animateWithDuration:0.3 animations:^{
        brandDetailVc.view.transform = CGAffineTransformMakeTranslation(0, - ScreenHeight + NavViewHeight);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:indexPath.row];
        [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
