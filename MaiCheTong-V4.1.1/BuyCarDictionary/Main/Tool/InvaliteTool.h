//
//  InvaliteTool.h
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-28.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvaliteTool : NSObject

+ (BOOL)checkTel:(NSString *)str;

+ (NSString *)md5Digest:(NSString *)OrgString;

@end
