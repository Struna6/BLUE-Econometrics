//
//  OtherEstimationVC.swift
//  BLUE
//
//  Created by Karol Struniawski on 14/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit
import AVKit

class OtherEstimationVC: UIViewController {

    @IBOutlet weak var parametersViewText: UILabel!
    @IBOutlet var parametersView: UIView!
    @IBOutlet weak var parametersViewImage: UIImageView!
    @IBOutlet weak var parametersViewTopLabel: UILabel!
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
    var instrumentsToChoose = [String]()
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
    
    var selectObjectForTopLabel = LongTappableToSaveContext()
    var selectObjectForTableView = LongTappableToSaveContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewToBlur.isHidden = true
        self.tableView.isHidden = true
        self.topLabel.isHidden = true
        parametersView.layer.cornerRadius = 10
        popUpView.layer.cornerRadius = 10
        instrumentsToChoose = model.headers
        model.chosenXHeader.forEach(){
            instrumentsToChoose.remove(at: instrumentsToChoose.firstIndex(of: $0)!)
        }
        
        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        parametersViewImage.addGestureRecognizer(tapOnImage)
        self.tableView.separatorColor = UIColor.clear;
        
        //topLabel
        selectObjectForTopLabel = LongTappableToSaveContext(newObject: self.topLabel, toBlur: self.viewToBlur, targetViewController: self)
        
        let longTapOnLabel = UILongPressGestureRecognizer(target: selectObjectForTopLabel, action: #selector(selectObjectForTopLabel.longTapOnObject(sender:)))
        topLabel.addGestureRecognizer(longTapOnLabel)
        
        //table
        selectObjectForTableView = LongTappableToSaveContext(newObject: self.tableView, toBlur: self.viewToBlur, targetViewController: self)
        
        let longTapOnTableView = UILongPressGestureRecognizer(target: selectObjectForTableView, action: #selector(selectObjectForTableView.longTapOnObject(sender:)))
        tableView.addGestureRecognizer(longTapOnTableView)
    }
    
    @IBAction func backParametersView(_ sender: UIButton) {
        closeParametersView()
    }
    @IBAction func closeChooseZ(_ sender: UIButton) {
        if !chosenZHeader.isEmpty && !chosenZInstrumentsHeader.isEmpty{
            self.tableView.isHidden = false
            self.topLabel.isHidden = false
        }
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
            instrumentsCalculate()
        }
    }
    
    private func instrumentsCalculate(){
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
        
        numsToDel.forEach(){num in
            for i in 0..<tmp.count{
                tmp[i].remove(at: num+1)
            }
        }
        var instruments = Array(repeating: Array(repeating: 0.0, count: 0), count: model.n)
        numsToAdd.forEach(){num in
            var tmpCol = [Double]()
            model.allObservations.forEach(){obs in
                tmpCol.append(obs.observationArray[num])
            }
            for i in 0..<tmpCol.count{
                tmp[i].append(tmpCol[i])
                instruments[i].append(tmpCol[i])
            }
        }
        Z = tmp
        var tmpEq = String()
        let eq = model.getGIVRegressionEquation(Z: Z)
        for i in 0..<eq.count{
            if i==0{
                tmpEq = tmpEq + String(format:"%.2f",eq[0])
            }else{
                let num = eq[i]
                if num>=0{
                    tmpEq = tmpEq + " + " + String(format:"%.2f",num) + model.chosenXHeader[i-1]
                }else{
                    tmpEq = tmpEq + " " + String(format:"%.2f",num) + model.chosenXHeader[i-1]
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
        
        parametersResults.removeAll()
        parametersResults.append(ModelParameters(name: "Hausmann Test", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: model.HausmannTest(Z: Z), description: "The Hausman Test (also called the Hausman specification test) detects endogenous regressors (predictor variables) in a regression model. Endogenous variables have values that are determined by other variables in the system. Having endogenous regressors in a model will cause ordinary least squares estimators to fail, as one of the assumptions of OLS is that there is no correlation between an predictor variable and the error term. Instrumental variables estimators can be used as an alternative in this case. However, before you can decide on the best regression method, you first have to figure out if your predictor variables are endogenous. This is what the Hausman test will do.", imageName: "CHI", videoName: "sampleVideo", variable: nil))
        parametersResults.append(ModelParameters(name: "Sargan–Hansen test", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: model.SarganTest(instruments: instruments, p: Double(numsToAdd.count-numsToDel.count)), description: "The Sargan test is based on the assumption that model parameters are identified via a priori restrictions on the coefficients, and tests the validity of over-identifying restrictions. The test statistic can be computed from residuals from instrumental variables regression by constructing a quadratic form based on the cross-product of the residuals and exogenous variables.[4]:132–33 Under the null hypothesis that the over-identifying restrictions are valid, the statistic is asymptotically distributed as a chi-square variable with (m−k)degrees of freedom (where m is the number of instruments and k is the number of endogenous variables).", imageName: "CHI", videoName: "sampleVideo", variable: nil))
        parametersResults.append(ModelParameters(name: "Weak Instruments test", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: model.FTestInstruments(instruments: instruments), description: "Weak instruments can produce biased IV estimators and hypothesis tests with large size distortions. But what, precisely, are weak instruments, and how does one detect them in practice? This paper proposes quantitative definitions of weak instruments based on the maximum IV estimator bias, or the maximum Wald test size distortion, when there are multiple endogenous regressors. We tabulate critical values that enable using the first-stage F-statistic (or, when there are multiple endogenous regressors, the Cragg–Donald [1993] statistic) to test whether the given instruments are weak.", imageName: "F", videoName: "sampleVideo", variable: nil))
        tableView.reloadData()
    }
    
    func loadParametersView(item : ModelParameters){
        parametersViewTopLabel.text = item.name
        parametersViewText.text = item.description
        parametersViewImage.image = UIImage(named: item.imageName)
        self.view.addSubview(parametersView)
        parametersView.alpha = 0
        parametersView.center = self.view.center
        parametersView.transform = CGAffineTransform(translationX: 0.0, y: 300)
        UIView.animate(withDuration: 0.4) {
            self.tableView.isHidden = true
            self.viewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.viewToBlur.isHidden = false
            self.parametersView.alpha = 1
            self.parametersView.transform = CGAffineTransform.identity
        }
    }
    
    func closeParametersView(){
        UIView.animate(withDuration: 0.4, animations: {
            self.parametersView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.parametersView.alpha = 0
            self.tableView.isHidden = false
            self.viewToBlur.effect = nil
        }) { (success) in
            self.parametersView.removeFromSuperview()
            self.viewToBlur.isHidden = false
        }
    }
    
    @objc func imageTapped(){
        if let path = Bundle.main.path(forResource: "sampleVideo", ofType: "mp4"){
            let video = AVPlayer(url: URL(fileURLWithPath: path))
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            present(videoPlayer, animated: true, completion: {
                video.play()
            })
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
            return instrumentsToChoose.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        if tableView == self.tableView{
            let par = parametersCategorized[indexPath.section][indexPath.row]
            cell.textLabel?.text = par.name + " = " + String(format:"%.3f",Double(par.value))
            
            switch indexPath.section{
            case 0:
                cell.imageView?.image = UIImage.init(named: "critical")
            case 1:
                cell.imageView?.image = UIImage.init(named: "warning")
            case 2:
                cell.imageView?.image = UIImage.init(named: "ok")
            case 3:
                cell.textLabel?.text = par.name
                cell.textLabel?.textColor = UIColor.red
                cell.imageView?.image = UIImage.init(named: "nan")
            default:break
            }
        }else if tableView == self.tableViewX{
            cell.textLabel?.text = model.chosenXHeader[indexPath.row]
        }else{
            cell.textLabel?.text = instrumentsToChoose[indexPath.row]
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
        }
        else if tableView == self.tableViewInstr{
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
        }else{
            loadParametersView(item: self.parametersCategorized[indexPath.section][indexPath.row])
        }
    }
    
}
