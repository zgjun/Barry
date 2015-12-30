//
//  CalculateTool.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-3-20.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "CalculateTool.h"

@implementation CalculateTool

+ (NSDictionary *)calculateTax:(CGFloat)pureValue taxDictM:(NSMutableDictionary *)taxDictM{
    //设置各种税的初始值
    CGFloat buyTax = ((pureValue * 10000) / 1.17) * 0.1;
    CGFloat invaliteTax = 500;
    CGFloat carUseTax;
    if ([taxDictM[@"carShipValueSort"] integerValue] == 0) {
        carUseTax = 480;//各省不统一，北京9座及以下客车480元/年
    } else {
        carUseTax = 540;//各省不统一，9座以上客车540元/年
    }
    CGFloat trafficTax;
    if ([taxDictM[@"trafficValueSort"] integerValue] == 0) {
        trafficTax = 950;//家用6座以下为950元/年
    } else {
        trafficTax = 1100;//家用6座以上为1100元/年
    }
    
    CGFloat allTax = buyTax + invaliteTax + carUseTax + trafficTax;
    
    NSDictionary *taxDict = @{@"buyTax":@(buyTax),@"invaliteTax":@(invaliteTax),@"carUseTax":@(carUseTax),@"trafficTax":@(trafficTax),@"allTax":@(allTax)};
    
    
    return taxDict;
}


+ (NSDictionary *)calculateInsurance:(CGFloat)pureValue insureDictM:(NSMutableDictionary *)insureDictM familySites:(NSInteger)familySites {
    //设置各项商业保险
    CGFloat thirdInsurance;
    if (familySites == 0) {
        switch ([insureDictM[@"thirdValueSort"] integerValue]) {
            case 0://5万元
                thirdInsurance = 801;
                break;
            case 1://10万元
                thirdInsurance = 971;
                break;
            case 2://20万元
                thirdInsurance = 1120;
                break;
            case 3://50万元
                thirdInsurance = 1293;
                break;
            case 4://100万元
                thirdInsurance = 1412;
                break;
            default:
                thirdInsurance = 801;
                break;
        }
    } else {
        switch ([insureDictM[@"thirdValueSort"] integerValue]) {
            case 0://5万元
                thirdInsurance = 685;
                break;
            case 1://10万元
                thirdInsurance = 831;
                break;
            case 2://20万元
                thirdInsurance = 958;
                break;
            case 3://50万元
                thirdInsurance = 1106;
                break;
            case 4://100万元
                thirdInsurance = 1208;
                break;
            default:
                thirdInsurance = 685;
                break;
        }
    }
    
    
    CGFloat loseInsurance = (pureValue * 10000) * 0.012;
    CGFloat carStealInsurance = (pureValue * 10000) * 0.01;
    //进口新车购置价x0.25%，国产新车购置价x0.15%
    CGFloat glassInsurance;
    if ([insureDictM[@"glassValueSort"] integerValue] == 0) {
         glassInsurance = (pureValue * 10000) * 0.0015;
    } else {
         glassInsurance = (pureValue * 10000) * 0.0025;
    }
    CGFloat burnInsurance = (pureValue * 10000) * 0.0015;
    CGFloat ingnoreInsurance;
    if ([insureDictM[@"thirdShow"] integerValue] == 1 && [insureDictM[@"loseShow"] integerValue] == 1 ) {
        ingnoreInsurance = (loseInsurance + thirdInsurance) * 0.2;
    } else if ([insureDictM[@"thirdShow"] integerValue] == 0 && [insureDictM[@"loseShow"] integerValue] == 1 ) {
        ingnoreInsurance = loseInsurance * 0.2;
    } else if ([insureDictM[@"thirdShow"] integerValue] == 1 && [insureDictM[@"loseShow"] integerValue] == 0 ) {
        ingnoreInsurance = thirdInsurance * 0.2;
    } else {
        ingnoreInsurance = 0;
    }

    CGFloat carPeopleInsurance = 50;
    CGFloat scratchInsurance  = 400;//赔付金额2千
    if (pureValue < 30) {
        switch ([insureDictM[@"scratchValueSort"] integerValue]) {
            case 0:
                scratchInsurance = 400;
                break;
            case 1:
                scratchInsurance = 570;
                break;
            case 2:
                scratchInsurance = 760;
                break;
            case 3:
                scratchInsurance = 1140;
                break;
            default:
                break;
        }
    } else if (pureValue > 50) {
        switch ([insureDictM[@"scratchValueSort"] integerValue]) {
            case 0:
                scratchInsurance = 850;
                break;
            case 1:
                scratchInsurance = 1100;
                break;
            case 2:
                scratchInsurance = 1500;
                break;
            case 3:
                scratchInsurance = 2250;
                break;
            default:
                break;
        }
    } else {
        switch ([insureDictM[@"scratchValueSort"] integerValue]) {
            
            case 0:
                scratchInsurance = 585;
                break;
            case 1:
                scratchInsurance = 900;
                break;
            case 2:
                scratchInsurance = 1170;
                break;
            case 3:
                scratchInsurance = 1780;
                break;
            default:
                break;
        }
    }
    
    CGFloat noWrongInsurance;
    if ([insureDictM[@"thirdShow"] integerValue] == 1) {
        noWrongInsurance = thirdInsurance * 0.2;//无过责任险：第三者责任险*0.2
    } else {
        noWrongInsurance = 0;
    }

    CGFloat allInsurance = 0;
    if ([insureDictM[@"thirdShow"] integerValue] == 1) {
        allInsurance = allInsurance + thirdInsurance;
    }
    if ([insureDictM[@"loseShow"] integerValue] == 1) {
        allInsurance = allInsurance + loseInsurance;
    }
    if ([insureDictM[@"carStealShow"] integerValue] == 1) {
        allInsurance = allInsurance + carStealInsurance;
    }
    if ([insureDictM[@"glassShow"] integerValue] == 1) {
        allInsurance = allInsurance + glassInsurance;
    }
    if ([insureDictM[@"burnShow"] integerValue] == 1) {
        allInsurance = allInsurance + burnInsurance;
    }
    if ([insureDictM[@"ingnoreShow"] integerValue] == 1) {
        allInsurance = allInsurance + ingnoreInsurance;
    }
    if ([insureDictM[@"carPeopleShow"] integerValue] == 1) {
        allInsurance = allInsurance + carPeopleInsurance;
    }
    if ([insureDictM[@"scratchShow"] integerValue] == 1) {
        allInsurance = allInsurance + scratchInsurance;
    }
    if ([insureDictM[@"noWrongShow"] integerValue] == 1) {
        allInsurance = allInsurance + noWrongInsurance;
    }
    
//    
//    allInsurance = thirdInsurance + loseInsurance + carStealInsurance + glassInsurance + burnInsurance + ingnoreInsurance + carPeopleInsurance + scratchInsurance + noWrongInsurance;
    
    NSDictionary *insuranceDict = @{@"thirdInsurance":@(thirdInsurance),@"loseInsurance":@(loseInsurance),@"carStealInsurance":@(carStealInsurance),@"glassInsurance":@(glassInsurance),@"burnInsurance":@(burnInsurance),@"ingnoreInsurance":@(ingnoreInsurance),@"carPeopleInsurance":@(carPeopleInsurance),@"scratchInsurance":@(scratchInsurance),@"noWrongInsurance":@(noWrongInsurance),@"allInsurance":@(allInsurance)};
    
    return insuranceDict;
    
}

@end
