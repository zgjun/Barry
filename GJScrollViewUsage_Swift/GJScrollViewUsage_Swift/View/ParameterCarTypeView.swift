//
//  ParameterCarTypeView.swift
//  GJScrollViewUsage_Swift
//
//  Created by zgjun on 15/9/22.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

import UIKit

extension UIImage {
    //类方法
   class func resizableImageWithName(imageName:String) -> UIImage {
        var image : UIImage = UIImage(named: imageName)!
        var imageSize : CGSize = image.size
        image = image.resizableImageWithCapInsets(UIEdgeInsetsMake(imageSize.height * 0.4, imageSize.width * 0.5, imageSize.height * 0.6, imageSize.width * 0.5))
        
        return image
    }
}

//portocol
protocol ParameterCarTypeViewDelegate {
    func parameterReduceBtnClick (carTypeView : ParameterCarTypeView)
    func parameterAddBtnClick (carTypeView: ParameterCarTypeView)
}



class ParameterCarTypeView: UIView {
    
    var imageView :UIImageView!
    var carTypeName:UILabel!
    var compareBtn:CompareButton!
    var reduceBtn:NoHighLightBtn!
    //delegate
    var delegate : ParameterCarTypeViewDelegate!
    
    var compareArrM:NSMutableArray {
        get {
            
            if NSMutableArray(contentsOfFile: self.getCompareCarsPlistPath()) == nil {
                return NSMutableArray.new()
            } else {
                
                return NSMutableArray(contentsOfFile: self.getCompareCarsPlistPath())!
            }
            
        }
    }
    
    
    var dataDict :NSDictionary! {
        
        /**
        1.didSet wrong :fatal error: unexpectedly found nil while unwrapping an Optional value
        2.willSet was right
        */
        
        willSet(newDataDict) {
            let carType : AnyObject? = newDataDict["carTypeName"]
            carTypeName.text = "\(carType!)"
            let tipLabelX:CGFloat = 0
            let tipLabelY:CGFloat = 0
            let maxSize:CGSize = CGSizeMake(self.bounds.size.width, CGFloat(MAXFLOAT))
            
            var tipStrTemp : AnyObject!
            var tipStr :NSString!
            
            
            
            if newDataDict["value"] == nil {
                tipStr = ""
            } else {
                tipStrTemp = newDataDict["value"]!
                tipStr = "\(tipStrTemp)"
            }
            
            let tipLabelSize: CGSize = tipStr.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
            
            carTypeName.frame = CGRectMake(tipLabelX, tipLabelY, tipLabelSize.width, tipLabelSize.height)
            
            if compareArrM.count > 0 {
                
                for i in 0 ... compareArrM.count - 1 {
                    let dict : NSDictionary = compareArrM[i] as! NSDictionary
                    if newDataDict["carTypeId"]?.integerValue == dict["carTypeId"]?.integerValue {
                        compareBtn.selected = true
                        break
                    }
                }
            }
            
        }
    }
    /**
    get path of the compareCars.plist
    
    :returns: the  file's path
    */
    func getCompareCarsPlistPath () -> String {
        let docDir :NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true) as NSArray
        var path :String = docDir.lastObject as! String
        path = path.stringByAppendingPathComponent("compareCars.plist")
        return path
    }
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView.new()
        imageView.userInteractionEnabled = true
        imageView.image = UIImage.resizableImageWithName("chexun_models_addbut_hengban")
        self.addSubview(imageView)
        
        carTypeName = UILabel.new()
        carTypeName.font = UIFont.systemFontOfSize(12)
        carTypeName.numberOfLines = -1
        carTypeName.textAlignment = NSTextAlignment.Center
        imageView.addSubview(carTypeName)
        
        compareBtn = CompareButton.new()
        compareBtn.setImage(UIImage(named: "chexun_pk_addicon"), forState: UIControlState.Normal)
        compareBtn.setImage(UIImage(named: "chexun_models_cancelicon"), forState: UIControlState.Selected)
        compareBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        compareBtn.setTitle("添加对比", forState: UIControlState.Normal)
        compareBtn.setTitle("取消对比", forState: UIControlState.Selected)
        compareBtn.imageView!.contentMode = UIViewContentMode.Center
        compareBtn.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        compareBtn.titleLabel!.font = UIFont.systemFontOfSize(15)
        compareBtn.addTarget(self, action: "compareBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        imageView.addSubview(compareBtn)
        
        reduceBtn = NoHighLightBtn.new()
        reduceBtn.setBackgroundImage(UIImage(named: "chexun_deletebut"), forState: UIControlState.Normal)
        reduceBtn.addTarget(self, action: "reduceBtnClick:", forControlEvents: UIControlEvents.TouchDown)
        self.addSubview(reduceBtn)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let selfWidth : CGFloat = self.bounds.size.width
        let selfHeight : CGFloat = self.bounds.size.height
        let gapWidth : CGFloat = 15
        imageView.frame = CGRectMake(0, 10, selfWidth - gapWidth, selfHeight - 10)
        carTypeName.frame = CGRectMake(0, 0, selfWidth - gapWidth, selfHeight * 0.6)
        compareBtn.frame = CGRectMake(0, selfHeight * 0.55, selfWidth, selfHeight * 0.4)
        reduceBtn.frame = CGRectMake(selfWidth - 25, 0, 23, 23)
    }
    
    
    
    
    func compareBtnClick (btn : CompareButton) {
        
        btn.selected = !btn.selected
        
        var compareTemp :NSMutableArray = NSMutableArray(array: compareArrM)
        
        if btn.selected == true {
            let carTypeId : NSString = dataDict["carTypeId"] as! NSString
            let carTypeName : NSString = dataDict["carTypeName"] as! NSString
            let carTypeImage : NSString = dataDict["carTypeImage"] as! NSString
            let carTypePrice : NSString = dataDict["carTypePrice"] as! NSString
            let carTypeLowPrice :NSString = dataDict["carTypeLowPrice"] as! NSString
            let carSeriesId : NSString = dataDict["carSeriesId"] as! NSString
            let carSeriesName : NSString = dataDict["carSeriesName"] as! NSString
            
            var carTypeInfo : NSDictionary = ["carTypeId":carTypeId,"carTypeName":carTypeName,"carTypeImage":carTypeImage,"carTypePrice":carTypePrice,"carTypeLowPrice":carTypeLowPrice,"compareState":"0","carSeriesId":carSeriesId,"carSeriesName":carSeriesName]
            
            compareTemp.addObject(carTypeInfo)
            
            if compareTemp.count == 0 {
                self.cleanCompareCars()
            } else {
                self.writeNewData(compareTemp)
            }
            
        } else {
            for i in 0 ... compareTemp.count - 1 {
                var dict = compareTemp[i] as! NSDictionary
                if dict["carTypeId"]?.integerValue == dataDict["carTypeId"]?.integerValue {
                    compareTemp.removeObject(dict)
                    if compareTemp.count == 0 {
                        self.cleanCompareCars()
                    } else {
                        self.writeNewData(compareTemp)
                    }
                    break
                }
            }
        }
        
        //inform delegage do 
        delegate.parameterAddBtnClick(self)
        
    }
    
    func reduceBtnClick (btn :NoHighLightBtn) {
        delegate.parameterReduceBtnClick(self)
    }
    
    /**
    clear cars
    */
    func cleanCompareCars () {
        var path :String = getCompareCarsPlistPath()
        
        let fileMgr : NSFileManager = NSFileManager.defaultManager()
        var bRet = fileMgr.fileExistsAtPath(path)
        if bRet {
            var err:NSErrorPointer!
            fileMgr.removeItemAtPath(path, error: err)
        }
        
    }
    /**
    write to the file
    
    :param: arr cars
    */
    func writeNewData(arr: NSArray) {
        var path :String = getCompareCarsPlistPath()
        arr.writeToFile(path, atomically: true)
    }
}
