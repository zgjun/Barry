//
//  NSString+hash.h
//  BuyCarDictionary
//
//  Created by zgjun on 14-11-25.
//  Copyright (c) 2014年 chexun. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (Hash)

@property (readonly) NSString *md5String;
@property (readonly) NSString *sha1String;
@property (readonly) NSString *sha256String;
@property (readonly) NSString *sha512String;

- (NSString *)hmacSHA1StringWithKey:(NSString *)key;
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

@end
