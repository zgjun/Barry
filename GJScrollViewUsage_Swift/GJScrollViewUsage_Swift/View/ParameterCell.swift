//
//  ParameterCell.swift
//  GJScrollViewUsage_Swift
//
//  Created by zgjun on 15/9/24.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

import UIKit

class ParameterCell: UIView {
    
    let mainBackGroundColor : UIColor = UIColor(red: (232.0 / 255.0), green: (233.0 / 255.0), blue: (235.0 / 255.0), alpha: 1.0)
    let mainGoldenColor : UIColor = UIColor(red: (230.0 / 255.0), green: (185.0 / 255.0), blue: (44.0 / 255.0), alpha: 1.0)
    var contentStr : String! {
        set(newContentStr) {
            showTitle.text = newContentStr
            let tipLabelX : CGFloat = 0.0
            let tipLabelY : CGFloat = 0.0
            let maxSize : CGSize = CGSizeMake(self.bounds.size.width, CGFloat(MAXFLOAT))
            let contentStrTemp : NSString = newContentStr as NSString
            let tipLabelSize : CGSize = contentStrTemp.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(12.0)])
            showTitle.frame = CGRectMake(tipLabelX, tipLabelY, tipLabelSize.width, tipLabelSize.height)
        }
        get {
            return self.contentStr
        }
    }
    var isAll : Bool! {
        set(newIsAll) {
            if newIsAll == true {
                showTitle.textColor = mainGoldenColor
            } else {
                showTitle.textColor = UIColor.blackColor()
            }
            
            if indicator == "title" {
                showTitle.textColor = UIColor.blackColor()
            }
        }
        get {
            return self.isAll
        }
    }
    var indicator : String!
    
    //views
    var showTitle : UILabel!
    var rightLine : UIView!
    var bottomLine : UIView!
    
    var selfWidth : CGFloat!
    var selfHeight : CGFloat!
    
    
    init(Frame frame: CGRect,IndicatorNew indicatorNew : String) {
        super.init(frame: frame)
        indicator = indicatorNew
        showTitle = UILabel.new()
        showTitle.textAlignment = NSTextAlignment.Center
        showTitle.font = UIFont.systemFontOfSize(12)
        showTitle.numberOfLines = -1
        self.addSubview(showTitle)
        
        rightLine = UIView.new()
        rightLine.backgroundColor = mainBackGroundColor
        self.addSubview(rightLine)
        
        bottomLine = UIView.new()
        bottomLine.backgroundColor = mainBackGroundColor
        self.addSubview(bottomLine)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
        
        showTitle.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        rightLine.frame = CGRectMake(self.bounds.size.width - 1, 0, 1, self.bounds.size.height);
        bottomLine.frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
    }
    
}
