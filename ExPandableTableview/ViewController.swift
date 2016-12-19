//
//  ViewController.swift
//  ExPandableTableview
//
//  Created by  mshen on 2016/12/15.
//  Copyright © 2016年  mshen. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CustomCellDelegate {
    
    @IBOutlet weak var mTableView:UITableView!
    var cellDescriptorsArray = [[[String:AnyObject]]]()
    var visibleRowsPerSection = [[Int]]()
    var arrayTest = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCellDescriptor()
        self.configureTableView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func configureTableView() {
        mTableView.tableFooterView = UIView(frame: CGRect.zero)
        mTableView.register(UINib(nibName: "NormalCell", bundle: nil), forCellReuseIdentifier: "idCellNormal")
        mTableView.register(UINib(nibName: "TextfieldCell", bundle: nil), forCellReuseIdentifier: "idCellTextfield")
        mTableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
        mTableView.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "idCellSwitch")
        mTableView.register(UINib(nibName: "ValuePickerCell", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
        mTableView.register(UINib(nibName: "SliderCell", bundle: nil), forCellReuseIdentifier: "idCellSlider")
        self.mTableView.sectionHeaderHeight = 44;
        
    }
    
    
    func getCellDescriptor() {
        if let path = Bundle.main.path(forResource: "CellDescriptor", ofType: "plist") {
            let array:NSMutableArray = NSMutableArray.init(contentsOfFile: path)!;
            cellDescriptorsArray = array as NSArray as! [[[String :AnyObject]]]
            self.getVisibleRows()
        }
        
    }
    
    func getVisibleRows() {
        visibleRowsPerSection.removeAll()
        for array in cellDescriptorsArray {
            var visibleRows = [Int]()
            for (index, value) in array.enumerated() {
                if (value["isVisible"] as! Bool == true) {
                    visibleRows.append(index)
                }
            }
            visibleRowsPerSection.append(visibleRows) //[[0,3,5,],[0,5],[0]]
        }
    }
    
    func getCellSettingForIndexPath(indexPath:IndexPath)->[String : AnyObject] {
        let invisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row];
        return cellDescriptorsArray[indexPath.section][invisibleRow]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellDescriptorsArray.count
    }
    
    ///UITableViewDelegate
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Personal"
            
        case 1:
            return "Preferences"
            
        default:
            return "Work Experience"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRowsPerSection[section].count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dict:[String: AnyObject] = self.getCellSettingForIndexPath(indexPath:indexPath)
        switch dict["cellIdentifier"] as! String {
        case "idCellNormal":
            return 60.0
            
        case "idCellDatePicker":
            return 270.0
            
        default:
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCellDescriptor:[String: AnyObject] = self.getCellSettingForIndexPath(indexPath:indexPath)
        let identifier:String = currentCellDescriptor["cellIdentifier"] as! String
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CustomCell
        if currentCellDescriptor["cellIdentifier"] as! String == "idCellNormal" {
            if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                cell.textLabel?.text = primaryTitle as? String
            }
            
            if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                cell.detailTextLabel?.text = secondaryTitle as? String
            }
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellTextfield" {
            cell.textField.placeholder = currentCellDescriptor["primaryTitle"] as? String
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSwitch" {
            cell.lblSwitchLabel.text = currentCellDescriptor["primaryTitle"] as? String
            
            let value = currentCellDescriptor["value"] as? String
            cell.swMaritalStatus.isOn = (value == "true") ? true : false
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellValuePicker" {
            cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSlider" {
            let value = currentCellDescriptor["value"] as! String
            cell.slExperienceLevel.value = (value as NSString).floatValue
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]
        //        var dict = cellDescriptorsArray[indexPath.section][index]
        /*重新创建一个变量dict，用于获取状态信息是没问题的，但是如果用于修改就有问题了，dict和cellDescriptorsArray并不是指向一个地址。切记*****/
        //点击了indexPath，修改这行的展开状态
        if cellDescriptorsArray[indexPath.section][indexOfTappedRow]["isExpandable"] as! Bool == true {
            var shouldExpandAndShowSubRows = false
            if cellDescriptorsArray[indexPath.section][indexOfTappedRow]["isExpanded"] as! Bool == false {
                shouldExpandAndShowSubRows = true
            }
            cellDescriptorsArray[indexPath.section][indexOfTappedRow]["isExpanded"] = shouldExpandAndShowSubRows as AnyObject?
            //修改展开行的可见状态
            let addtionalNum =  (cellDescriptorsArray[indexPath.section][indexOfTappedRow]["additionalRows"] as! NSNumber).intValue
            for n in 1...addtionalNum {
                cellDescriptorsArray[indexPath.section][indexOfTappedRow + n]["isVisible"] =  shouldExpandAndShowSubRows as AnyObject?
            }
            
        } else {
            //如果该行是不可展开的，点击之后要给它的父cell赋值
            if cellDescriptorsArray[indexPath.section][indexOfTappedRow]["cellIdentifier"] as! String == "idCellValuePicker" {
                var indexOfParentCell: Int = indexOfTappedRow
                while indexOfParentCell >= 0 {
                    indexOfParentCell -= 1
                    if cellDescriptorsArray[indexPath.section][indexOfParentCell]["isExpandable"] as! Bool == true {
                        break;
                    }
                }
                //父cell赋值
                let string = cellDescriptorsArray[indexPath.section][indexOfTappedRow]["primaryTitle"] as AnyObject?
                cellDescriptorsArray[indexPath.section][indexOfParentCell]["primaryTitle"] = string
                //设置父cell收起
                cellDescriptorsArray[indexPath.section][indexOfParentCell]["isExpanded"] = false as AnyObject?
                let addtionalNum =  (cellDescriptorsArray[indexPath.section][indexOfParentCell]["additionalRows"] as! NSNumber).intValue
                for n in 1...addtionalNum {
                    cellDescriptorsArray[indexPath.section][indexOfParentCell + n]["isVisible"] =  false as AnyObject?
                }
            }
        }
        //刷新
        self.getVisibleRows()
        self.mTableView.reloadSections(IndexSet.init(integer: indexPath.section), with: UITableViewRowAnimation.fade)
        
    }
    
    ///CustomCellDelegate
    
    func dateWasSelected(_ selectedDateString: String) {
        let dateCellSection = 0
        let dateCellRow = 3
        cellDescriptorsArray[dateCellSection][dateCellRow]["primaryTitle"] = selectedDateString as AnyObject?
        self.mTableView .reloadSections(IndexSet.init(integer: dateCellSection), with: UITableViewRowAnimation.automatic)
    }
    
    func maritalStatusSwitchChangedState(_ isOn: Bool) {
        let maritalSwitchCellSection = 0
        let maritalSwitchCellRow = 6
        
        let valueToStore = (isOn) ? "true" : "false"
        let valueToDisplay = (isOn) ? "Married" : "Single"
        
        cellDescriptorsArray[maritalSwitchCellSection][maritalSwitchCellRow]["value"]  = valueToStore as AnyObject?
        cellDescriptorsArray[maritalSwitchCellSection][maritalSwitchCellRow - 1]["primaryTitle"] = valueToDisplay as AnyObject?
        self.mTableView.reloadSections(IndexSet.init(integer: maritalSwitchCellSection), with: UITableViewRowAnimation.automatic)
        
    }
    
    func textfieldTextWasChanged(_ newText: String, parentCell: CustomCell) {
        //输入完之后点击return才会去调用
        let parentCellIndexPath = mTableView.indexPath(for: parentCell)
        if parentCellIndexPath?.row == 1 {
            cellDescriptorsArray[0][1]["primaryTitle"] = newText as AnyObject?
        } else {
            cellDescriptorsArray[0][2]["primaryTitle"] = newText as AnyObject?
        }
        
        let fistName : String = cellDescriptorsArray[0][1]["primaryTitle"] as! String
        let secondName: String = cellDescriptorsArray[0][2]["primaryTitle"] as! String
        let fullName = fistName + " " + secondName
        cellDescriptorsArray[0][0]["primaryTitle"] = fullName as AnyObject?
        self.mTableView.reloadData()
    }
    
    func sliderDidChangeValue(_ newSliderValue: String) {
        cellDescriptorsArray[2][0]["primaryTitle"] = newSliderValue as AnyObject?
        cellDescriptorsArray[2][1]["value"] = newSliderValue as AnyObject?
        mTableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.none)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

