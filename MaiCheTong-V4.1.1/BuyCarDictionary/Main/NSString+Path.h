//
//  NSString+Path.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Path)

/** 文档目录 */
+ (NSString *)documentPath;
/** 缓存目录 */
+ (NSString *)cachePath;
/** 临时目录 */
+ (NSString *)tempPath;

/**
 *  添加文档路径
 */
- (NSString *)appendDocumentPath;
/**
 *  添加缓存路径
 */
- (NSString *)appendCachePath;
/**
 *  添加临时路径
 */
- (NSString *)appendTempPath;
@end
