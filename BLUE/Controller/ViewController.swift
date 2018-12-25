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

// MARK: Protocol for Transponating Arrays


class ViewController: UIViewController, Transposable, Storage{
    //var model = Model(withHeaders: false, observationLabeled: false, path: Bundle.main.path(forResource: "test1", ofType: "txt")!)
    @IBOutlet weak var topTableView: UITableView!
    
    @IBOutlet weak var topLabel: UILabel!
    let topTableSections = ["Critical","Warning","Normal"]
    var model = Model()
    var parametersResults : [ModelParameters]{
        get{
            if model.squareR.isNaN{
                return []
            }else{
                return [
                ModelParameters(name: "R\u{00B2}", isLess: true, criticalFloor: 0.5, warningFloor: 0.75, value: model.squareR, description: "The better the linear regression (on the right) fits the data in comparison to the simple average (on the left graph), the closer the value of R\u{00B2} is to 1. The areas of the blue squares represent the squared residuals with respect to the linear regression. The areas of the red squares represent the squared residuals with respect to the average value.", imageName: "R", videoName: "sampleVideo"),
                ModelParameters(name: "Quantile odd observations", isLess: false, criticalFloor: Double(model.k)*0.1, warningFloor: 1, value: Double(model.calculateNumberOfOddObservations()), description: "In statistics and probability quantiles are cut points dividing the range of a probability distribution into continuous intervals with equal probabilities, or dividing the observations in a sample in the same way. There is one less quantile than the number of groups created. Thus quartiles are the three cut points that will divide a dataset into four equal-sized groups. Common quantiles have special names: for instance quartile, decile (creating 10 groups: see below for more). The groups created are termed halves, thirds, quarters, etc., though sometimes the terms for the quantile are used for the groups created, rather than for the cut points.", imageName: "Q", videoName: "sampleVideo")
                ]
            }
        }
    }
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
    var parametersCategorized : [[ModelParameters]]{
        get{
            var tmp = [[ModelParameters]]()
            tmp.append(criticalParameters)
            tmp.append(warningParameters)
            tmp.append(normalParameters)
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
    @IBOutlet var parametersView: UIView!
    @IBOutlet weak var parametersViewTitle: UILabel!
    @IBOutlet weak var parametersViewImage: UIImageView!
    @IBOutlet weak var parametersViewDetails: UILabel!
    
    var newModel = true
    var chosenY = String()
    var chosenX = [String]()
    // MARK: Getter that updates everything after loading new data
    var newPath = ""{
        didSet{
            if newPath.contains(".csv"){
                model = Model(path: newPath)
            }else{
                model = Model(withHeaders: false, observationLabeled: false, path: newPath)
            }
            chooseYTableView.reloadData()
            chooseXTableView.reloadData()
            topTableView.reloadData()
            topTableView.isHidden = true
            topLabel.isHidden = true
            chosenY.removeAll()
            chosenX.removeAll()
        }
    }
    // MARK: Deinit that delete views in background
    
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseXTableView.delegate = self
        chooseXTableView.dataSource = self
        chooseYTableView.delegate = self
        chooseYTableView.dataSource = self
        chooseXYView.layer.cornerRadius = 10
        parametersView.layer.cornerRadius = 10
        visualViewToBlur.effect = nil
        if model.squareR.isNaN{
            topTableView.isHidden = true
            topLabel.isHidden = true
        }
        else{
            var tmpXText = String()
            model.chosenXHeader.forEach { (str) in
                tmpXText = tmpXText + " " + str
            }
            var tmpEq = String()
            for i in 0..<model.getOLSRegressionEquation().count{
                if i==0{
                    tmpEq = tmpEq + String(format:"%.2f",model.getOLSRegressionEquation()[0])
                }else{
                    let num = model.getOLSRegressionEquation()[i]
                    if num>=0{
                        tmpEq = tmpEq + " + " + String(format:"%.2f",num) + model.chosenXHeader[i-1]
                    }else{
                        tmpEq = tmpEq + " " + String(format:"%.2f",num) + model.chosenXHeader[i-1]
                    }
                }
            }
            topLabel.text = "Regressand: \(model.chosenYHeader)\nRegressors:  \(tmpXText)\nEquation: \(tmpEq)"
        }
        if !newModel{
            loadSavedModel()
        }
        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        parametersViewImage.addGestureRecognizer(tapOnImage)
        self.topTableView.separatorColor = UIColor.clear;
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        dismissAllViews()
        //MARK: Edit file name resticition/alerts
        let alertController = UIAlertController.init(title: "Model name", message: "Choose name for model saving", preferredStyle: .alert)
        var text = ""
        alertController.addTextField { (textField) in
        }
        print(text)
        let alert = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) in
            text = alertController.textFields![0].text!
            self.save(object: self.model, fileName: text)
        }
        alertController.addAction(alert)
        present(alertController,animated: true)
        
    }
    
    // MARK: Prepare of segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSideMenu"{
            dismissAllViews()
            let target = segue.destination as! UISideMenuNavigationController
            target.sideMenuManager.menuPresentMode = .menuDissolveIn
            target.sideMenuManager.menuPushStyle = .popWhenPossible
            target.sideMenuManager.menuWidth = 400
            target.sideMenuManager.menuAnimationFadeStrength = 0.4
            target.sideMenuManager.menuBlurEffectStyle = UIBlurEffect.Style.extraLight
            let targetVC = target.topViewController as! SideMenuView
            targetVC.model = model
        }
        if segue.identifier == "back"{
            dismissAllViews()
        }
    }
    
    // MARK: New import
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        dismissAllViews()
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        documentPicker.delegate = self
       present(documentPicker, animated: true, completion:  nil)
    }
    
    // MARK: Window pop up for chosing X and Y
    @IBAction func choosingXYDone(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.chooseXYView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.chooseXYView.alpha = 0
            self.topTableView.isHidden = false
            self.visualViewToBlur.effect = nil
        }) { (success) in
            self.chooseXYView.removeFromSuperview()
        }
        if self.chosenX.count > 0 && self.chosenY != ""{
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
            model.chosenX = transposeArray(array: tmpX, rows: i+1, cols: self.model.n)
            model.chosenXHeader = self.chosenX
            model.chosenYHeader = self.chosenY
            topTableView.reloadData()
            topTableView.isHidden = false
            var tmpXText = String()
            model.chosenXHeader.forEach { (str) in
                tmpXText = tmpXText + " " + str
            }
            var tmpEq = String()
            for i in 0..<model.getOLSRegressionEquation().count{
                if i==0{
                    tmpEq = tmpEq + String(format:"%.4f",model.getOLSRegressionEquation()[0])
                }else{
                    let num = model.getOLSRegressionEquation()[i]
                    if num>=0{
                        tmpEq = tmpEq + " + " + String(format:"%.4f",num) + model.chosenXHeader[i-1]
                    }else{
                        tmpEq = tmpEq + " " + String(format:"%.4f",num) + model.chosenXHeader[i-1]
                    }
                }
            }
            topLabel.isHidden = false
            topLabel.text = "Regressand: \(model.chosenYHeader)\nRegressor:   \(tmpXText)\nEquation: \(tmpEq)"
        }
    }
    @IBAction func chooseXYButtonPressed(_ sender: UIBarButtonItem) {
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
    
    func loadSavedModel(){
        self.chosenY = model.chosenYHeader
        self.chosenX = model.chosenXHeader
    }
}
    // MARK: File Browser Window
extension ViewController : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        self.newPath = (urls.first?.path)!
        //ADD ALERT YES?NO
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        if tableView == topTableView{
            
            let par = parametersCategorized[indexPath.section][indexPath.row]
            cell.textLabel?.text = par.name + " = " + String(format:"%.4f",Double(par.value))
            
            switch indexPath.section{
                case 0:
                    cell.imageView?.image = UIImage.init(named: "critical")
                    cell.textLabel?.textColor = UIColor.init(named: "red")
                case 1:
                    cell.imageView?.image = UIImage.init(named: "warning")
                case 2:
                    cell.imageView?.image = UIImage.init(named: "ok")
                default:break
            }
        }else{
        let text = model.headers[indexPath.row]
        cell.textLabel?.text = text
        cell.textLabel?.textAlignment = NSTextAlignment.center
        if !newModel{
            if tableView == self.chooseXTableView && chosenX.contains(text){
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }else if tableView == self.chooseYTableView && chosenY == text{
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == topTableView{
            loadParametersView(item: parametersCategorized[indexPath.section][indexPath.row])
        }else{
            let cell = tableView.cellForRow(at: indexPath)
            if cell?.accessoryType == UITableViewCell.AccessoryType.none{
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            }else{
                cell?.accessoryType = UITableViewCell.AccessoryType.none
            }
            if tableView == self.chooseYTableView{
                self.chosenY = (cell?.textLabel?.text)!
            }
            if tableView == self.chooseXTableView{
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

//MARK: Functions for parameters view

extension ViewController{
    
    func loadParametersView(item : ModelParameters){
        parametersViewTitle.text = item.name
        parametersViewDetails.text = item.description
        parametersViewImage.image = UIImage(named: item.imageName)
        self.view.addSubview(parametersView)
        parametersView.alpha = 0
        parametersView.center = self.view.center
        parametersView.transform = CGAffineTransform(translationX: 0.0, y: 300)
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
        }
    }
    
    //MARK: Gesture Recognizer for Image- Play Video
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
    
    //MARK: Dismiss open windows
    func dismissAllViews(){
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

