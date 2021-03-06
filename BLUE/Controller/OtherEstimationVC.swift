//
//  OtherEstimationVC.swift
//  BLUE
//
//  Created by Karol Struniawski on 14/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit
import AVKit

class OtherEstimationVC: UIViewController, PlayableLoadingScreen, ErrorScreenPlayable {

    @IBOutlet weak var premiumButton: UIStackView!
    @IBOutlet weak var playButton: UIView!
    @IBOutlet weak var topText: UINavigationItem!
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
    
    
    var isLogitProbit = false
    var isProbit = false
    var logitToChoose = [String]()
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
    let imgViewBeforeEdit = UIImageView.init(image: UIImage(named: "editChoose"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !(UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
            premiumButton.isHidden = true
        }
        
        tableViewX.layer.borderWidth = 0.2
        tableViewInstr.layer.borderWidth = 0.2
        
        tableViewX.layer.cornerRadius = 5.0
        tableViewInstr.layer.cornerRadius = 5.0
        
        let imgViewBeforeEditTap = UITapGestureRecognizer(target: self, action: #selector(self.editButtonPressed(_:)))
        imgViewBeforeEdit.addGestureRecognizer(imgViewBeforeEditTap)
        imgViewBeforeEdit.isUserInteractionEnabled = true
        imgViewBeforeEdit.center = self.view.center
        self.view.addSubview(imgViewBeforeEdit)
        
        if isLogitProbit{
            if isProbit{
                topText.title = "Probit Model"
            }else{
                topText.title = "Logit Model"
            }
        }else{
            topText.title = "Instrumental Variables Model"
        }
        
        viewToBlur.isHidden = true
        self.tableView.isHidden = true
        self.topLabel.isHidden = true
        parametersView.layer.cornerRadius = 10
        popUpView.layer.cornerRadius = 10
        instrumentsToChoose = model.headers
        
        if isLogitProbit{
            labelToChoose1.text = "Choose variable for n"
            labelToChoose2.text = "Choose variable for success"
            logitToChoose = model.headers
            model.chosenXHeader.forEach(){
                logitToChoose.remove(at: logitToChoose.firstIndex(of: $0)!)
            }
        }
        
        model.chosenXHeader.forEach(){
            instrumentsToChoose.remove(at: instrumentsToChoose.firstIndex(of: $0)!)
        }
        
        if let index = instrumentsToChoose.firstIndex(of: model.chosenYHeader){
            instrumentsToChoose.remove(at: index)
        }
        
        
        playButton.layer.cornerRadius = 10.0
        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        playButton.addGestureRecognizer(tapOnImage)
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
    @IBOutlet weak var labelToChoose1: UILabel!
    @IBOutlet weak var labelToChoose2: UILabel!
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
            self.view.sendSubviewToBack(self.viewToBlur)
        }
    }
    @objc @IBAction func editButtonPressed(_ sender: Any) {
        self.view.bringSubviewToFront(viewToBlur)
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
            imgViewBeforeEdit.removeFromSuperview()
            self.tableView.isHidden = false
            self.topLabel.isHidden = false
            if isLogitProbit{
                if isProbit{
                    probitCalculate()
                }else{
                    logitCalculate()
                }
                
            }else{
               instrumentsCalculate()
            }
        }else{
            self.tableView.isHidden = true
            self.topLabel.isHidden = true
            if !self.view.subviews.contains(self.imgViewBeforeEdit){
                self.view.addSubview(self.imgViewBeforeEdit)
            }
        }
    }
    
    private func instrumentsCalculate(){
        self.tableView.isHidden = false
        self.topLabel.isHidden = false
        var tmpEq = String()
        var tmpXText = String()
        var tmpInstruments = String()
        
        playLoadingAsync(tasksToDoAsync: {
            var numsToDel = [Int]()
            var numsToAdd = [Int]()
            
            self.chosenZHeader.forEach(){
                if let num = self.model.chosenXHeader.firstIndex(of: $0){
                    numsToDel.append(num)
                }
            }
            self.chosenZInstrumentsHeader.forEach(){
                if let num = self.model.headers.firstIndex(of: $0){
                    numsToAdd.append(num)
                }
            }
            
            var tmp = [[Double]]()
            tmp = self.model.chosenX
            
            numsToDel.forEach(){num in
                for i in 0..<tmp.count{
                    tmp[i].remove(at: num+1)
                }
            }
            var instruments = Array(repeating: Array(repeating: 0.0, count: 0), count: self.model.n)
            numsToAdd.forEach(){num in
                var tmpCol = [Double]()
                self.model.allObservations.forEach(){obs in
                    tmpCol.append(obs.observationArray[num])
                }
                for i in 0..<tmpCol.count{
                    tmp[i].append(tmpCol[i])
                    instruments[i].append(tmpCol[i])
                }
            }
            self.Z = tmp
            
            let eq = self.model.getGIVRegressionEquation(Z: self.Z)
            for i in 0..<eq.count{
                if i==0{
                    tmpEq = tmpEq + String(format:"%.2f",eq[0])
                }else{
                    let num = eq[i]
                    if num>=0{
                        tmpEq = tmpEq + " + " + String(format:"%.2f",num) + "×" + self.model.chosenXHeader[i-1]
                    }else{
                        tmpEq = tmpEq + " " + String(format:"%.2f",num).replacingOccurrences(of: "-", with: " -") + "×" + self.model.chosenXHeader[i-1]
                    }
                }
            }
            
            self.chosenZHeader.forEach { (str) in
                tmpXText = tmpXText + " " + str
            }
            
            self.chosenZInstrumentsHeader.forEach(){
                tmpInstruments = tmpInstruments + " " + $0
            }
            
            self.parametersResults.removeAll()
            self.parametersResults.append(ModelParameters(name: "Hausmann Test", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: self.model.HausmannTest(Z: self.Z), description: "The Hausman Test (also called the Hausman specification test) detects endogenous regressors (predictor variables) in a regression model. Endogenous variables have values that are determined by other variables in the system. Having endogenous regressors in a model will cause ordinary least squares estimators to fail, as one of the assumptions of OLS is that there is no correlation between an predictor variable and the error term. Instrumental variables estimators can be used as an alternative in this case. However, before you can decide on the best regression method, you first have to figure out if your predictor variables are endogenous. This is what the Hausman test will do.", imageName: "CHI", videoName: "Hausmann", variable: nil))
            self.parametersResults.append(ModelParameters(name: "Sargan–Hansen test", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: self.model.SarganTest(instruments: instruments, p: Double(numsToAdd.count-numsToDel.count)), description: "The Sargan test is based on the assumption that model parameters are identified via a priori restrictions on the coefficients, and tests the validity of over-identifying restrictions. The test statistic can be computed from residuals from instrumental variables regression by constructing a quadratic form based on the cross-product of the residuals and exogenous variables.[4]:132–33 Under the null hypothesis that the over-identifying restrictions are valid, the statistic is asymptotically distributed as a chi-square variable with (m−k)degrees of freedom (where m is the number of instruments and k is the number of endogenous variables).", imageName: "CHI", videoName: "Sargan", variable: nil))
            self.parametersResults.append(ModelParameters(name: "Weak Instruments test", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: self.model.FTestInstruments(instruments: instruments), description: "Weak instruments can produce biased IV estimators and hypothesis tests with large size distortions. But what, precisely, are weak instruments, and how does one detect them in practice? This paper proposes quantitative definitions of weak instruments based on the maximum IV estimator bias, or the maximum Wald test size distortion, when there are multiple endogenous regressors. We tabulate critical values that enable using the first-stage F-statistic (or, when there are multiple endogenous regressors, the Cragg–Donald [1993] statistic) to test whether the given instruments are weak.", imageName: "F", videoName: "weakF", variable: nil))
        }, tasksToMainBack: {
            self.topLabel.text = "Regressand: \(self.model.chosenYHeader)\nInstrumentalized:   \(tmpXText)\nEquation: \(tmpEq)\nInstruments: \(tmpInstruments)"
            self.tableView.reloadData()
        }, mainView: self.view)
        
        playShortAnimationOnce(mainViewController: self)
    }
    
    private func logitCalculate(){
        self.tableView.isHidden = false
        self.topLabel.isHidden = false
        var tmpXText = String()
        var tmpEq = String()
        
        var nGroupTest = [Double]()
        var successTest = [Double]()
        
        let numGroupTest = self.model.headers.firstIndex(of: self.chosenZHeader.first!)!
        let numSuccessTest = self.model.headers.firstIndex(of: self.chosenZInstrumentsHeader.first!)!
        
        for i in 0..<self.model.allObservations.count{
            nGroupTest.append(self.model.allObservations[i].observationArray[numGroupTest])
            successTest.append(self.model.allObservations[i].observationArray[numSuccessTest])
        }
        
        for i in 0..<nGroupTest.count{
            let test = successTest[i]/nGroupTest[i]
            if test < 0.0 || test > 1.0{
                self.tableView.isHidden = true
                self.topLabel.isHidden = true
                if !self.view.subviews.contains(self.imgViewBeforeEdit){
                    self.view.addSubview(self.imgViewBeforeEdit)
                }
                playErrorScreen(msg: "Cannot build model! Probability lower than 0 or greater than 1", blurView: self.viewToBlur, mainViewController: self, alertToDismiss: nil)
                topLabel.text = "Error"
                return
            }
        }
        
        playLoadingAsync(tasksToDoAsync: {
            var nGroup = [Double]()
            var success = [Double]()
            
            let numGroup = self.model.headers.firstIndex(of: self.chosenZHeader.first!)!
            let numSuccess = self.model.headers.firstIndex(of: self.chosenZInstrumentsHeader.first!)!
            
            for i in 0..<self.model.allObservations.count{
                nGroup.append(self.model.allObservations[i].observationArray[numGroup])
                success.append(self.model.allObservations[i].observationArray[numSuccess])
            }
            
            let eq = self.model.getLogitEquation(nGroup: nGroup, success: success, X: self.model.chosenX)
            for i in 0..<eq.count{
                if i==0{
                    tmpEq = tmpEq + String(format:"%.2f",eq[0])
                }else{
                    let num = eq[i]
                    if num>=0{
                        tmpEq = tmpEq + " + " + String(format:"%.2f",num) + "×" + self.model.chosenXHeader[i-1]
                    }else{
                        tmpEq = tmpEq + " " + String(format:"%.2f",num).replacingOccurrences(of: "-", with: " -") + "×" + self.model.chosenXHeader[i-1]
                    }
                }
            }
            
            self.model.chosenXHeader.forEach { (str) in
                tmpXText = tmpXText + " " + str
            }
            
            self.parametersResults.removeAll()
            let dict = self.model.calculateLogitCountedR(nGroup: nGroup, success: success, X: self.model.chosenX)
            dict.forEach { (arg0) in
                let (key, value) = arg0
                if key.contains("%"){
                    self.parametersResults.append(ModelParameters(name: key, isLess: true, criticalFloor: 0.5, warningFloor: 0.75, value: value, description: "In statistics, the logistic model (or logit model) is a widely used statistical model that, in its basic form, uses a logistic function to model a binary dependent variable; many more complex extensions exist. In regression analysis, logistic regression (or logit regression) is estimating the parameters of a logistic model; it is a form of binomial regression. Mathematically, a binary logistic model has a dependent variable with two possible values, such as pass/fail, win/lose, alive/dead or healthy/sick; these are represented by an indicator variable, where the two values are labeled \"0\" and \"1\". In the logistic model, the log-odds (the logarithm of the odds) for the value labeled \"1\" is a linear combination of one or more independent variables (\"predictors\"); the independent variables can each be a binary variable (two classes, coded by an indicator variable) or a continuous variable (any real value). The corresponding probability of the value labeled \"1\" can vary between 0 (certainly the value \"0\") and 1 (certainly the value \"1\"), hence the labeling; the function that converts log-odds to probability is the logistic function, hence the name. ", imageName: "logit", videoName: nil, variable: nil))
                }else{
                    self.parametersResults.append(ModelParameters(name: key, isLess: nil, criticalFloor: nil, warningFloor: nil, value: value, description: "In statistics, the logistic model (or logit model) is a widely used statistical model that, in its basic form, uses a logistic function to model a binary dependent variable; many more complex extensions exist. In regression analysis, logistic regression (or logit regression) is estimating the parameters of a logistic model; it is a form of binomial regression. Mathematically, a binary logistic model has a dependent variable with two possible values, such as pass/fail, win/lose, alive/dead or healthy/sick; these are represented by an indicator variable, where the two values are labeled \"0\" and \"1\". In the logistic model, the log-odds (the logarithm of the odds) for the value labeled \"1\" is a linear combination of one or more independent variables (\"predictors\"); the independent variables can each be a binary variable (two classes, coded by an indicator variable) or a continuous variable (any real value). The corresponding probability of the value labeled \"1\" can vary between 0 (certainly the value \"0\") and 1 (certainly the value \"1\"), hence the labeling; the function that converts log-odds to probability is the logistic function, hence the name. ", imageName: "logit", videoName: nil, variable: nil))
                }
            }
        }, tasksToMainBack: {
            self.topLabel.text = "Regressand: \(self.chosenZHeader[0]) / \(self.chosenZInstrumentsHeader[0])\nRegressor:   \(tmpXText)\nEquation: \(tmpEq)"
            self.tableView.reloadData()
        }, mainView: self.view)
    }
    
    private func probitCalculate(){
        self.tableView.isHidden = false
        self.topLabel.isHidden = false
        var tmpEq = String()
        var tmpXText = String()
        
        var nGroup = [Double]()
        var success = [Double]()
        
        var nGroupTest = [Double]()
        var successTest = [Double]()
        
        let numGroupTest = self.model.headers.firstIndex(of: self.chosenZHeader.first!)!
        let numSuccessTest = self.model.headers.firstIndex(of: self.chosenZInstrumentsHeader.first!)!
        
        for i in 0..<self.model.allObservations.count{
            nGroupTest.append(self.model.allObservations[i].observationArray[numGroupTest])
            successTest.append(self.model.allObservations[i].observationArray[numSuccessTest])
        }
        
        for i in 0..<nGroupTest.count{
            let test = successTest[i]/nGroupTest[i]
            if test < 0.0 || test > 1.0{
                self.tableView.isHidden = true
                self.topLabel.isHidden = true
                if !self.view.subviews.contains(self.imgViewBeforeEdit){
                    self.view.addSubview(self.imgViewBeforeEdit)
                }
                playErrorScreen(msg: "Cannot build model! Probability lower than 0 or greater than 1", blurView: self.viewToBlur, mainViewController: self, alertToDismiss: nil)
                topLabel.text = "Error"
                return
            }
        }
        
        playLoadingAsync(tasksToDoAsync: {
            let numGroup = self.model.headers.firstIndex(of: self.chosenZHeader.first!)!
            let numSuccess = self.model.headers.firstIndex(of: self.chosenZInstrumentsHeader.first!)!
            
            for i in 0..<self.model.allObservations.count{
                nGroup.append(self.model.allObservations[i].observationArray[numGroup])
                success.append(self.model.allObservations[i].observationArray[numSuccess])
            }
            
            let eq = self.model.getProbitEquation(nGroup: nGroup, success: success, X: self.model.chosenX)
            for i in 0..<eq.count{
                if i==0{
                    tmpEq = tmpEq + String(format:"%.2f",eq[0])
                }else{
                    let num = eq[i]
                    if num>=0{
                        tmpEq = tmpEq + " + " + String(format:"%.2f",num) + "×" + self.model.chosenXHeader[i-1]
                    }else{
                        tmpEq = tmpEq + " " + String(format:"%.2f",num).replacingOccurrences(of: "-", with: " -") + "×" + self.model.chosenXHeader[i-1]
                    }
                }
            }
            
            self.model.chosenXHeader.forEach { (str) in
                tmpXText = tmpXText + " " + str
            }
            
            self.parametersResults.removeAll()
            let dict = self.model.calculateProbitCountedR(nGroup: nGroup, success: success, X: self.model.chosenX)
            dict.forEach { (arg0) in
                let (key, value) = arg0
                if key.contains("%"){
                    self.parametersResults.append(ModelParameters(name: key, isLess: true, criticalFloor: 0.5, warningFloor: 0.75, value: value, description: "In statistics, a probit model is a type of regression where the dependent variable can take only two values, for example married or not married. The word is a portmanteau, coming from probability + unit. The purpose of the model is to estimate the probability that an observation with particular characteristics will fall into a specific one of the categories; moreover, classifying observations based on their predicted probabilities is a type of binary classification model.A probit model is a popular specification for an ordinal or a binary response model. As such it treats the same set of problems as does logistic regression using similar techniques. The probit model, which employs a probit link function, is most often estimated using the standard maximum likelihood procedure, such an estimation being called a probit regression.", imageName: "logit", videoName: nil, variable: nil))
                }else{
                    self.parametersResults.append(ModelParameters(name: key, isLess: nil, criticalFloor: nil, warningFloor: nil, value: value, description: "In statistics, a probit model is a type of regression where the dependent variable can take only two values, for example married or not married. The word is a portmanteau, coming from probability + unit. The purpose of the model is to estimate the probability that an observation with particular characteristics will fall into a specific one of the categories; moreover, classifying observations based on their predicted probabilities is a type of binary classification model.A probit model is a popular specification for an ordinal or a binary response model. As such it treats the same set of problems as does logistic regression using similar techniques. The probit model, which employs a probit link function, is most often estimated using the standard maximum likelihood procedure, such an estimation being called a probit regression.", imageName: "logit", videoName: nil, variable: nil))
                }
            }
        }, tasksToMainBack: {
            self.topLabel.text = "Regressand: \(self.chosenZHeader[0]) / \(self.chosenZInstrumentsHeader[0])\nRegressor:   \(tmpXText)\nEquation: \(tmpEq)"
            self.tableView.reloadData()
        }, mainView: self.view)
        
        playShortAnimationOnce(mainViewController: self)
    }
    
    
    var chosenParameter : ModelParameters?
    
    func loadParametersView(item : ModelParameters){
        parametersViewTopLabel.text = item.name
        parametersViewText.text = item.description
        parametersViewImage.image = UIImage(named: item.imageName)
        self.view.bringSubviewToFront(viewToBlur)
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
        chosenParameter = item
        if (chosenParameter?.videoName != nil){
            if Bundle.main.path(forResource: chosenParameter!.videoName!, ofType: "mov") == nil{
                playButton.isHidden = true
            }
        }else{
            playButton.isHidden = true
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
            self.view.sendSubviewToBack(self.viewToBlur)
        }
    }
    
    @objc private func hidePlayBack(_ tap : UIGestureRecognizer ){
        let player = tap.view?.viewController as! AVPlayerViewController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            UIView.animate(withDuration: 1.0, animations: {
                player.view.alpha = 0.0
            }) { (_) in
                player.view.removeGestureRecognizer(tap)
                player.view.removeFromSuperview()
                player.removeFromParent()
                let alertController = UIAlertController.init(title: "Error", message: "Only VIP account can see full video, free account is limited to playing 60 seconds of tutorial. Please buy VIP account!", preferredStyle: .alert)
                self.present(alertController,animated: true,completion: {
                    sleep(3)
                    alertController.dismiss(animated: true)
                })
            }
        }
    }
    
    @objc func imageTapped(){
        if let path = Bundle.main.path(forResource: chosenParameter!.videoName!, ofType: "mov"){
            let video = AVPlayer(url: URL(fileURLWithPath: path))
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            
            if (UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
                self.addChild(videoPlayer)
                videoPlayer.player = video
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.hidePlayBack))
                videoPlayer.view.addGestureRecognizer(tap)
                videoPlayer.showsPlaybackControls = false
                videoPlayer.setValue(true, forKey: "requiresLinearPlayback")
                
                self.view.addSubview(videoPlayer.view)
                video.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    UIView.animate(withDuration: 1.0, animations: {
                        videoPlayer.view.alpha = 0.0
                    }) { (_) in
                        videoPlayer.view.removeGestureRecognizer(tap)
                        videoPlayer.view.removeFromSuperview()
                        videoPlayer.removeFromParent()
                        let alertController = UIAlertController.init(title: "Error", message: "Only VIP account can see full video, free account is limited to playing 60 seconds of tutorial. Please buy VIP account!", preferredStyle: .alert)
                        self.present(alertController,animated: true,completion: {
                            sleep(3)
                            alertController.dismiss(animated: true)
                        })
                    }
                }
            }else{
                present(videoPlayer, animated: true, completion: {
                    video.play()
                })
            }
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
        if isLogitProbit{
            if tableView == self.tableView{
                return parametersCategorized[section].count
            }else{
                return logitToChoose.count
            }
        }else{
            if tableView == self.tableView{
                return parametersCategorized[section].count
            }else if tableView == self.tableViewX{
                return model.chosenXHeader.count
            }else{
                return instrumentsToChoose.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        if isLogitProbit{
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
            }else{
                cell.textLabel?.text = logitToChoose[indexPath.row]
            }
            return cell
        }else{
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if !isLogitProbit{
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
        }else{
            if tableView == self.tableViewX{
                if cell?.accessoryType == UITableViewCell.AccessoryType.none && chosenZHeader.isEmpty{
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
                if cell?.accessoryType == UITableViewCell.AccessoryType.none && chosenZInstrumentsHeader.isEmpty{
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
    
}
