//
//  TimeTool.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-2.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "TimeTool.h"

@implementation TimeTool


+ (NSString *)returnSampleTime:(NSString *)timeStr {
    NSArray *timeArr = [timeStr componentsSeparatedByString:@"-"];
    NSInteger year = [timeArr[0] integerValue];
    NSInteger month = [timeArr[1] integerValue];
    NSInteger day = [timeArr[2] integerValue];
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    NSInteger nowYear = [comps year];
    NSInteger nowMonth = [comps month];
    NSInteger nowDay = [comps day];
    
    if (nowYear > year || nowMonth > month) {
        return @"10天前";
    } else if (nowDay - day > 10) {
        return @"10天前";
    } else if (nowDay - day == 0){
        return @"今天";
    } else {
        return [NSString stringWithFormat:@"%li天前",nowDay - day];
    }
}


+ (NSString *)returnStringTime:(NSString *)timeStr {
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSDate *date=[dateFormat dateFromString:timeStr];
    
    NSDate *currentDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *coms = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond  fromDate:date toDate:currentDate options:0];
    NSInteger nowYear = [coms year];
    NSInteger nowMonth = [coms month];
    NSInteger nowDay = [coms day];
    NSInteger nowHour = [coms hour];
    NSInteger nowMinute = [coms minute];
//    NSInteger nowSecond = [coms second];
    
    if (nowYear > 0 || nowMonth > 0 || nowDay > 10) {
        return @"10天前";
    }
    
    if (nowDay <= 10 && nowDay > 0) {
        return [NSString stringWithFormat:@"%li天前",nowDay];
    }
    
    if (nowHour > 0) {
        return [NSString stringWithFormat:@"%li小时前",nowHour];
    }
    
    if (nowMinute > 5 && nowMinute <= 60) {
        return [NSString stringWithFormat:@"%li分钟前",nowMinute];
    }
    
    return @"刚刚";
}


+ (NSString *)returnRemainTime:(NSString *)timeStr

{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    
    [date setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSDate *d=[date dateFromString:timeStr];
    
    
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    
    
    NSString *timeString;
    
    
    
    NSTimeInterval cha=late-now;
    
    
    if (cha/3600<1) {
        
        NSString *timeString1 = [NSString stringWithFormat:@"%d", (int)cha/60];
        
        timeString=[NSString stringWithFormat:@"0天0时%@分", timeString1];
        
    }
    
    if (cha/3600>1&&cha/86400<1) {
        
        NSString *timeString1 = [NSString stringWithFormat:@"%d", (int)cha/3600];
        
        NSString *timeString2 = [NSString stringWithFormat:@"%d", ((int)cha%3600)/60];
        
        
        
        timeString=[NSString stringWithFormat:@"0天%@时%@分",timeString1,timeString2];
        
    }
    
    if (cha/86400>1)
        
    {
        
        NSString *timeString1 = [NSString stringWithFormat:@"%d", (int)cha/86400];
        
        NSString *timeString2 = [NSString stringWithFormat:@"%d", ((int)cha%86400)/3600];
        
        NSString *timeString3 = [NSString stringWithFormat:@"%d", (((int)cha%86400)%3600)/60];
        
        timeString=[NSString stringWithFormat:@"%@天%@时%@分",timeString1,timeString2,timeString3];
        
    }
    
    return timeString;
    
}

@end
