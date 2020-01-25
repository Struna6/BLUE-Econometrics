//
//  ViewController.swift
//  BLUE
//
//  Created by Karol Struniawski on 12/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit
import Surge
import MobileCoreServices
import SideMenu
import AVKit
import Tutti
import Firebase

// MARK: Protocol for Transponating Arrays

class ViewController: UIViewController, Storage, BackUpdatedObservations, SendBackSpreedSheetView, PlayableLoadingScreen, ErrorScreenPlayable{
    
    @IBOutlet weak var adView: GADBannerView!
    @IBOutlet weak var playButton: UIView!
    @IBOutlet weak var sideMenu: UIBarButtonItem!
    @IBOutlet weak var premiumLabel: UIStackView!
    @IBOutlet weak var premiumLabel2: UIStackView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var topTableView: UITableView!
    @IBOutlet weak var topLabel: UILabel!
    let topTableSections = ["Critical","Warning","Normal","Uncalculable"]
    var updateParametersResults : Bool = false{
        didSet{
            parametersResultsLoad()
        }
    }
    
    var openedFileName = ""
    var openedFilePath = ""
    var blurWhenMenuPresented: UIVisualEffectView?
    
    func parametersResultsLoad(){
        if newModel{
            parametersResults = []
        }else{
            let testsAdvanced = OLSTestsAdvanced(baseModel: model)
            parametersResults.removeAll()
             parametersResults = [
                ModelParameters(name: "R\u{00B2}", isLess: true, criticalFloor: 0.5, warningFloor: 0.75, value: model.squareR, description: "The better the linear regression (on the right) fits the data in comparison to the simple average (on the left graph), the closer the value of R\u{00B2} is to 1. The areas of the blue squares represent the squared residuals with respect to the linear regression. The areas of the red squares represent the squared residuals with respect to the average value.", imageName: "R", videoName: "squereR")
                ,ModelParameters(name: "Quantile odd observations", isLess: false, criticalFloor: Double(model.n)*0.05, warningFloor: Double(model.n)*0.1, value: Double(model.calculateNumberOfOddObservations()), description: "In statistics and probability quantiles are cut points dividing the range of a probability distribution into continuous intervals with equal probabilities, or dividing the observations in a sample in the same way. There is one less quantile than the number of groups created. Thus quartiles are the three cut points that will divide a dataset into four equal-sized groups. Common quantiles have special names: for instance quartile, decile (creating 10 groups: see below for more). The groups created are termed halves, thirds, quarters, etc., though sometimes the terms for the quantile are used for the groups created, rather than for the cut points.", imageName: "Q", videoName: "quantileOdd")
                ,ModelParameters(name: "Test F significance", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: model.parametersF, description: "The F value in regression is the result of a test where the null hypothesis is that all of the regression coefficients are equal to zero. In other words, the model has no predictive capability. Basically, the f-test compares your model with zero predictor variables (the intercept only model), and decides whether your added coefficients improved the model. If you get a significant result, then whatever coefficients you included in your model improved the model’s fit.", imageName: "F", videoName: "fTest")
                ,ModelParameters(name: "RESET test of stability of model", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: testsAdvanced.RESET(), description: "In statistics, the Ramsey Regression Equation Specification Error Test (RESET) test is a general specification test for the linear regression model. More specifically, it tests whether non-linear combinations of the fitted values help explain the response variable. The intuition behind the test is that if non-linear combinations of the explanatory variables have any power in explaining the response variable, the model is misspecified in the sense that the data generating process might be better approximated by a polynomial or another non-linear functional form.", imageName: "F", videoName: "RESET")
                ,ModelParameters(name: "Jarque-Bera test of normality", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: model.JBtest, description: "The Jarque-Bera Test,a type of Lagrange multiplier test, is a test for normality. Normality is one of the assumptions for many statistical tests, like the t test or F test; the Jarque-Bera test is usually run before one of these tests to confirm normality. ", imageName: "CHI", videoName: "JBtest")
                ,ModelParameters(name: "Lagrange test of autocorrelation", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: testsAdvanced.LMAutoCorrelation(), description: "Autocorrelation, also known as serial correlation, is the correlation of a signal with a delayed copy of itself as a function of delay. Informally, it is the similarity between observations as a function of the time lag between them. The analysis of autocorrelation is a mathematical tool for finding repeating patterns, such as the presence of a periodic signal obscured by noise, or identifying the missing fundamental frequency in a signal implied by its harmonic frequencies. It is often used in signal processing for analyzing functions or series of values, such as time domain signals.", imageName: "CHI", videoName: "LMtest"),
                 ModelParameters(name: "White test of homoskedasticity", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: testsAdvanced.WhiteHomo(), description: "In statistics, the White test is a statistical test that establishes whether the variance of the errors in a regression model is constant: that is for homoskedasticity.These methods have become extremely widely used, making this paper one of the most cited articles in economics.[2]In cases where the White test statistic is statistically significant, heteroskedasticity may not necessarily be the cause; instead the problem could be a specification error. In other words, the White test can be a test of heteroskedasticity or specification error or both. If no cross product terms are introduced in the White test procedure, then this is a test of pure heteroskedasticity. If cross products are introduced in the model, then it is a test of both heteroskedasticity and specification bias.", imageName: "CHI", videoName: "WhiteHomo")
            ]
            let tResults = model.parametersT
            parametersResults.append(ModelParameters(name: "Test t for free variable", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: tResults[0], description: "A statistically significant t-test result is one in which a difference between two groups is unlikely to have occurred because the sample happened to be atypical. Statistical significance is determined by the size of the difference between the group averages, the sample size, and the standard deviations of the groups. For practical purposes statistical significance suggests that the two larger populations from which we sample are “actually” different.", imageName: "T", videoName: "tTest"))
            for i in 0..<model.k{
                let tmpElement = ModelParameters(name: "Test t for \(model.chosenXHeader[i]) variable", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: tResults[i+1], description: "A statistically significant t-test result is one in which a difference between two groups is unlikely to have occurred because the sample happened to be atypical. Statistical significance is determined by the size of the difference between the group averages, the sample size, and the standard deviations of the groups. For practical purposes statistical significance suggests that the two larger populations from which we sample are “actually” different.", imageName: "T", videoName: "tTest")
            parametersResults.append(tmpElement)
            }
        }
    }
    var model = Model()
    var parametersResults = [ModelParameters]()
    var criticalParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Critical"})
        }
    }
    var warningParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Warning"})
        }
    }
    var normalParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Normal"})
        }
    }
    var nanParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Nan"})
        }
    }
    
    var parametersCategorized : [[ModelParameters]]{
        get{
            var tmp = [[ModelParameters]]()
            tmp.append(criticalParameters)
            tmp.append(warningParameters)
            tmp.append(normalParameters)
            tmp.append(nanParameters)
            return tmp
        }
    }
    // MARK: Buttons
    @IBOutlet weak var doneButton: UIButton!

    // MARK: Views
    @IBOutlet weak var visualViewToBlur: UIVisualEffectView!
    @IBOutlet var chooseXYView: UIView!
    @IBOutlet weak var chooseYTableView: UITableView!
    @IBOutlet weak var chooseXTableView: UITableView!
    
    // MARK: Parameters details view
    @IBOutlet weak var parametersView: UIView!
    @IBOutlet weak var parametersViewTitle: UILabel!
    @IBOutlet weak var parametersViewImage: UIImageView!
    @IBOutlet weak var parametersViewDetails: UILabel!
    
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    var newModel = true{
        didSet{
            if newModel{
                topLabel.isHidden = true
                topTableView.isHidden = true
                model.n = model.allObservations.count
                sideMenuButton.isEnabled = false
            }
        }
    }
    var chosenY = String()
    var chosenX = [String]()
    // MARK: Getter that updates everything after loading new data
    var newPath = ""{
        didSet{
            topTableView.isHidden = true
            topLabel.isHidden = true
            chosenY.removeAll()
            chosenX.removeAll()
            if self.newPath.contains(".csv"){
                do{
                    model = try Model(path: self.newPath)
                }catch let er as ImportError{
                    self.playErrorScreen(msg: er.rawValue, blurView: self.visualViewToBlur, mainViewController: self, alertToDismiss: nil)
                    self.editButton.isEnabled = false
                    return
                }catch{
                    
                }
            }else{
                do{
                    model = try Model(withHeaders: false, observationLabeled: false, path: newPath)
                }catch let er as ImportError{
                    self.playErrorScreen(msg: er.rawValue, blurView: self.visualViewToBlur, mainViewController: self, alertToDismiss: nil)
                    self.editButton.isEnabled = false
                    return
                }catch{
                    
                }
            }
            imgViewBeforeImport.removeFromSuperview()
            imgViewBeforeEdit.center = self.view.center
            self.view.addSubview(imgViewBeforeEdit)
            self.newModel = true
            //let _ = parametersResults
            self.chooseYTableView.reloadData()
            self.chooseXTableView.reloadData()
            self.topTableView.reloadData()
            playShortAnimationOnce(mainViewController: self)
        }
    }
    let defaults = UserDefaults.standard
    
    var chosenParameters : ModelParameters?
    
    let imgViewBeforeImport = UIImageView.init(image: UIImage(named: "importData"))
    let imgViewBeforeEdit = UIImageView.init(image: UIImage(named: "editChoose"))
    
    // MARK: Deinit that delete views in background
    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        chooseXTableView.delegate = self
        chooseXTableView.dataSource = self
        chooseYTableView.delegate = self
        chooseYTableView.dataSource = self
        
        chooseXTableView.layer.borderWidth = 0.2
        chooseYTableView.layer.borderWidth = 0.2
        
        chooseXTableView.layer.cornerRadius = 5.0
        chooseYTableView.layer.cornerRadius = 5.0
        
        chooseXYView.layer.cornerRadius = 10
        parametersView.layer.cornerRadius = 10
        visualViewToBlur.effect = nil
        
        createDirectory()
        (UIApplication.shared.delegate as! AppDelegate).adProvider.viewController = self
        (UIApplication.shared.delegate as! AppDelegate).adProvider.initiateAds()
        
        let tapOnImgBeforeImport = UITapGestureRecognizer(target: self, action: #selector(self.addButtonPressed(_:)))
        imgViewBeforeImport.addGestureRecognizer(tapOnImgBeforeImport)
        imgViewBeforeImport.isUserInteractionEnabled = true
        
        let tapOnImgBeforeEdit = UITapGestureRecognizer(target: self, action: #selector(self.chooseXYButtonPressed(_:)))
        imgViewBeforeEdit.addGestureRecognizer(tapOnImgBeforeEdit)
        imgViewBeforeEdit.isUserInteractionEnabled = true
        
        if !(UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
            premiumLabel.isHidden = true
            premiumLabel2.isHidden = true
        }
       
        playButton.layer.cornerRadius = 10.0
        
        if model.squareR.isNaN{
            topTableView.isHidden = true
            topLabel.isHidden = true
            saveButton.isEnabled = false
            editButton.isEnabled = false
            
            imgViewBeforeImport.center = self.view.center
            self.view.addSubview(imgViewBeforeImport)
        }
        else{
            var tmpXText = String()
            model.chosenXHeader.forEach { (str) in
                tmpXText = tmpXText + " " + str
            }
            var tmpEq = String()
            for i in 0..<model.getOLSRegressionEquation().count{
                if i==0{
                    tmpEq = tmpEq + " " + String(format:"%.2f",model.getOLSRegressionEquation()[0])
                }else{
                    let num = model.getOLSRegressionEquation()[i]
                    if num>=0{
                        tmpEq = tmpEq + " + " + String(format:"%.2f",num) + "×" + model.chosenXHeader[i-1]
                    }else{
                        tmpEq = tmpEq + " " + String(format:"%.2f",num).replacingOccurrences(of: "-", with: "- ") + "×" + model.chosenXHeader[i-1]
                    }
                }
            }
            let boldAttr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]
            let text1 = NSAttributedString(string: "Regressand: ", attributes: boldAttr)
            let text2 = NSAttributedString(string: "\(model.chosenYHeader)")
            let text3 = NSAttributedString(string: "\nRegressor: ", attributes: boldAttr)
            let text4 = NSAttributedString(string: "\(tmpXText)")
            let text5 = NSAttributedString(string: "\nEquation: ", attributes: boldAttr)
            let text6 = NSAttributedString(string: "\(tmpEq)")
            let text7 = NSAttributedString(string: "\nObservations: ", attributes: boldAttr)
            let text8 = NSAttributedString(string: "\(model.n)")
            let text = NSMutableAttributedString()
            text.append(text1)
            text.append(text2)
            text.append(text3)
            text.append(text4)
            text.append(text5)
            text.append(text6)
            text.append(text7)
            text.append(text8)
            topLabel.attributedText = text
            //topLabel.text = "Regressand: \(model.chosenYHeader)\nRegressor: \(tmpXText)\nEquation: \(tmpEq)\nObservations: \(model.n)"
        }
        if !newModel{
            loadSavedModel()
        }else{
            sideMenuButton.isEnabled = false
        }
        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        playButton.addGestureRecognizer(tapOnImage)
        
        self.topTableView.separatorColor = UIColor.clear;
         //label
        selectObjectForTopLabel = LongTappableToSaveContext(newObject: self.topLabel, toBlur: self.visualViewToBlur, targetViewController: self)
        
        let longTapOnLabel = UILongPressGestureRecognizer(target: selectObjectForTopLabel, action: #selector(selectObjectForTopLabel.longTapOnObject(sender:)))
        topLabel.addGestureRecognizer(longTapOnLabel)
        
        //table
        selectObjectForTableView = LongTappableToSaveContext(newObject: self.topTableView, toBlur: self.visualViewToBlur, targetViewController: self)
        
        let longTapOnTableView = UILongPressGestureRecognizer(target: selectObjectForTableView, action: #selector(selectObjectForTableView.longTapOnObject(sender:)))
        topTableView.addGestureRecognizer(longTapOnTableView)
    }
    
    var first = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !first{
            first = true
            (UIApplication.shared.delegate as! AppDelegate).adProvider.showFullScreenAd()
        }else{
            (UIApplication.shared.delegate as! AppDelegate).adProvider.createNewAd()
        }
    }
    
    var selectObjectForTableView = LongTappableToSaveContext()
    var selectObjectForTopLabel = LongTappableToSaveContext()
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        dismissAllViews()
        (UIApplication.shared.delegate as! AppDelegate).adProvider.showFullScreenAd()
        
        //MARK: Edit file name resticition/alerts
        let alertPopOver = UIAlertController(title: "Choose option", message: "", preferredStyle: .actionSheet)
        alertPopOver.popoverPresentationController?.barButtonItem = sender
        
        let overrideOption = UIAlertAction(title: "Override current", style: .destructive) { (alert) in
            let alertSureController = UIAlertController(title: "Override", message: "Are you sure you want override current model?", preferredStyle: .alert)
            let yes = UIAlertAction.init(title: "Yes", style: UIAlertAction.Style.destructive, handler: { (alert) in
                do{
                    try self.save(object: self.model, pathExternal: self.openedFilePath + ".plist")
                    self.copyDocumentsToiCloudDirectory()
                    self.playShortAnimationOnce(mainViewController: self)
                }catch let er as SavingErrors{
                    self.playErrorScreen(msg: er.rawValue, blurView: self.visualViewToBlur, mainViewController: self, alertToDismiss: nil)
                }catch{}
                }
        )
            let no = UIAlertAction.init(title: "No", style: UIAlertAction.Style.cancel){ (alert) in
                alertSureController.dismiss(animated: true, completion: nil)
            }
            alertSureController.addAction(yes)
            alertSureController.addAction(no)
            self.present(alertSureController,animated: true)
        }
        
        let saveLocallyOption = UIAlertAction(title: "Save", style: .default) { (alert) in
            alertPopOver.removeFromParent()
                let alertController = UIAlertController.init(title: "Model name", message: "Choose name for model saving", preferredStyle: .alert)
                var text = ""
                alertController.addTextField(configurationHandler: nil)
                let alert = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) in
                    text = alertController.textFields![0].text!
                    if text.count > 3{
                        if !self.exists(fileName: text){
                            if self.getListOfFiles().contains(text + ".plist"){
                                self.playErrorScreen(msg: "File exists!", blurView: self.visualViewToBlur, mainViewController: self, alertToDismiss: alertController)
                            }else{
                                self.model.name = text
                                do{
                                    try self.save(object: self.model, fileName: text)
                                    self.copyDocumentsToiCloudDirectory()
                                }catch let er as SavingErrors{
                                    self.playErrorScreen(msg: er.rawValue, blurView: self.visualViewToBlur, mainViewController: self, alertToDismiss: nil)
                                }catch{
                                    
                                }
                                self.openedFileName = text
                                let path : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let name = "/Saved Models/" + text + ".plist"
                                let url = path.appendingPathComponent(name)
                                self.openedFilePath = url.path
                                self.model.name = text
                                self.playShortAnimationOnce(mainViewController: self, animationName: "done")
                            }
                            
                        }else{
                            self.playErrorScreen(msg: "File exists!", blurView: self.visualViewToBlur, mainViewController: self, alertToDismiss: alertController)
                        }
                    }else{
                        self.playErrorScreen(msg: "Wrong file name!", blurView: self.visualViewToBlur, mainViewController: self, alertToDismiss: alertController)
                    }
                }
                alertController.addAction(alert)
                self.present(alertController,animated: true)
        }
        alertPopOver.addAction(saveLocallyOption)
        if openedFileName != ""{
            alertPopOver.addAction(overrideOption)
        }
        
        
        
        present(alertPopOver, animated: true)
    }
    
    private func createDirectory(){
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                try? FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
            }
        }
    }
    
    private func copyDocumentsToiCloudDirectory() {
        guard UserDefaults.standard.bool(forKey: "icloudSave") else {return}
        guard let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last else { return }
        
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else { return }
        
        var isDir:ObjCBool = false
        
        if FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            try? FileManager.default.removeItem(at: iCloudDocumentsURL)
        }
        
        try? FileManager.default.copyItem(at: localDocumentsURL, to: iCloudDocumentsURL)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Close model", message: "Are you sure? All unsaved data will be lost", preferredStyle: .alert)

        let yes = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        let no = UIAlertAction(title: "No", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(yes)
        alertController.addAction(no)
        present(alertController, animated: true)
    }
    
    // MARK: Prepare of segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSideMenu"{
            dismissAllViews()
            self.view.sendSubviewToBack(visualViewToBlur)
            let target = segue.destination as! SideMenuNavigationController
            target.presentationStyle = .menuSlideIn
            target.pushStyle = .popWhenPossible
            target.menuWidth = 300
            target.dismissOnPresent = true
            target.enableTapToDismissGesture = true
            target.blurEffectStyle = UIBlurEffect.Style.dark
            target.sideMenuDelegate = self
            //target.menuBlurEffectStyle = UIBlurEffect.Style.light
            let targetVC = target.topViewController as! SideMenuView
            targetVC.model = model
            targetVC.sendBackSpreedVCDelegate = self
            targetVC.viewController = self
        }
        if segue.identifier == "back"{
            self.removeFromParent()
        }
    }
    
    // MARK: New import
    @objc @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        dismissAllViews()
        (UIApplication.shared.delegate as! AppDelegate).adProvider.showFullScreenAd()
        
        self.saveButton.isEnabled = false
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion:  nil)
    }
    
    // MARK: Window pop up for chosing X and Y
    @IBAction func choosingXYDone(_ sender: UIButton) {
        (UIApplication.shared.delegate as! AppDelegate).adProvider.showFullScreenAd()
        UIView.animate(withDuration: 0.4, animations: {
            self.chooseXYView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.chooseXYView.alpha = 0
            self.topTableView.isHidden = false
            self.visualViewToBlur.effect = nil
        }) { (success) in
            self.chooseXYView.removeFromSuperview()
            self.view.sendSubviewToBack(self.visualViewToBlur)
        }
        topTableView.isHidden = true
        if self.chosenX.count > 0 && self.chosenY != ""{
            imgViewBeforeEdit.removeFromSuperview()
            let positionY = model.headers.firstIndex(of: self.chosenY)
            var positionX = [Int]()
            self.chosenX.forEach { (element) in
                positionX.append(model.headers.firstIndex(of: element)!)
            }
            var tmpY = [[Double]]()
            model.allObservations.forEach { (observation) in
                tmpY.append([observation.observationArray[positionY!]])
            }
            model.chosenY = tmpY
            var tmpX = [[Double]]()
            var tmpXrow = [Double]()
            var i = 0
            positionX.forEach { (position) in
                model.allObservations.forEach { (observation) in
                    tmpXrow.append(observation.observationArray[positionX[i]])
                }
                tmpX.append(tmpXrow)
                tmpXrow.removeAll()
                i = i + 1
            }
            tmpX.insert([Double](repeating: 1.0, count: model.n), at: 0)
            var tmp = Array(repeating: Array(repeating: 0.0, count: tmpX.count), count: tmpX[0].count)
            
            for row in 0..<tmp.count{
                for col in 0..<tmp[0].count{
                    tmp[row][col] = tmpX[col][row]
                }
            }
            
            
            model.chosenX = tmp
            model.chosenXHeader = self.chosenX
            model.chosenYHeader = self.chosenY
            var tmpXText = String()
            model.chosenXHeader.forEach { (str) in
                tmpXText = tmpXText + " " + str
            }
            var tmpEq = String()
            for i in 0..<model.getOLSRegressionEquation().count{
                if i==0{
                    tmpEq = tmpEq + " " + String(format:"%.2f",model.getOLSRegressionEquation()[0])
                }else{
                    let num = model.getOLSRegressionEquation()[i]
                    if num>=0{
                        tmpEq = tmpEq + " + " + String(format:"%.2f",num) + "×" + model.chosenXHeader[i-1]
                    }else{
                        tmpEq = tmpEq + " " + String(format:"%.2f",num).replacingOccurrences(of: "-", with: "- ") + "×" + model.chosenXHeader[i-1]
                    }
                }
            }
            topLabel.isHidden = false
            sideMenuButton.isEnabled = true
            newModel = false
            saveButton.isEnabled = true
            
            self.topTableView.isHidden = true
            playLoadingAsync(tasksToDoAsync: {
                self.updateParametersResults = true
            }, tasksToMainBack: {
                UIView.animate(withDuration: 0.4) {
                    //self.visualViewToBlur.backgroundColor = UIColor.clear
                    self.topTableView.isHidden = false
                }
                self.topTableView.reloadData()
            }, mainView: self.view)
            let boldAttr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]
            let text1 = NSAttributedString(string: "Regressand: ", attributes: boldAttr)
            let text2 = NSAttributedString(string: "\(model.chosenYHeader)")
            let text3 = NSAttributedString(string: "\nRegressor: ", attributes: boldAttr)
            let text4 = NSAttributedString(string: "\(tmpXText)")
            let text5 = NSAttributedString(string: "\nEquation: ", attributes: boldAttr)
            let text6 = NSAttributedString(string: "\(tmpEq)")
            let text7 = NSAttributedString(string: "\nObservations: ", attributes: boldAttr)
            let text8 = NSAttributedString(string: "\(model.n)")
            let text = NSMutableAttributedString()
            text.append(text1)
            text.append(text2)
            text.append(text3)
            text.append(text4)
            text.append(text5)
            text.append(text6)
            text.append(text7)
            text.append(text8)
            topLabel.attributedText = text
            //topLabel.text = "Regressand: \(model.chosenYHeader)\nRegressor:   \(tmpXText)\nEquation: \(tmpEq)\nObservations: \(model.n)"
            topLabel.showHint(text: "Long press to activate saving option, then press the button that will be shown. This will work on every element in application like text, tables, charts! [VIP]")
            self.view.layoutIfNeeded()
            if defaults.bool(forKey: "firstChecker"){
                topTableView.showHint(text: "Remember test values shown here are p-values. Tap on parameter to show details")
                self.view.layoutIfNeeded()
            }else{
                defaults.set(true, forKey: "firstChecker")
            }
        }else{
            topLabel.isHidden = true
            topTableView.isHidden = true
            if !self.view.subviews.contains(self.imgViewBeforeEdit){
                imgViewBeforeEdit.center = self.view.center
                self.view.addSubview(self.imgViewBeforeEdit)
            }
        }
    }
    @objc @IBAction func chooseXYButtonPressed(_ sender: UIBarButtonItem) {
        (UIApplication.shared.delegate as! AppDelegate).adProvider.showFullScreenAd()
        
        if !(UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
            premiumLabel.isHidden = true
        }
        self.view.bringSubviewToFront(visualViewToBlur)
        self.view.addSubview(chooseXYView)
        chooseXYView.alpha = 0
        chooseXYView.center = self.view.center
        chooseXYView.transform = CGAffineTransform(translationX: 0.0, y: 300)
        UIView.animate(withDuration: 0.4) {
            self.topTableView.isHidden = true
            self.visualViewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.chooseXYView.alpha = 1
            self.chooseXYView.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func closeChooseXY(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.chooseXYView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.chooseXYView.alpha = 0
            if self.model.chosenX.count > 0 && self.model.squareR.isFinite{
                self.topTableView.isHidden = false
            }
            self.visualViewToBlur.effect = nil
        }) { (success) in
            self.chooseXYView.removeFromSuperview()
            self.view.sendSubviewToBack(self.visualViewToBlur)
        }
    }
    func loadSavedModel(){
        self.chosenY = model.chosenYHeader
        self.chosenX = model.chosenXHeader
        playLoadingAsync(tasksToDoAsync: {
            self.parametersResultsLoad()
        }, tasksToMainBack: {
            self.topTableView.reloadData()
        }, mainView: self.view)
    }
    
    @objc func longPressOnTableView(_ sender: UIGestureRecognizer){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.center = self.topTableView.center
        button.backgroundColor = .systemBackground
        button.alpha = 0.9
        button.layer.borderWidth = 0.1
        let image = UIImage.init(named: "upload")
        let imageFilled = UIImage.init(named: "upload_filled")
        button.setImage(image, for: .normal)
        button.setImage(imageFilled, for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 25, right: 20)
        
        if sender.state == .ended{
            Dispatch.DispatchQueue.global(qos: .background).async {
                sleep(3)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1.0, animations: {
                        button.alpha = 0.0
                        self.topTableView.layer.borderWidth = 0.0
                        self.visualViewToBlur.effect = nil
                        self.topTableView.layer.opacity = 1.0
                    })
                    self.topTableView.layer.removeAllAnimations()
                    self.view.subviews.forEach(){
                        if $0 is UIButton{
                            $0.removeFromSuperview()
                        }
                    }
                }
            }
        }else if sender.state == .began{
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 1.2
            pulseAnimation.toValue = NSNumber(value: 1.08)
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
            
            UIView.animate(withDuration: 1.0, animations: {
                self.visualViewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                self.topTableView.layer.borderWidth = 0.1
                self.topTableView.layer.opacity = 0.8
            })
            
            self.topTableView.layer.add(pulseAnimation, forKey: "scale")
            self.view.addSubview(button)
        }
    }
}
    // MARK: File Browser Window
extension ViewController : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        let url = urls[0]
        let isSecuredURL = url.startAccessingSecurityScopedResource() == true
        editButton.isEnabled = true
        self.newPath = url.path

        if (isSecuredURL) {
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if chosenY.count > 0{
            saveButton.isEnabled = true
        }
    }
}

    // MARK: Pop up windows for choosing X Y tables
extension ViewController :  UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == topTableView{
            return self.topTableSections.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == topTableView{
            return topTableSections[section]
        }
        else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == topTableView{
            return parametersCategorized[section].count
        }else{
            return model.headers.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        
        if tableView == topTableView{
            let par = parametersCategorized[indexPath.section][indexPath.row]
            
            let boldAttr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
            let text1 = NSAttributedString(string: par.name + " = ")
            let text2 = NSAttributedString(string: String(format:"%.2f",Double(par.value)), attributes: boldAttr)
            let text = NSMutableAttributedString()
            text.append(text1)
            text.append(text2)
            cell.textLabel?.attributedText = text
            cell.textLabel?.numberOfLines = 0
            switch indexPath.section{
                case 0:
                    cell.imageView?.image = UIImage.init(named: "critical")
                case 1:
                    cell.imageView?.image = UIImage.init(named: "warning")
                case 2:
                    cell.imageView?.image = UIImage.init(named: "ok")
                case 3:
                    cell.textLabel?.text = par.name
                    cell.imageView?.image = UIImage.init(named: "nan")
                default:break
            }
        }else{
            let text = model.headers[indexPath.row]
            cell.textLabel?.text = text
            cell.textLabel?.textAlignment = NSTextAlignment.center
            if tableView == self.chooseXTableView && chosenX.contains(text){
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }else if tableView == self.chooseYTableView && chosenY == text{
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == topTableView{
            loadParametersView(item: parametersCategorized[indexPath.section][indexPath.row])
        }else{
            let cell = tableView.cellForRow(at: indexPath)
            
            if tableView == self.chooseYTableView{
                if cell?.accessoryType == UITableViewCell.AccessoryType.none && chosenY.isEmpty{
                    cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    self.chosenY = (cell?.textLabel?.text)!
                }else if cell?.accessoryType == UITableViewCell.AccessoryType.checkmark{
                    cell?.accessoryType = UITableViewCell.AccessoryType.none
                    self.chosenY.removeAll()
                }
            }
            if !(UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
                if tableView == self.chooseXTableView{
                    if cell?.accessoryType == UITableViewCell.AccessoryType.none{
                        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }else{
                        cell?.accessoryType = UITableViewCell.AccessoryType.none
                    }
                    let text = (cell?.textLabel?.text)!
                    if self.chosenX.contains(text){
                        self.chosenX.remove(at: chosenX.firstIndex(of: text)!)
                    }else{
                        self.chosenX.append(text)
                    }
                }
            }else{
                if tableView == self.chooseXTableView{
                    if cell?.accessoryType == UITableViewCell.AccessoryType.none && chosenX.count<2{
                        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }else{
                        cell?.accessoryType = UITableViewCell.AccessoryType.none
                    }
                    let text = (cell?.textLabel?.text)!
                    if self.chosenX.contains(text){
                        self.chosenX.remove(at: chosenX.firstIndex(of: text)!)
                    }else{
                        self.chosenX.append(text)
                    }
                }
            }
        }
    }
}

//MARK: Functions for parameters view

extension ViewController{
    
    func loadParametersView(item : ModelParameters){
        if !(UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
            premiumLabel.isHidden = true
        }
        parametersViewTitle.text = item.name
        parametersViewDetails.text = item.description
        parametersViewImage.image = UIImage(named: item.imageName)
        self.view.bringSubviewToFront(visualViewToBlur)
        self.view.addSubview(parametersView)
        parametersView.alpha = 0
        parametersView.center = self.view.center
        parametersView.transform = CGAffineTransform(translationX: 0.0, y: 300)
        chosenParameters = item
        if (chosenParameters?.videoName != nil){
            if Bundle.main.path(forResource: chosenParameters!.videoName!, ofType: "mov") == nil{
                playButton.isHidden = true
            }
        }else{
            playButton.isHidden = true
        }
        UIView.animate(withDuration: 0.4) {
            self.topTableView.isHidden = true
            self.visualViewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.parametersView.alpha = 1
            self.parametersView.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func parametersViewBackButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.parametersView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.parametersView.alpha = 0
            self.topTableView.isHidden = false
            self.visualViewToBlur.effect = nil
        }) { (success) in
            self.parametersView.removeFromSuperview()
            self.view.sendSubviewToBack(self.visualViewToBlur)
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
    
    //MARK: Gesture Recognizer for Image- Play Video
    @objc func imageTapped(){
        UIView.animate(withDuration: 0.4, animations: {
            self.playButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { (_) in
            UIView.animate(withDuration: 0.4) {
                self.playButton.transform = CGAffineTransform.identity
            }
        }
        if let path = Bundle.main.path(forResource: chosenParameters!.videoName!, ofType: "mov"){
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
    
    //MARK: Dismiss open windows
    func dismissAllViews(){
        self.view.sendSubviewToBack(visualViewToBlur)
        self.view.subviews.forEach { (view) in
            if view == chooseXYView || view == parametersView{
                UIView.animate(withDuration: 0.4, animations: {
                    view.transform = CGAffineTransform(translationX: 0.0, y: 300)
                    view.alpha = 0
                    self.topTableView.isHidden = false
                    self.visualViewToBlur.effect = nil
                }) { (success) in
                    view.removeFromSuperview()
                }
            }
        }
    }
}

extension ViewController: SideMenuNavigationControllerDelegate{
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        blurWhenMenuPresented = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurWhenMenuPresented?.frame = view.frame
        blurWhenMenuPresented?.center = view.center
        blurWhenMenuPresented?.alpha = 0.0
        guard blurWhenMenuPresented != nil else {return}
        view.addSubview(blurWhenMenuPresented!)
        UIView.animate(withDuration: 0.5) {
            self.blurWhenMenuPresented?.alpha = 1.0
        }
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.blurWhenMenuPresented?.alpha = 0.0
        }) { (_) in
            self.blurWhenMenuPresented?.removeFromSuperview()
        }
    }
}

extension ViewController: SettingsVCDelegate{
    func removeAds() {
        self.adView.isHidden = true
        self.adView.delegate = nil
    }
}
