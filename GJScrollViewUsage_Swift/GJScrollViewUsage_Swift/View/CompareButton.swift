//
//  CompareButton.swift
//  GJScrollViewUsage_Swift
//
//  Created by zgjun on 15/9/22.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

import UIKit

class CompareButton: UIButton {

    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
         return CGRectMake(0.3 * contentRect.size.width, 0, 0.7 * contentRect.size.width, contentRect.size.height);
    }
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
         return CGRectMake(0, 0, 0.3 * contentRect.size.width, contentRect.size.height);
    }
}
