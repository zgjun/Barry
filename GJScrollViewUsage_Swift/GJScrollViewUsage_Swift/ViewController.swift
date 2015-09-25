//
//  ViewController.swift
//  GJScrollViewUsage_Swift
//
//  Created by zgjun on 15/9/21.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,ParameterCarTypeViewDelegate {
    
    let WrongNum : Int = -1000
    let ScreenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let ScreenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    let TitleBarWidth : CGFloat = 80.0
    let TopViewHeight : CGFloat = 110.0
    let NavBarHeight : CGFloat = 64
    let mainBackGroundColor : UIColor = UIColor(red: (232.0 / 255.0), green: (233.0 / 255.0), blue: (235.0 / 255.0), alpha: 1.0)
    let mainFontRedColor : UIColor = UIColor(red: (229.0 / 255.0), green: (89.0 / 255.0), blue: (84.0 / 255.0), alpha: 1.0)
    let CarTypeHeight : CGFloat = 90.0
    let CellWidth : CGFloat = (UIScreen.mainScreen().bounds.size.width - 80.0) * 0.5
    let Price_CarTypeHeight : CGFloat = 45.0
    let BottomViewHeight : CGFloat = (UIScreen.mainScreen().bounds.size.height - 110.0 - 64.0)
    let SectionHeight : CGFloat = 20.0
    let CellHeight : CGFloat = 45.0
    let BigCellHeight : CGFloat = 60.0
    
    var showIndicator : Int! = 0
    
    
    var carSeriesDict :Dictionary<String,String>!
    var carTypeCount :Int!
    
    //views
    var navView :UIView!
    var screenBtn:UIButton!
    var hiddenBtn:NoHighLightBtn!
    var showBtn:NoHighLightBtn!
    var carTypeScrollView:ParameterScrollView!
    var carTypeView:UIView!
    var headPriceView:UIView!
    var headPriceScrollView : ParameterScrollView!
    var contentPriceView : UIView!
    var bottomView : UIView!
    var navTableView : ParameterTableView!
    var contentTableView : ParameterTableView!
    var indicatorBtn : NoHighLightBtn!
    var contentScrollView : ParameterScrollView!
    
    /*
    @property (nonatomic,strong) NSMutableArray *contentData;
    @property (nonatomic,strong) NSMutableArray *contentDifData;
    @property (nonatomic,strong) NSMutableArray *compareCars;
    @property (nonatomic,strong) NSMutableArray *showLabels;
    @property (nonatomic,assign) NSInteger carTypeCount;
    **/
    //data
    var contentData : NSMutableArray!
    var contentDifData : NSMutableArray!
    var compareCars : NSMutableArray! {
        get {
            if NSMutableArray(contentsOfFile: getCompareCarsPlistPath()) == nil {
                return NSMutableArray.new()
            } else {
                
                return NSMutableArray(contentsOfFile: getCompareCarsPlistPath())
            }
        }
    }
    var showLabels : NSMutableArray!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize setting
        self.view.backgroundColor = UIColor.grayColor();
        carSeriesDict =  ["carSeriesId" : "107",
            "carSeriesImg" : "http://i0.chexun.net/images/2014/1218/16574/car_750_500_1663025456503F2AEF6BFFB14486BCD1.jpg",
            "carSeriesName" : "高尔夫"]
        carTypeCount = WrongNum
        //create childViews
        self.createChildViews()
        //load data
        self.loadData()
        
        
    }
    /**
    create viewChildViews
    */
    func createChildViews () {
        //create head view
        self.createHeadView()
        //create content index view
        self.createContentIndexView()
        //create content view
        self.createContentView()
        //create other views
        self.createOtherViews()
        
        
    }
    
    func createHeadView () {
        //head view
        navView = UIView.new()
        navView.frame = CGRectMake(0, 0, ScreenWidth, 64)
        navView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(navView)
        //create right button
        screenBtn = UIButton.new()
        screenBtn.frame = CGRectMake(ScreenWidth - 44, 20 + 4, 35, 35)
        screenBtn.setImage(UIImage(named: "chexun_menuicon_black"), forState: UIControlState.Normal)
        screenBtn.setImage(UIImage(named:"chexun_closeicon_gray"), forState: UIControlState.Selected)
        screenBtn.addTarget(self, action: "screenBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        navView.addSubview(screenBtn)
        
        //create hide and show buttons
        var titleView :UIImageView = UIImageView.new()
        titleView.userInteractionEnabled = true
        
        titleView.frame = CGRectMake((ScreenWidth - 188) * 0.5, 27, 188, 30)
        titleView.image = UIImage(named: "chexun_models_tabbg")
        navView.addSubview(titleView)
        
        //hide button
        hiddenBtn = NoHighLightBtn.new()
        hiddenBtn.frame = CGRectMake(0, 0.5, 94, 29)
        hiddenBtn.tag = 1
        hiddenBtn.setTitle("隐藏相同", forState: UIControlState.Normal)
        hiddenBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        hiddenBtn.setTitleColor(UIColor(red: (203.0 / 255.0), green: (205.0 / 255.0), blue:(208.0 / 255.0), alpha: 1.0), forState: UIControlState.Normal)
        hiddenBtn.setBackgroundImage(UIImage(named: "chexun_models_tableft_selected"), forState: UIControlState.Selected)
        hiddenBtn.titleLabel!.textAlignment = NSTextAlignment.Center
        hiddenBtn.addTarget(self, action: "showOrHiddenClick:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(hiddenBtn)
        
        //show button
        showBtn = NoHighLightBtn.new()
        showBtn.frame = CGRectMake(94, 0.5, 94, 29)
        showBtn.tag = 2
        showBtn.titleLabel!.textAlignment = NSTextAlignment.Center
        showBtn.setBackgroundImage(UIImage(named: "chexun_models_tabright_selected"), forState: UIControlState.Selected)
        showBtn.setTitle("显示全部", forState: UIControlState.Normal)
        showBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        showBtn.setTitleColor(UIColor(red: (203.0 / 255.0), green: (205.0 / 255.0), blue:(208.0 / 255.0), alpha: 1.0), forState: UIControlState.Normal)
        showBtn.addTarget(self, action: "showOrHiddenClick:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(showBtn)
        
        //initialize selected button
        showBtn.selected = true
        
        
        //create a splite line
        var spliteLine = UIView.new()
        spliteLine.frame = CGRectMake(0, 63, ScreenWidth, 1)
        spliteLine.backgroundColor = UIColor(red: (203.0 / 255.0), green: (205.0 / 255.0), blue:(208.0 / 255.0), alpha: 1.0)
        navView.addSubview(spliteLine)
    
    }
    
    func createContentIndexView () {
        var topView :UIView! = UIView.new()
        topView.frame = CGRectMake(0, NavBarHeight, ScreenWidth, TopViewHeight)
        topView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(topView)
        
        
        var parameterView = UIView.new()
        parameterView.frame = CGRectMake(0.0, 0.0, TitleBarWidth, TopViewHeight)
        topView.addSubview(parameterView)
        
        var parameterLabel = UILabel.new()
        parameterLabel.frame = CGRectMake(10, 10, 60, 80)
        parameterLabel.numberOfLines = -1
        parameterLabel.font = UIFont.systemFontOfSize(16)
        parameterLabel.textAlignment = NSTextAlignment.Center
        parameterLabel.text = "车型\n配置表"
        parameterView.addSubview(parameterLabel)
        
        carTypeScrollView = ParameterScrollView.new()
        carTypeScrollView.frame = CGRectMake(TitleBarWidth, 5, ScreenWidth - TitleBarWidth, TopViewHeight - 20)
        carTypeScrollView.showsHorizontalScrollIndicator = false
        carTypeScrollView.delegate = self
        carTypeScrollView.bounces = false
        carTypeScrollView.indicatorStr = "carType"
        carTypeScrollView.backgroundColor = UIColor.whiteColor()
        topView.addSubview(carTypeScrollView)
        
        carTypeView = UIView.new()
        carTypeScrollView.addSubview(carTypeView)
        
        //initialize views
        for i in 0...1 {
            
            var paraCarView : ParameterCarTypeView = ParameterCarTypeView(frame: CGRectMake(CGFloat(i) * CellWidth, 0, CellWidth, CarTypeHeight))
            
            carTypeView.addSubview(paraCarView)
        }
        
        //lowest price and company price
        headPriceView = UIView(frame: CGRectMake(0, CGRectGetMaxY(topView.frame), ScreenWidth, 60))
        headPriceView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(headPriceView)
        
        headPriceScrollView = ParameterScrollView(frame: CGRectMake(TitleBarWidth, 0, ScreenWidth - TitleBarWidth, 60))
        headPriceScrollView.bounces = false
        headPriceScrollView.showsHorizontalScrollIndicator = false
        headPriceScrollView.delegate = self
        headPriceScrollView.indicatorStr = "headPrice"
        headPriceView.addSubview(headPriceScrollView)
        
        contentPriceView = UIView.new()
        headPriceScrollView.addSubview(contentPriceView)
        
        var topLine : UIView = UIView(frame: CGRectMake(0, 0, TitleBarWidth, 1))
        topLine.backgroundColor = mainBackGroundColor
        headPriceView.addSubview(topLine)
        
        var companyPrice : UILabel = UILabel(frame: CGRectMake(0, 0, TitleBarWidth, 30))
        companyPrice.textAlignment = NSTextAlignment.Center
        companyPrice.text = "厂商指导价"
        companyPrice.font = UIFont.systemFontOfSize(12)
        headPriceView.addSubview(companyPrice)
        
        var centerLine : UIView = UIView(frame: CGRectMake(0, 29, TitleBarWidth, 1))
        centerLine.backgroundColor = mainBackGroundColor
        headPriceView.addSubview(centerLine)
        
        var gobalLowPrice : UILabel = UILabel(frame: CGRectMake(0, 30, TitleBarWidth, 30))
        gobalLowPrice.textAlignment = NSTextAlignment.Center
        gobalLowPrice.text = "全国最低价"
        gobalLowPrice.font = UIFont.systemFontOfSize(12)
        gobalLowPrice.textColor = mainFontRedColor
        headPriceView.addSubview(gobalLowPrice)
        
        let PriceCellWidth : CGFloat = (ScreenWidth - 80) * 0.5
        
        //initialize views
        for i in 0 ... 1 {
            var priceContenView : PriceContentView = PriceContentView.new()
            priceContenView.tag = i
            priceContenView.frame = CGRectMake(CGFloat(i) * CellWidth, 0, CellWidth, CarTypeHeight)
            contentPriceView.addSubview(priceContenView)
        }
        
        var bottomLine : UIView = UIView(frame: CGRectMake(0, 59, TitleBarWidth, 1))
        bottomLine.backgroundColor = mainBackGroundColor
        headPriceView.addSubview(bottomLine)
        
        var upRightLine : UIView = UIView(frame: CGRectMake(TitleBarWidth - 1, 0, 1, 30))
        upRightLine.backgroundColor = mainBackGroundColor
        headPriceView.addSubview(upRightLine)
        
        var downRightLine : UIView = UIView(frame: CGRectMake(TitleBarWidth - 1, 30, 1, 30))
        downRightLine.backgroundColor = mainBackGroundColor
        headPriceView.addSubview(downRightLine)
        
    }
    
    func createContentView() {
        bottomView = UIView(frame:CGRectMake(0, CGRectGetMaxY(headPriceView.frame), ScreenWidth, BottomViewHeight))
        bottomView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(bottomView)
        
        navTableView = ParameterTableView(frame: CGRectMake(0, 0, TitleBarWidth, BottomViewHeight))
        navTableView.indicatorId = "title"
        navTableView.showsVerticalScrollIndicator = false
        navTableView.bounces = false
        //register table cell
        navTableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "NavTableCell")
        navTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        navTableView.dataSource = self
        navTableView.delegate = self
        bottomView.addSubview(navTableView)
        
        contentScrollView  = ParameterScrollView(frame: CGRectMake(TitleBarWidth, 0, ScreenWidth - TitleBarWidth, BottomViewHeight))
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.delegate = self
        contentScrollView.indicatorStr = "content"
        contentScrollView.contentSize = CGSizeMake(500, 0)
        contentScrollView.bounces = false
        bottomView.addSubview(contentScrollView)
        
        contentTableView = ParameterTableView(frame: CGRectMake(0, 0, 500, BottomViewHeight))
        contentTableView.showsVerticalScrollIndicator = false
        contentTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        contentTableView.bounces = false
        contentTableView.dataSource = self
        contentTableView.delegate = self
        contentTableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "ContentTableCell")
        contentTableView.indicatorId = "content"
        contentScrollView.addSubview(contentTableView)
    }
    
    func createOtherViews() {
        
        var pkView : UIView = UIView(frame: CGRectMake(ScreenWidth - 10 - 35, ScreenHeight - 49 * 2 - 35, 45, 50))
        view.addSubview(pkView)
        
        var pkBtn = UIButton(frame: CGRectMake(0, 3, 35, 35))
        pkBtn.setBackgroundImage(UIImage(named: "chexun_pkbut"), forState: UIControlState.Normal)
        pkBtn.addTarget(self, action: "pkBtnClik", forControlEvents: UIControlEvents.TouchDown)
        pkView.addSubview(pkBtn)
        
        // a indicator button above the pk button
        indicatorBtn = NoHighLightBtn(frame: CGRectMake(23, 0, 18, 18))
        indicatorBtn.setBackgroundImage(UIImage(named: "chexunr_pkicon_selected"), forState: UIControlState.Normal)
        indicatorBtn.addTarget(self, action: "pkBtnClik", forControlEvents: UIControlEvents.TouchDown)
        indicatorBtn.titleLabel?.font = UIFont.systemFontOfSize(10)
        indicatorBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //set whether show or hide 
        if compareCars.count == 0 {
            indicatorBtn.hidden = true
        } else {
            indicatorBtn.hidden = false
            indicatorBtn.setTitle("\(compareCars.count)", forState: UIControlState.Normal)
        }
        
        pkView.addSubview(indicatorBtn)
        
        // add a button that to the table top
        var topBtn : UIButton = UIButton(frame: CGRectMake(ScreenWidth - 10 - 35, ScreenHeight - 49 - 35, 35, 35))
        topBtn.setBackgroundImage(UIImage(named: "chexun_uparrow"), forState: UIControlState.Normal)
        topBtn.addTarget(self, action: "topBtnClick", forControlEvents: UIControlEvents.AllTouchEvents)
        view.addSubview(topBtn)
        
    }
    
    
    /**
    load data
    */
    func loadData () {
        var path :String! = NSBundle.mainBundle().pathForResource("contentData", ofType: "plist")
        
        var contentArr :NSArray! = NSArray(contentsOfFile: path)
        //deal data ,merge(combine)config and parame
        let dict0 : NSDictionary = contentArr[0] as! NSDictionary
        let dict1 : NSDictionary = contentArr[1] as! NSDictionary
        let paraDict : NSDictionary = dict0["result"] as! NSDictionary
        self.divideDifferentPara(paraDict["paramtypeitems"] as! NSArray)
        let configDict : NSDictionary = dict1["result"] as! NSDictionary
        self.divideDifferentConfig(configDict["configtypeitems"] as! NSArray)
        if contentArr.count >= 3 {
            /*
            var carsDict :NSDictionary!
            carsDict = contentArr[0] as! NSDictionary
            var carsResult :NSDictionary!
            carsResult = carsDict["result"] as! NSDictionary
            */
            
            //reset view content
            self.resetViewContent();
            
        }
        
    }
    /**
    reset view content
    */
    func resetViewContent () {
        
        showLabels = NSMutableArray.new()
        
        for i in 0 ... contentData.count - 1 {
            var showLabel : UILabel = UILabel(frame: CGRectMake(10, 0, ScreenWidth - TitleBarWidth, SectionHeight))
            let paraDict : NSDictionary! = contentData[i] as! NSDictionary
            showLabel.text = paraDict["name"] as? String
            showLabel.font = UIFont.systemFontOfSize(12)
            showLabels.addObject(showLabel)
        }
        
        let secDict : NSDictionary = contentData[0] as! NSDictionary
        let secArr : NSArray = secDict["paramitems"] as! NSArray
        let rowDic : NSDictionary = secArr[0] as! NSDictionary
        let rowArr : NSArray = rowDic["valueitems"] as! NSArray
        
        //guide price from the company 
        let rowDic2 : NSDictionary = secArr[2] as! NSDictionary
        let rowArr2 : NSArray = rowDic2["valueitems"] as! NSArray
        //the lowest price in the country
        let rowDic3 : NSDictionary = secArr[3] as! NSDictionary
        let rowArr3 : NSArray = rowDic3["valueitems"] as! NSArray
        
        //displacement
        let rowDic9 : NSDictionary = secArr[9] as! NSDictionary
        let rowArr9 : NSArray = rowDic9["valueitems"] as! NSArray
        //top position
        let rowDic14 : NSDictionary = secArr[14] as! NSDictionary
        let rowArr14 : NSArray = rowDic14["valueitems"] as! NSArray
        //year
        let rowDic1 : NSDictionary = secArr[1] as! NSDictionary
        let rowArr1 : NSArray = rowDic1["valueitems"] as! NSArray
        
        contentTableView.frame = CGRectMake(0, 0, CGFloat(rowArr.count) * CellWidth, BottomViewHeight)
        contentScrollView.contentSize = CGSizeMake(CGFloat(rowArr.count) * CellWidth, 0)
        
        carTypeScrollView.contentSize = CGSizeMake(CGFloat(rowArr.count) * CellWidth, 0)
        carTypeView.frame = CGRectMake(0, 0, CGFloat(rowArr.count) * CellWidth, carTypeScrollView.bounds.size.height)
        headPriceScrollView.contentSize = CGSizeMake(CGFloat(rowArr.count) * CellWidth, 0)
        contentPriceView.frame = CGRectMake(0, 0, CGFloat(rowArr.count) * CellWidth, headPriceScrollView.bounds.size.height)
        //create carTypeScrollView's child views
        let subviewsCount : Int = carTypeView.subviews.count
        if subviewsCount > 0 {
            for subview in carTypeView.subviews {
                subview.removeFromSuperview()
            }
        }
        
        
        for i in 0 ... rowArr.count - 1 {
            var paraCarView : ParameterCarTypeView = ParameterCarTypeView.new()
            let rowDict : NSDictionary = rowArr[i] as! NSDictionary
            let rowDict2 : NSDictionary = rowArr2[i] as! NSDictionary
            var guidePrice : String = rowDict2["value"] as! String
            
            if guidePrice.hasSuffix("万元") {
                /*字符串的截取
                var s="1234567890"
                let index = advance(s.startIndex, 5)
                let index2 = advance(s.endIndex, -6);
                var range = Range<String.Index>(start: index2,end: index)
                var s1:String=s.substringFromIndex(index)
                var s2:String=s.substringToIndex(index2)
                var s3=s.substringWithRange(range)
                */
                let index = advance(guidePrice.endIndex, -2)
                guidePrice = guidePrice.substringToIndex(index)
            }
            
            let rowDict3 : NSDictionary = rowArr3[i] as! NSDictionary
            var lowPrice : String = rowDict3["value"] as! String
            if lowPrice.hasSuffix("万元") {
                let index = advance(lowPrice.endIndex, -2)
                lowPrice = lowPrice.substringToIndex(index)
            }
            let rowDict1 : NSDictionary = rowArr1[i] as! NSDictionary
            let year : String = rowDict1["value"] as! String
            let rowDict9 : NSDictionary = rowArr9[i] as! NSDictionary
            let displace : String = rowDict9["value"] as! String
            let rowDict14 : NSDictionary = rowArr14[i] as! NSDictionary
            let speed : String = rowDict14["value"] as! String
            
            let carTypeImage : String = carSeriesDict["carSeriesImg"]!
            let carSeriesId : String = carSeriesDict["carSeriesId"]!
            let carSeriesName : String = carSeriesDict["carSeriesName"]!
            
            var dataDict : NSDictionary? = ["carTypeId" : (rowDict["specid"] as! String),
                                            "carTypeImage" : carTypeImage,
                                            "carTypeLowPrice" : lowPrice,
                                            "carTypeName" : rowDict["value"] as! String,
                                            "carTypePrice" : guidePrice,
                                            "year" : year,
                                            "displace" : displace,
                                            "speed" : speed,
                                            "carSeriesId" : carSeriesId,
                                            "carSeriesName" : carSeriesName]
            
            paraCarView.dataDict = dataDict
            paraCarView.delegate = self
            paraCarView.tag = i
            paraCarView.frame = CGRectMake(CGFloat(i) * CellWidth, 0, CellWidth, CarTypeHeight)
            carTypeView.addSubview(paraCarView)
            
        }
        
        
        //set page number
        
        //create headPriceScrollView's childview
        let count : Int = contentPriceView.subviews.count
        if count > 0 {
            for subView in contentPriceView.subviews {
                subView.removeFromSuperview()
            }
        }
        for i in 0 ... (rowArr.count - 1) {
            var priceContenView : PriceContentView = PriceContentView.new()
            let dict2 : NSDictionary = rowArr2[i] as! NSDictionary
            let dict3 : NSDictionary = rowArr3[i] as! NSDictionary
            var dataDict : NSDictionary? = ["companyPrice":dict2["value"] as! String,"lowPrice":dict3["value"] as! String]
            priceContenView.dataDict = dataDict
            priceContenView.tag = i
            priceContenView.frame = CGRectMake(CGFloat(i) * CellWidth, 0, CellWidth, CarTypeHeight)
            contentPriceView.addSubview(priceContenView)
        }
        
    }
    
    func divideDifferentPara (allArr : NSArray) {
        var allArrM : NSMutableArray = NSMutableArray.new()
        var allArrDifM : NSMutableArray = NSMutableArray.new()
        for i in 0 ... allArr.count - 1 {
            let sectionDict : NSDictionary = allArr[i] as! NSDictionary
            let name : String = sectionDict["name"] as! String
            let rowArr : NSArray = sectionDict["paramitems"] as! NSArray
            var secondArrM : NSMutableArray = NSMutableArray.new()
            var secondArrDifM : NSMutableArray = NSMutableArray.new()
            
            
            if rowArr.count > 0 {
                
                for j in 0 ... rowArr.count - 1 {
                    var inditor : Int = 0
                    var rowArrM : NSMutableArray = NSMutableArray.new()
                    let secondDict : NSDictionary = rowArr[j] as! NSDictionary
                    let paraName : String = secondDict["name"] as! String
                    let paraIdTemp : AnyObject = secondDict["id"]!
                    let paraId : String = "\(paraIdTemp)"
                    let paraArr : NSArray = secondDict["valueitems"] as! NSArray
                    var rowDict0 : NSDictionary!
                    var rowStr0 : String!
                    var rowDict : NSDictionary!
                    var rowStr : String!
                    var dict : NSDictionary!
                    
                    if paraArr.count > 0 {
                    
                        for k in 0 ... paraArr.count - 1 {
                            if k == 0 {
                                rowDict0 = paraArr[0] as! NSDictionary
                                let rowTemp : AnyObject = rowDict0["value"]!
                                rowStr0 = "\(rowTemp)"
                                
                            }
                            rowDict = paraArr[k] as! NSDictionary
                            let rowStrTemp : AnyObject = rowDict["value"]!
                            rowStr = "\(rowStrTemp)"
                            
                            let specidTemp : AnyObject = rowDict["specid"]!
                            let valueTemp : AnyObject = rowDict["value"]!
                            dict = ["specid":"\(specidTemp)","value":"\(valueTemp)"]
                            rowArrM.addObject(dict)
                            let row0 : String = rowStr0
                            let rowOther : String = rowStr
                            if row0 != rowOther {
                                inditor = 1
                            }
                            
                        }// third layer
                    }
                    
                    var resultDict : NSDictionary? = ["id":paraId,"name":paraName,"difIndicator":inditor,"valueitems":rowArrM]
                    secondArrM.addObject(resultDict!)
                    if inditor == 1 {
                        secondArrDifM.addObject(resultDict!)
                    }
                    
                    
                }//second layer
            }
            
            var allResultDict : NSDictionary = ["name":name,"paramitems":secondArrM]
            var allResultDifDict : NSDictionary = ["name":name,"paramitems":secondArrDifM]
            allArrM.addObject(allResultDict)
            allArrDifM.addObject(allResultDifDict)
            
        }//first layer 
        contentData = NSMutableArray(array: allArrM)
        contentDifData = NSMutableArray(array: allArrDifM)
        
    }
    
    func divideDifferentConfig (allArr : NSArray) {
        
        for i in 0 ... allArr.count - 1 {
            let sectionDict : NSDictionary = allArr[i] as! NSDictionary
            let name : String = sectionDict["name"] as! String
            let rowArr : NSArray = sectionDict["configitems"] as! NSArray
            var secondArrM : NSMutableArray = NSMutableArray.new()
            var secondArrDifM : NSMutableArray = NSMutableArray.new()
            for j in 0 ... rowArr.count - 1 {
                var inditor : Int = 0
                var rowArrM : NSMutableArray = NSMutableArray.new()
                let secondDict : NSDictionary = rowArr[j] as! NSDictionary
                let paraName : String = secondDict["name"] as! String
                let paraIdTemp : AnyObject = secondDict["id"]!
                let paraId : String = "\(paraIdTemp)"
                let paraArr : NSArray = secondDict["valueitems"] as! NSArray
                var rowDict0 : NSDictionary!
                var rowStr0 : String!
                var rowDict : NSDictionary!
                var rowStr : String!
                var dict : NSDictionary!
                for k in 0 ... paraArr.count - 1 {
                    if k == 0 {
                        rowDict0 = paraArr[0] as! NSDictionary
                        let rowTemp : AnyObject = rowDict0["value"]!
                        rowStr0 = "\(rowTemp)"
                        
                    }
                    rowDict = paraArr[k] as! NSDictionary
                    let rowStrTemp : AnyObject = rowDict["value"]!
                    rowStr = "\(rowStrTemp)"
                    
                    let specidTemp : AnyObject = rowDict["specid"]!
                    let valueTemp : AnyObject = rowDict["value"]!
                    dict = ["specid":"\(specidTemp)","value":"\(valueTemp)"]
                    rowArrM.addObject(dict)
                    let row0 : String = rowStr0
                    let rowOther : String = rowStr
                    if row0 != rowOther {
                        inditor = 1
                    }
                    
                }// third layer
                
                var resultDict : NSDictionary? = ["id":paraId,"name":paraName,"difIndicator":inditor,"valueitems":rowArrM]
                secondArrM.addObject(resultDict!)
                if inditor == 1 {
                    secondArrDifM.addObject(resultDict!)
                }
                
                
            }//second layer
            var allResultDict : NSDictionary = ["name":name,"paramitems":secondArrM]
            var allResultDifDict : NSDictionary = ["name":name,"paramitems":secondArrDifM]
            contentData.addObject(allResultDict)
            contentDifData.addObject(allResultDifDict)
            
        }//first layer
        
    }
    
    
    
    /**
    right menu button click
    :param: btn
    */
    func screenBtnClick(btn:UIButton) {
        btn.selected = !btn.selected
    
    }
    
    /**
    *  showOrHiddenClick
    */
    func showOrHiddenClick(btn:NoHighLightBtn) {
        btn.selected  = true
        
        if btn.tag == 1 {
            showBtn.selected = false
            showIndicator = 1
        } else {
            hiddenBtn.selected = false
            showIndicator = 0
            
        }
        
        navTableView.reloadData()
        contentTableView.reloadData()
    }
    
    
    func topBtnClick() {
        contentTableView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if showIndicator == 0 {
            return contentData.count
        } else {
            return contentDifData.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showIndicator == 0 {
            let dict : NSDictionary = contentData[section] as! NSDictionary
            let arr : NSArray = dict["paramitems"] as! NSArray
            return arr.count
        } else {
            let dict : NSDictionary = contentDifData[section] as! NSDictionary
            let arr : NSArray = dict["paramitems"] as! NSArray
            return arr.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var arrData : NSArray!
        if showIndicator == 0 {
            arrData = contentData
        } else {
            arrData = contentDifData
        }
        var readCellHeight : CGFloat!
        if indexPath.section == 0 && indexPath.row == 0 {
            readCellHeight = BigCellHeight
        } else {
            readCellHeight = CellHeight
        }
        
        let tmp : ParameterTableView = tableView as! ParameterTableView
        
        if tmp.indicatorId == "title" {
             var  titleID : String = "NavTableCell"
            
            var titleCell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(titleID, forIndexPath: indexPath) as! UITableViewCell
            titleCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            let count : Int = titleCell.contentView.subviews.count
            if count > 0 {
                for subView in titleCell.contentView.subviews {
                    subView.removeFromSuperview()
                }
            }
            
            let secDict : NSDictionary = arrData[indexPath.section] as! NSDictionary
            let secArr : NSArray = secDict["paramitems"] as! NSArray
            let rowDic : NSDictionary = secArr[indexPath.row] as! NSDictionary
            var parameterView : ParameterCell = ParameterCell(Frame: titleCell.bounds, IndicatorNew: "title")
            if rowDic["difIndicator"] as! Int == 0 {
                parameterView.isAll = true
            } else {
                parameterView.isAll = false
            }
            parameterView.contentStr = rowDic["name"] as! String
            titleCell.contentView.addSubview(parameterView)
            
            return titleCell
        } else {
             var contentID : String = "ContentTableCell"
            
            var contentCell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(contentID, forIndexPath: indexPath) as! UITableViewCell
            contentCell.selectionStyle = UITableViewCellSelectionStyle.None
            let count : Int = contentCell.contentView.subviews.count
            if count > 0 {
                for subView in contentCell.contentView.subviews {
                    subView.removeFromSuperview()
                }
            }
            
            let secDict : NSDictionary = arrData[indexPath.section] as! NSDictionary
            let secArr : NSArray = secDict["paramitems"] as! NSArray
            let rowDic : NSDictionary = secArr[indexPath.row] as! NSDictionary
            let rowArr : NSArray = rowDic["valueitems"] as! NSArray
            
            if rowArr.count > 0 {
                for i in 0 ... rowArr.count - 1 {
                    let dict : NSDictionary = rowArr[i] as! NSDictionary
                    var parameterView : ParameterCell = ParameterCell(Frame: CGRectMake(CGFloat(i) * CellWidth, 0, CellWidth, readCellHeight), IndicatorNew: "content")
                    if rowDic["difIndicator"] as! Int == 0 {
                        parameterView.isAll = true
                    } else {
                        parameterView.isAll = false
                    }
                    let contentStrTemp : AnyObject = dict["value"]!
                    parameterView.contentStr = "\(contentStrTemp)"
                    contentCell.contentView.addSubview(parameterView)
                }
            }
            
            return contentCell
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tmp : ParameterTableView = tableView as! ParameterTableView
        
        if tmp.indicatorId == "title" {
            var titleView : UIView! = UIView(frame: CGRectMake(0, 0, TitleBarWidth, SectionHeight))
            titleView.backgroundColor = mainBackGroundColor
            titleView.addSubview(showLabels[section] as! UIView)
            return titleView
        } else {
            var contentView : UIView! = UIView(frame: CGRectMake(0, 0, TitleBarWidth, SectionHeight))
            contentView.backgroundColor = mainBackGroundColor
            return contentView
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SectionHeight
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return BigCellHeight
        } else {
            return CellHeight
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(ParameterScrollView) {
            let tmp : ParameterScrollView = scrollView as! ParameterScrollView
            if tmp.indicatorStr == "content" {
                carTypeScrollView.contentOffset = tmp.contentOffset
                headPriceScrollView.contentOffset = tmp.contentOffset
            } else if tmp.indicatorStr == "headPrice" {
                carTypeScrollView.contentOffset = tmp.contentOffset
                contentScrollView.contentOffset = tmp.contentOffset
            } else {
                contentScrollView.contentOffset = tmp.contentOffset
                headPriceScrollView.contentOffset = tmp.contentOffset
            }
            
        } else if scrollView.isKindOfClass(ParameterTableView) {
            let tmp : ParameterTableView = scrollView as! ParameterTableView
            if tmp.indicatorId == "title" {
                contentTableView.contentOffset = tmp.contentOffset
            } else {
                navTableView.contentOffset = tmp.contentOffset
            }
        }
    }
    
    
    func parameterReduceBtnClick (carTypeView : ParameterCarTypeView) {
        let indexNum : Int = carTypeView.tag
        if carTypeView.subviews.count > 0 {
            for i in 0 ... carTypeView.subviews.count - 1 {
                let carView : ParameterCarTypeView = self.carTypeView.subviews[i] as! ParameterCarTypeView
                if carView.tag == indexNum {
                    carView.removeFromSuperview()
                    break
                }
            }
        }
        
        
        if self.contentPriceView.subviews.count > 0 {
            for x in 0 ... self.contentPriceView.subviews.count - 1 {
                let priceView : PriceContentView = self.contentPriceView.subviews[x] as! PriceContentView
                if priceView.tag == indexNum {
                    priceView.removeFromSuperview()
                    break
                }
            }
        }
        
        
        carTypeCount = self.carTypeView.subviews.count
        
        //deal with data
        var allArrM : NSMutableArray = NSMutableArray.new()
        var allArrDifM : NSMutableArray = NSMutableArray.new()
        for i in 0 ... contentData.count - 1 {
            let sectionDict : NSDictionary = contentData[i] as! NSDictionary
            let name : String = sectionDict["name"] as! String
            let rowArr : NSArray = sectionDict["paramitems"] as! NSArray
            var secondArrM : NSMutableArray = NSMutableArray.new()
            var secondArrDifM : NSMutableArray = NSMutableArray.new()
            for j in 0 ... rowArr.count - 1 {
                
                var rowArrM : NSMutableArray = NSMutableArray.new()
                let secondDict : NSDictionary = rowArr[j] as! NSDictionary
                let paraName : String = secondDict["name"] as! String
                var inditor : NSInteger  = secondDict["difIndicator"]!.integerValue
                
                let paraIdTemp : AnyObject = secondDict["id"]!
                let paraId : String = "\(paraIdTemp)"
                let paraArr : NSArray = secondDict["valueitems"] as! NSArray
                
                
                var rowDict : NSDictionary!
                var rowStr : String!
                var dict : NSDictionary!
                for k in 0 ... paraArr.count - 1 {
                    
                    if k != indexNum {
                        rowDict = paraArr[k] as! NSDictionary
                        let rowStrTemp : AnyObject = rowDict["value"]!
                        rowStr = "\(rowStrTemp)"
                        let specidTemp : AnyObject = rowDict["specid"]!
                        let valueTemp : AnyObject = rowDict["value"]!
                        dict = ["specid":"\(specidTemp)","value":"\(valueTemp)"]
                        rowArrM.addObject(dict)
                    }
                }// third layer
                
                var resultDict : NSDictionary? = ["id":paraId,"name":paraName,"difIndicator":inditor,"valueitems":rowArrM]
                secondArrM.addObject(resultDict!)
                if inditor == 1 {
                    secondArrDifM.addObject(resultDict!)
                }
                
                
            }//second layer
            var allResultDict : NSDictionary = ["name":name,"paramitems":secondArrM]
            var allResultDifDict : NSDictionary = ["name":name,"paramitems":secondArrDifM]
            allArrM.addObject(allResultDict)
            allArrDifM.addObject(allResultDifDict)
            
        }//first layer
        
        
        self.divideDifferentPara(allArrM)
        if contentData == nil {
            contentData = NSMutableArray(array: allArrM)
        }
        if contentDifData == nil {
            contentDifData = NSMutableArray(array: allArrDifM)
        }
        
        //set carTypeScrollView subviews' frame
        if self.carTypeView.subviews.count > 0 {
            
            for l in indexNum ... self.carTypeView.subviews.count - 1 {
                var carView : ParameterCarTypeView = self.carTypeView.subviews[l] as! ParameterCarTypeView
                carView.tag = l
                carView.frame = CGRectMake(CGFloat(carView.tag) * CellWidth, 0, CellWidth, CarTypeHeight)
            }
        }
        
        //set contentPriceView subchlid frame
        if contentPriceView.subviews.count > 0 {
            
            for m in indexNum ... contentPriceView.subviews.count - 1 {
                var priceView : PriceContentView = contentPriceView.subviews[m] as! PriceContentView
                priceView.tag = m
                priceView.frame = CGRectMake(CGFloat(priceView.tag) * CellWidth, 0, CellWidth, CarTypeHeight)
            }
        }
        
        let secDict : NSDictionary = contentData[0] as! NSDictionary
        let secArr : NSArray = secDict["paramitems"] as! NSArray
        let rowDic : NSDictionary = secArr[0] as! NSDictionary
        let rowArr : NSArray = rowDic["valueitems"] as! NSArray
        
        //reset contentsize
        contentTableView.frame = CGRectMake(0, 0, CGFloat(rowArr.count) * CellWidth, BottomViewHeight)
        contentScrollView.contentSize = CGSizeMake(CGFloat(rowArr.count) * CellWidth, 0)
        carTypeScrollView.contentSize = CGSizeMake(CGFloat(rowArr.count) * CellWidth, 0)
        self.carTypeView.frame = CGRectMake(0, 0, CGFloat(rowArr.count) * CellWidth, carTypeScrollView.bounds.size.height)
        headPriceScrollView.contentSize = CGSizeMake(CGFloat(rowArr.count) * CellWidth, 0)
        contentPriceView.frame = CGRectMake(0, 0, CGFloat(rowArr.count) * CellWidth, headPriceScrollView.bounds.size.height)
        
        if (carTypeCount == 0) {
            bottomView.hidden = true;
            navTableView.hidden = true;
            contentScrollView.hidden = true;
            contentTableView.hidden = true;
        } else {
            bottomView.hidden = false;
            navTableView.hidden = false;
            contentScrollView.hidden = false;
            contentTableView.hidden = false;
        }
        
        navTableView.reloadData()
        contentTableView.reloadData()
        
    }
    
    
    
    func parameterAddBtnClick (carTypeView: ParameterCarTypeView) {
        if compareCars.count == 0 {
            indicatorBtn.hidden = true
        } else {
            indicatorBtn.hidden = false
            indicatorBtn.setTitle("\(compareCars.count)", forState: UIControlState.Normal)
        }
    }

}

