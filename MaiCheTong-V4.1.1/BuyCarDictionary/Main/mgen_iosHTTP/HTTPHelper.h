//
//  HTTPHelper.h
//  HTTPHelper
//
//  Created by Mgen on 14-8-13.
//  Copyright (c) 2014年 Mgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPHelper : NSObject
//创建HTTP GET请求
+ (NSMutableURLRequest*)createGETRequest:(NSString*)url params:(NSDictionary*)params timeout:(NSTimeInterval)timeout;

//创建HTTP POST请求
+ (NSMutableURLRequest*)createPOSTRequest:(NSString*)url params:(NSDictionary*)params timeout:(NSTimeInterval)timeout;

//http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string/3426140#3426140
//对字符串进行URL编码
+ (NSString *)StringEncode:(NSString*)str;

//http://stackoverflow.com/questions/7920071/how-to-url-decode-in-ios-objective-c
//对字符串进行URL解码
+ (NSString *)StringDecode:(NSString*)str;

//URL编码
+ (NSString *)URLEncode:(NSString*)baseUrl data:(NSDictionary*)dictionary;

//URL解码
+ (NSArray *)URLDecode:(NSString *)url;
@end
