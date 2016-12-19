//
//  CellModel.swift
//  ExPandableTableview
//
//  Created by  mshen on 2016/12/15.
//  Copyright © 2016年  mshen. All rights reserved.
//

import UIKit

class CellModel: NSObject {

//    public let Main_Screen_Width = UIScreen.main.bounds.width
//    public let Main_Screen_Height = UIScreen.main.bounds.height
    
    public var additionalRows:Int = 0     //展开的行数
    public var cellIdentifier:String = ""  //标识符
    public var isExpandable:Bool = false  //是否可展开，默认为否
    public var isExpanded:Bool = false  //是否是展开的状态
    public var isVisible:Bool = false   //是否可见
    public var primaryTitle:String = ""
    public var secondaryTitle:String = ""
    public var value:String = ""
    
    
    public func getCellModelWithDict(dict:[String:AnyObject]) ->CellModel {
        self.additionalRows = (dict["additionalRows"] as! NSNumber).intValue
        self.cellIdentifier = dict["cellIdentifier"] as! String
        self.isExpandable = dict["isExpandable"] as! Bool
        self.isExpanded = dict["isExpanded"] as! Bool
        self.isVisible = dict["isVisible"] as! Bool
        self.primaryTitle = dict["primaryTitle"] as! String
        self.secondaryTitle = dict["secondaryTitle"] as! String
        self.value = dict["value"] as! String
        return self
    }
    

}
