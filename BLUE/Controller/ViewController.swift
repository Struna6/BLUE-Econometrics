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

protocol Transposable{
    func transposeArray(array : [[Double]], rows : Int, cols : Int) -> [[Double]]
}
extension Transposable{
    func transposeArray(array : [[Double]], rows : Int, cols : Int) -> [[Double]]{
        var tmpX2 = Array(repeating: Array(repeating: 0.0, count: rows), count: cols)
        var i = 0
        var j = 0
        array.forEach { (row) in
            j = 0
            row.forEach({ (item) in
                tmpX2[j][i] = item
                j = j + 1
            })
            i = i + 1
        }
        return tmpX2
    }
}

class ViewController: UIViewController, Transposable, Storage{
    //var model = Model(withHeaders: false, observationLabeled: false, path: Bundle.main.path(forResource: "test1", ofType: "txt")!)
    @IBOutlet weak var topTableView: UITableView!
    
    let topTableSections = ["Critical","Warning","Normal"]
    var model = Model()
    var parametersResults : [ModelParameters]{
        get{
            return [ModelParameters(name: "R\u{00B2}", criticalFloor: 0.5, warningFloor: 0.75, value: model.squareR, description: "The better the linear regression (on the right) fits the data in comparison to the simple average (on the left graph), the closer the value of R\u{00B2} is to 1. The areas of the blue squares represent the squared residuals with respect to the linear regression. The areas of the red squares represent the squared residuals with respect to the average value.", imageName: "R", videoName: "sampleVideo")
            ]
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
            model = Model(withHeaders: false, observationLabeled: false, path: newPath)
            chooseYTableView.reloadData()
            chooseXTableView.reloadData()
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
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
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
            var tmp = self.parametersResults
            tmp = tmp.filter{$0.category.rawValue == topTableSections[section]}
            return tmp.count
        }else{
            return model.headers.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        if tableView == topTableView{
            cell.textLabel?.text = parametersResults[indexPath.row].name + " = " + String(format:"%.4f",Double(parametersResults[indexPath.row].value))
            switch parametersResults[indexPath.row].category{
                case .Critical:
                    cell.imageView?.image = UIImage.init(named: "critical")
                    cell.textLabel?.textColor = UIColor.init(named: "red")
                case .Warning:
                    cell.imageView?.image = UIImage.init(named: "warning")
                default: break
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
            loadParametersView(item: parametersResults[indexPath.row])
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

