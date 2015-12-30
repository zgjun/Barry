//
//  BookChooseController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "BookChooseController.h"

@interface BookChooseController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UITableView *tableView;

@end

@implementation BookChooseController

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
    self.navigationItem.title = @"预约";
    
    self.view.backgroundColor = MainBackGroundColor;
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -20;
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_home_backarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, backItem];
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 88 + 64)];
    tableView.scrollEnabled = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.showsVerticalScrollIndicator = NO;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"OnlyBookCell"];
    [self.view addSubview:tableView];
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"OnlyBookCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"预约试驾";
    } else {
        cell.textLabel.text = @"预约保养";
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedName;
    if (indexPath.row == 0) {
        selectedName = @"预约试驾";
    } else {
        selectedName = @"预约保养";
    }
    
    if ([self.delegate respondsToSelector:@selector(bookChooseSelected:)]) {
        [self.delegate bookChooseSelected:selectedName];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}



@end
