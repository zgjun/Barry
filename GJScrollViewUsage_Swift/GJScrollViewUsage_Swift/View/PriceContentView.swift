//
//  PriceContentView.swift
//  GJScrollViewUsage_Swift
//
//  Created by zgjun on 15/9/22.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

import UIKit

class PriceContentView: UIView {
    
    let ScreenWidth = UIScreen.mainScreen().bounds.size.width
    let ScreenHeight = UIScreen.mainScreen().bounds.size.height
    let mainBackGroundColor : UIColor = UIColor(red: (232.0 / 255.0), green: (233.0 / 255.0), blue: (235.0 / 255.0), alpha: 1.0)
    let mainFontRedColor : UIColor = UIColor(red: (229.0 / 255.0), green: (89.0 / 255.0), blue: (84.0 / 255.0), alpha: 1.0)
    
    
    var companyPrice :UILabel!
    var gobalLowPrice : UILabel!

    var dataDict : NSDictionary! {
        set(newDataDict) {
            companyPrice.text = newDataDict["companyPrice"] as? String
            gobalLowPrice.text = newDataDict["lowPrice"] as? String
        }
        
        get {
            return self.dataDict
        }
    }
    
    override init(frame: CGRect) {
        
        let PriceCellWidth : CGFloat = (ScreenWidth - 80) * 0.5
        
        super.init(frame:frame)
        
        var topLine : UIView = UIView(frame: CGRectMake(0, 0, PriceCellWidth, 1))
        topLine.backgroundColor = mainBackGroundColor
        self.addSubview(topLine)
        
        companyPrice = UILabel(frame: CGRectMake(0, 0, PriceCellWidth, 30))
        companyPrice.textAlignment = NSTextAlignment.Center
        companyPrice.font = UIFont.systemFontOfSize(12)
        self.addSubview(companyPrice)
        
        var centerLine :UIView = UIView(frame: CGRectMake(0, 29, PriceCellWidth, 1))
        centerLine.backgroundColor = mainBackGroundColor
        self.addSubview(centerLine)
        
        gobalLowPrice = UILabel(frame: CGRectMake(0, 30, PriceCellWidth, 30))
        gobalLowPrice.textAlignment = NSTextAlignment.Center
        gobalLowPrice.font = UIFont.systemFontOfSize(12)
        gobalLowPrice.textColor = mainFontRedColor
        self.addSubview(gobalLowPrice)
        
        var bottomLine : UIView = UIView(frame: CGRectMake(0, 59, PriceCellWidth, 1))
        bottomLine.backgroundColor = mainBackGroundColor
        self.addSubview(bottomLine)
        
        var upRightLine : UIView = UIView(frame: CGRectMake(PriceCellWidth - 1, 0, 1, 30))
        upRightLine.backgroundColor = mainBackGroundColor
        self.addSubview(upRightLine)
        
        var downRightLine : UIView = UIView(frame: CGRectMake(PriceCellWidth - 1, 30, 1, 30))
        downRightLine.backgroundColor = mainBackGroundColor
        self.addSubview(downRightLine)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
