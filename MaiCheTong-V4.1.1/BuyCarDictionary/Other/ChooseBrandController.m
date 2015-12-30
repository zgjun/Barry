//
//  ChooseBrandController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ChooseBrandController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+GJ.h"

#define IndexHeight 20
#define IndexGap 10

@interface ChooseBrandController ()

@property (nonatomic,strong) NSArray *brandArrays;

@property (nonatomic,strong) NSString *letterStr;

@property (nonatomic,strong) NSArray *letters;

@end

@implementation ChooseBrandController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getData];
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = @"http://api.tool.chexun.com/mobile/buyCarBrands.do";
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    __weak ChooseBrandController *myself = self;
    
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
        
        myself.brandArrays = sections;
        
        [myself.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:myself.tableView animated:YES];
        [MBProgressHUD showError:@"数据加载异常"];
        return;
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.brandArrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.brandArrays[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ChooseBrandCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    NSDictionary *dict = self.brandArrays[indexPath.section][indexPath.row];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:dict[@"imagePath"]] placeholderImage:[UIImage imageNamed:@"load0"]];
    
    cell.textLabel.text = dict[@"name"];
    return cell;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return IndexHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *letterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, IndexHeight)];
    letterView.backgroundColor = MainBackGroundColor;
    UILabel *letterLabel = [[UILabel alloc]initWithFrame:CGRectMake(IndexGap, 0, ScreenWidth - IndexGap, IndexHeight)];
    letterLabel.text = self.letters[section];
    letterLabel.textColor = [UIColor blackColor];
    [letterView addSubview:letterLabel];
    return letterView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.brandArrays[indexPath.section][indexPath.row];
    if ([self.delegate respondsToSelector:@selector(chooseBrandClick:)]) {
        [self.delegate chooseBrandClick:dict[@"id"]];
    }
}

- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}
@end
