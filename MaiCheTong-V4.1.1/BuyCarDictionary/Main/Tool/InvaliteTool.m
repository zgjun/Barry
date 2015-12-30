//
//  InvaliteTool.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-28.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "InvaliteTool.h"
#import <CommonCrypto/CommonDigest.h>

@implementation InvaliteTool

+ (BOOL)checkTel:(NSString *)str

{
    
    if ([str length] == 0) {
        
        return NO;
        
    }
    
    //1[0-9]{10}
    
    //^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$
    
    //    NSString *regex = @"[0-9]{11}";
    
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:str];
    
    if (!isMatch) {
        
        return NO;
    }
    
    return YES;
    
}


+ (NSString *)md5Digest:(NSString *)OrgString {
    
    const char *cStr = [OrgString UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, strlen(cStr), result);
    
    return [NSString stringWithFormat:
            
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            
            ];
    
}

@end
