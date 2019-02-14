//
//  OtherEstimationVC.swift
//  BLUE
//
//  Created by Karol Struniawski on 14/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit

class OtherEstimationVC: UIViewController {


    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewX: UITableView!
    @IBOutlet weak var tableViewInstr: UITableView!
    @IBOutlet weak var viewToBlur: UIVisualEffectView!
    
    var model = Model()
    var chosenZHeader = [String]()
    var chosenZInstrumentsHeader = [String]()
    var Z = [[Double]]()
    var newHeaders = [String]()
    let tableSections = ["Critical","Warning","Normal","Uncalculable","Uncategorised"]
    var selectedVariable = "All"
    
    var parametersResults = [ModelParameters]()
    var criticalParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Critical"
                }else{
                    return $0.category.rawValue == "Critical" && $0.variable == selectedVariable
                }
            })
        }
    }
    var warningParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Warning"
                }else{
                    return $0.category.rawValue == "Warning" && $0.variable == selectedVariable
                }
            })
        }
    }
    var normalParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Normal"
                }else{
                    return $0.category.rawValue == "Normal" && $0.variable == selectedVariable
                }
            })
        }
    }
    var nanParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Nan"
                }else{
                    return $0.category.rawValue == "Nan" && $0.variable == selectedVariable
                }
            })
        }
    }
    var otherParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Other"
                }else{
                    return $0.category.rawValue == "Other" && $0.variable == selectedVariable
                }
            })
        }
    }
    var parametersCategorized : [[ModelParameters]]{
        get{
            var tmp = [[ModelParameters]]()
            tmp.append(criticalParameters)
            tmp.append(warningParameters)
            tmp.append(normalParameters)
            tmp.append(nanParameters)
            tmp.append(otherParameters)
            return tmp
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewToBlur.isHidden = true
        self.tableView.isHidden = true
        self.topLabel.isHidden = true
        
        
    }
    
    @IBAction func closeChooseZ(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.popUpView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.popUpView.alpha = 0
            self.popUpView.isHidden = false
            self.viewToBlur.effect = nil
            self.viewToBlur.isHidden = true
        }) { (success) in
            self.popUpView.removeFromSuperview()
        }
    }
    @IBAction func editButtonPressed(_ sender: Any) {
        self.view.addSubview(popUpView)
        popUpView.alpha = 0
        popUpView.center = self.view.center
        popUpView.transform = CGAffineTransform(translationX: 0.0, y: 300)
        UIView.animate(withDuration: 0.4) {
            self.tableView.isHidden = true
            self.viewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
            self.viewToBlur.isHidden = false
        }
    }
    
    @IBAction func editDissmiss(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.popUpView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.popUpView.alpha = 0
            self.popUpView.isHidden = false
            self.viewToBlur.effect = nil
            self.viewToBlur.isHidden = true
        }) { (success) in
            self.popUpView.removeFromSuperview()
        }
        if !chosenZHeader.isEmpty && !chosenZInstrumentsHeader.isEmpty{
            self.tableView.isHidden = false
            self.topLabel.isHidden = false
            
            var numsToDel = [Int]()
            var numsToAdd = [Int]()
            
            chosenZHeader.forEach(){
                if let num = model.chosenXHeader.firstIndex(of: $0){
                    numsToDel.append(num)
                }
            }
            chosenZInstrumentsHeader.forEach(){
                if let num = model.headers.firstIndex(of: $0){
                    numsToAdd.append(num)
                }
            }
            
            var tmp = [[Double]]()
            tmp = model.chosenX
            newHeaders = model.chosenXHeader
            
            numsToDel.forEach(){num in
                for i in 0..<tmp.count{
                    tmp[i].remove(at: num+1)
                }
                newHeaders.remove(at: num)
            }
            numsToAdd.forEach(){num in
                var tmpCol = [Double]()
                model.allObservations.forEach(){obs in
                    tmpCol.append(obs.observationArray[num])
                }
                for i in 0..<tmpCol.count{
                    tmp[i].append(tmpCol[i])
                }
                newHeaders.append(model.headers[num])
            }
            
            var tmpEq = String()
            let eq = model.getGIVRegressionEquation(Z: Z)
            for i in 0..<eq.count{
                if i==0{
                    tmpEq = tmpEq + String(format:"%.2f",eq[0])
                }else{
                    let num = eq[i]
                    if num>=0{
                        tmpEq = tmpEq + " + " + String(format:"%.2f",num) + newHeaders[i-1]
                    }else{
                        tmpEq = tmpEq + " " + String(format:"%.2f",num) + newHeaders[i-1]
                    }
                }
            }
            topLabel.text = tmpEq
            
            var tmpXText = String()
            self.chosenZHeader.forEach { (str) in
                tmpXText = tmpXText + " " + str
            }
            
            var tmpInstruments = String()
            self.chosenZInstrumentsHeader.forEach(){
                tmpInstruments = tmpInstruments + " " + $0
            }
            
            topLabel.text = "Regressand: \(model.chosenYHeader)\nInstrumentalized:   \(tmpXText)\nEquation: \(tmpEq)\nInstruments: \(tmpInstruments)"
        }
    }
}


extension OtherEstimationVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView{
            return tableSections.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView{
            return tableSections[section]
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return parametersCategorized[section].count
        }else if tableView == self.tableViewX{
            return model.chosenXHeader.count
        }else{
            return model.headers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        if tableView == self.tableView{
            let par = parametersCategorized[indexPath.section][indexPath.row]
            cell.textLabel?.text = par.name + " = " + String(format:"%.3f",Double(par.value))
        }else if tableView == self.tableViewX{
            cell.textLabel?.text = model.chosenXHeader[indexPath.row]
        }else{
            cell.textLabel?.text = model.headers[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if tableView == self.tableViewX{
            if cell?.accessoryType == UITableViewCell.AccessoryType.none{
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            }else{
                cell?.accessoryType = UITableViewCell.AccessoryType.none
            }
            let text = (cell?.textLabel?.text)!
            if self.chosenZHeader.contains(text){
                self.chosenZHeader.remove(at: chosenZHeader.firstIndex(of: text)!)
            }else{
                self.chosenZHeader.append(text)
            }
        }else if tableView == self.tableViewInstr{
            if cell?.accessoryType == UITableViewCell.AccessoryType.none{
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            }else{
                cell?.accessoryType = UITableViewCell.AccessoryType.none
            }
            let text = (cell?.textLabel?.text)!
            if self.chosenZInstrumentsHeader.contains(text){
                self.chosenZInstrumentsHeader.remove(at: chosenZInstrumentsHeader.firstIndex(of: text)!)
            }else{
                self.chosenZInstrumentsHeader.append(text)
            }
        }
    }
    
}
