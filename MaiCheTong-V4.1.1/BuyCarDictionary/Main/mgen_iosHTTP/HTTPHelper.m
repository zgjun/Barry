//
//  HttpHelper.m
//  HTTPHelper
//
//  Created by Mgen on 14-4-20.
//  Copyright (c) 2014年 Mgen. All rights reserved.
//
#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "HTTPHelper.h"

@implementation HTTPHelper

#pragma mark -
#pragma mark 创建NSURLRequest

+ (NSURLRequest*)createGETRequest:(NSString*)url params:(NSDictionary*)params timeout:(NSTimeInterval)timeout
{
    if(!url.length)
        return nil;
    
    NSString *queryUrl = [self URLEncode:url data:params];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
    [request setHTTPMethod:@"GET"];
    return request;
}

+ (NSURLRequest*)createPOSTRequest:(NSString*)url params:(NSDictionary*)params timeout:(NSTimeInterval)timeout
{
    NSString *queryString = [self URLEncode:nil data:params];
    NSData *contentData = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    return [self createPOSTRequest:url content:contentData contentType:@"application/x-www-form-urlencoded" timeout:timeout];
}

+ (NSURLRequest*)createPOSTRequest:(NSString*)url content:(NSData*)content contentType:(NSString*)contentType timeout:(NSTimeInterval)timeout
{
    if(!url.length)
        return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
    [request setHTTPMethod:@"POST"];
    
    if(contentType.length)
    {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)content.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:content];
    return request;
}

#pragma mark -
#pragma mark URL

+ (NSString *)StringEncode:(NSString*)str
{
    if (!str.length)
        return str;
    
    NSMutableString * output = [NSMutableString string];
    const char * source = (const char *)[str UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (NSString *)StringDecode:(NSString*)str
{
    if (!str.length)
        return str;
    return [[str stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)URLEncode:(NSString*)baseUrl data:(NSDictionary*)dictionary
{
    NSString *url = baseUrl;
    if(url.length)
    {
        url = [url stringByAppendingString:@"?"];
    }
    else
    {
        url = @"";
    }
    
    BOOL isFirst = YES;
    for(NSString *key in dictionary.allKeys)
    {
        if(isFirst)
        {
            isFirst = NO;
        }
        else
        {
            url = [url stringByAppendingString:@"&"];
        }
        url = [url stringByAppendingFormat:@"%@=%@", [NSString stringWithFormat:@"%@", [self StringEncode:key]], [self StringEncode:[NSString stringWithFormat:@"%@", [dictionary objectForKey:key]]]];
    }
    return url;
}

+ (NSArray *)URLDecode:(NSString *)url
{
    NSRange range = [url rangeOfString:@"?"];
    if(range.location == NSNotFound)
    {
        return @[url, [NSNull null]];
    }
    
    NSString *baseUrl = [url substringToIndex:range.location - 1];
    NSString *dataUrl = [url substringFromIndex:range.location + 1];
    
    NSArray *parameters = [dataUrl componentsSeparatedByString:@"&"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:parameters.count];
    for(NSString *pa in parameters)
    {
        NSArray *pair = [pa componentsSeparatedByString:@"="];
        NSString *key = [self StringDecode:[pair objectAtIndex:0]];
        NSString *val = [self StringDecode:[pair objectAtIndex:1]];
        
        [dic setValue:val forKey:key];
    }
    return @[baseUrl, dic];
}


@end
