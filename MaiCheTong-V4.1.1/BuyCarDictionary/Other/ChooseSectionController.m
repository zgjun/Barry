//
//  ChooseSectionController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-14.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "ChooseSectionController.h"

@interface ChooseSectionController ()

@property (nonatomic,strong) NSArray *sectionArr;

@end

@implementation ChooseSectionController

- (instancetype)initWithSectionArr:(NSArray *)sectionArr {
    if (self = [super init]) {
        self.sectionArr = sectionArr;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ChooseSectionCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ChooseSectionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    NSDictionary *dict = self.sectionArr[indexPath.row];
    
    cell.textLabel.text = dict[@"NAME"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.sectionArr[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(chooseSectionClick:)]) {
        [self.delegate chooseSectionClick:dict[@"ID"]];
    }
}
- (void)dealloc {
    
    MyLog(@"%s",__FILE__);
    
}

@end
