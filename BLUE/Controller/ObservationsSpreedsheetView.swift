//
//  ObservationsSpreedsheetView.swift
//  BLUE
//
//  Created by Karol Struniawski on 08/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit
import SpreadsheetView

class ObservationsSpreedsheetView: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate, ErrorScreenPlayable {
    @IBOutlet weak var normPicker: UIPickerView!
    @IBOutlet var normView: UIView!
    @IBOutlet weak var normChooseVar: UIPickerView!

    var col: Int{
        get{
            return observations[0].observationArray.count
        }
    }
    var row : Int{
        get{
            return observations.count
        }
    }
    var observationsLabeled = false
    var observations = [Observation]()
    var headers = [String]()
    var model = Model()
    var optionsBasedOn = [String]()
    var optionsFunction = [String]()
    var choosenFunction = String()
    var choosenVariable = Int()
    var backUpdateObservationsDelegate : BackUpdatedObservations?
    var isAddVariableOpenedOnStart = false
    var isNormalizeOpenedOnStart = false
    var selectedRow : Int?
    var selectedCol : Int?
    
    var normalizationOptions = ["Standarization",  "Unitarization"]
    var normalizationChosen = String()
    var normVarChosen = String()
    var normAsNewVar = false
    
    @IBOutlet weak var basedOnChoose: UIPickerView!
    
    @IBOutlet weak var functionChoose: UIPickerView!
    
    @IBOutlet var addObservationView: UIView!
    @IBOutlet weak var viewToBlur: UIVisualEffectView!
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        let sample = CGFloat(spreedsheet.frame.height) / CGFloat(row + 1) - 5
        if sample < CGFloat(spreedsheet.frame.height) / 30{
            return CGFloat(spreedsheet.frame.height) / 30
        }
        return CGFloat(spreedsheet.frame.height) / CGFloat(row + 1) - 5
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        let colTmp = observationsLabeled ? col+1 : col
        let sample = CGFloat(spreedsheet.frame.width) / CGFloat(colTmp) - 5
        if sample < CGFloat(spreedsheet.frame.width) / 4{
            return CGFloat(spreedsheet.frame.width) / 4
        }
        return CGFloat(spreedsheet.frame.width) / CGFloat(colTmp) - 10
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return observationsLabeled ? col+1 : col
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return row + 1
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return observationsLabeled ? 1 : 0
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if selectedCol == indexPath.column && selectedRow == indexPath.row{
            selectedCol = nil
            selectedRow = nil
        }else{
            selectedCol = indexPath.column
            selectedRow = indexPath.row
        }
        self.spreedsheet.reloadData()
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.column == 0 && observationsLabeled{
            let cell = spreedsheet.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            if indexPath.row != 0{
                cell.label.text = observations[indexPath.row-1].label
            }
            if selectedRow == indexPath.row && selectedCol == indexPath.column{
                cell.backgroundColor = UIColor.blue
            }
            return cell
        }
        if indexPath.row == 0 {
            let cell = spreedsheet.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            if observationsLabeled && indexPath.column == 0{
                if selectedRow == indexPath.row && selectedCol == indexPath.column{
                    cell.backgroundColor = UIColor.blue
                    cell.label.textColor = .white
                }
                return cell
            }
            if observationsLabeled{
                cell.label.text = String(headers[indexPath.column-1])
                if selectedRow == indexPath.row && selectedCol == indexPath.column{
                    cell.backgroundColor = UIColor.blue
                    cell.label.textColor = .white
                }
                return cell
            }
            cell.label.text = String(headers[indexPath.column])
            if selectedRow == indexPath.row && selectedCol == indexPath.column{
                cell.backgroundColor = UIColor.blue
                cell.label.textColor = .white
            }
            return cell
        }
        else{
            let cell = spreedsheet.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            if observationsLabeled && indexPath.column == 0{
                if selectedRow == indexPath.row && selectedCol == indexPath.column{
                    cell.backgroundColor = UIColor.blue
                    cell.label.textColor = .white
                }
                return cell
            }
            if observationsLabeled{
                cell.label.text = String(format: "%.2f",observations[indexPath.row-1].observationArray[indexPath.column-1])
                if selectedRow == indexPath.row && selectedCol == indexPath.column{
                    cell.backgroundColor = UIColor.blue
                    cell.label.textColor = .white
                }
                return cell
            }
            cell.label.text = String(format: "%.2f",observations[indexPath.row-1].observationArray[indexPath.column])
            if selectedRow == indexPath.row && selectedCol == indexPath.column{
                cell.backgroundColor = UIColor.blue
                cell.label.textColor = .white
            }
            return cell
        }
    }
    
    var selectObjectForSP = LongTappableToSaveContext()
    
    @IBOutlet weak var spreedsheet: SpreadsheetView!
    override func viewDidLoad() {
        super.viewDidLoad()
        spreedsheet.register(TextCell.self, forCellWithReuseIdentifier: "TextCell")
        spreedsheet.register(HeaderCell.self, forCellWithReuseIdentifier: "HeaderCell")
        spreedsheet.delegate = self
        spreedsheet.dataSource = self
        addObservationView.layer.cornerRadius = 10
        viewToBlur.effect = nil
        optionsBasedOn = headers
        optionsBasedOn.insert("All", at: 0)
        optionsBasedOn.append("nothing")
        optionsFunction = ["Logarithm", "Power of 2", "Squere root","Exponent"]
        choosenFunction = "Logarithm"
        choosenVariable = 0
        viewToBlur.isHidden = true
        normalizationChosen = normalizationOptions[0]
        normVarChosen = optionsBasedOn[0]
        
        selectObjectForSP = LongTappableToSaveContext(newObject: self.spreedsheet, toBlur: viewToBlur, targetViewController: self)
        
        let longTapOnLabel = UILongPressGestureRecognizer(target: selectObjectForSP, action: #selector(selectObjectForSP.longTapOnObject(sender:)))
        spreedsheet.addGestureRecognizer(longTapOnLabel)
        
        if isAddVariableOpenedOnStart{
            loadAddObservationsView()
        }
        if isNormalizeOpenedOnStart{
            loadNormObservationsView()
        }
    }
    
    @IBAction func addObsButtonPressed(_ sender: UIBarButtonItem) {
        loadAddObservationsView()
    }
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        closeAddObservationsView()
        switch choosenFunction{
            case  "Logarithm":
                addVariableFunction(f: log)
            case  "Power of 2":
                addVariableFunction(f: pow, n: 2.0)
            case  "Squere root":
                addVariableFunction(f: sqrt)
            case  "Exponent":
                addVariableFunction(f: exp)
            case "Ascending":
                var tmp = [Double]()
                for i in 0..<observations.count{
                    tmp.append(Double(i))
                }
                addVariableFunction(newValues: tmp)
            case "Descending":
                var tmp = [Double]()
                for i in (0..<observations.count).reversed(){
                    tmp.append(Double(i))
                }
                addVariableFunction(newValues: tmp)
            default: return
        }
        spreedsheet.reloadData()
        backUpdateObservationsDelegate?.updatedObservations(observations: observations, headers: headers)
    }
    
    @IBAction func editModeOnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Choose option", message: "", preferredStyle: .actionSheet)
        let headerOption = UIAlertAction(title: "Edit Header", style: .default, handler: {
            action in
            alert.removeFromParent()
            self.showPopOverInputWindow(name: "Edit Header", toDo: {
                newText in
                if self.observationsLabeled{
                    self.headers[self.selectedCol!-1] = newText
                }else{
                    self.headers[self.selectedCol!] = newText
                }
            })
        })
        let labelOption = UIAlertAction(title: "Edit Label", style: .default, handler: {
            action in
            alert.removeFromParent()
            self.showPopOverInputWindow(name: "Edit Label", toDo: { (text) in
                self.observations[self.selectedRow!-1].label = text
            })
        })
        let valuesOption = UIAlertAction(title: "Edit Value", style: .default, handler: {
            action in
            alert.removeFromParent()
            self.showPopOverInputWindow(name: "Edit Value", toDo: { (text) in
                if let _ = Double(text){
                    if self.observationsLabeled{
                        self.observations[self.selectedRow!-1].observationArray[self.selectedCol!-1] = Double(text)!
                    }else{
                        self.observations[self.selectedRow!-1].observationArray[self.selectedCol!] = Double(text)!
                    }
                }
            })
        })
        let headerOptionDel = UIAlertAction(title: "Delete Column", style: .destructive, handler: {
            action in
            alert.removeFromParent()
            self.showPopOverAcceptWindow(name: "Delete Column", toDo: {
                let tmpCol = self.observationsLabeled ? self.selectedCol! + 1 : self.selectedCol
                self.headers.remove(at: tmpCol!)
                for i in 0..<self.observations.count{
                    self.observations[i].observationArray.remove(at: tmpCol!)
                }
            })
        })
        let valuesOptionDel = UIAlertAction(title: "Delete Row", style: .destructive, handler: {
            action in
            alert.removeFromParent()
            self.showPopOverAcceptWindow(name: "Delete Row", toDo: {
                self.observations.remove(at: self.selectedRow!-1)
            })
        })
        let normalizeOption = UIAlertAction(title: "Normalize", style: .destructive) { (action) in
            alert.removeFromParent()
            self.loadNormObservationsView()
        }
        
        alert.popoverPresentationController?.barButtonItem = (sender as! UIBarButtonItem)
        
        if selectedRow != nil{
            if observationsLabeled && selectedCol == 0 && selectedRow == 0{
                
            }
            if observationsLabeled && selectedCol == 0 && selectedRow != 0{
                alert.addAction(labelOption)
                alert.addAction(valuesOptionDel)
            }
            if observationsLabeled && selectedCol != 0 && selectedRow == 0{
                alert.addAction(headerOption)
                alert.addAction(headerOptionDel)
            }
            if observationsLabeled && selectedCol != 0 && selectedRow != 0{
                alert.addAction(valuesOption)
                alert.addAction(headerOptionDel)
                alert.addAction(valuesOptionDel)
            }
            if !observationsLabeled && selectedRow == 0{
                alert.addAction(headerOption)
                alert.addAction(headerOptionDel)
            }
            if !observationsLabeled && selectedRow != 0{
                alert.addAction(valuesOption)
                alert.addAction(headerOptionDel)
                alert.addAction(valuesOptionDel)
            }
        }else{
            alert.addAction(normalizeOption)
        }
        present(alert,animated: true)
    }
    
    @IBAction func addVarClose(_ sender: UIButton) {
        closeAddObservationsView()
    }
    @IBAction func normClose(_ sender: UIButton) {
        closeNormObservationsView()
    }
    
    @IBAction func normAccept(_ sender: UIButton) {
        showPopOverNormWindow()
    }
}

//MARK: Edit options functions
extension ObservationsSpreedsheetView{
    func showPopOverInputWindow(name : String, toDo : @escaping (String) -> Void){
        let alertInput = UIAlertController(title: name, message: "Enter new value", preferredStyle: .alert)
        alertInput.addTextField(configurationHandler: nil)
        
        let alertInputOK = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            if let newText = alertInput.textFields![0].text{
                if let _ = Double(newText){
                    toDo(newText)
                    self.spreedsheet.reloadData()
                    self.backUpdateObservationsDelegate?.updatedObservations(observations: self.observations, headers: self.headers)
                }else{
                    self.playErrorScreen(msg: "Wrong format of data!", blurView: self.viewToBlur, mainViewController: self, alertToDismiss : alertInput)
                }
            }
        })
        alertInput.addAction(alertInputOK)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertInput.addAction(cancelAction)
    
        self.present(alertInput,animated: true, completion: nil)
    }
    func showPopOverAcceptWindow(name : String, toDo : @escaping () -> Void){
        let alertInput = UIAlertController(title: name, message: "Are you sure", preferredStyle: .alert)
        let alertInputOK = UIAlertAction(title: "Yes", style: .destructive, handler: { (UIAlertAction) in
            toDo()
            self.spreedsheet.reloadData()
            self.backUpdateObservationsDelegate?.updatedObservations(observations: self.observations, headers: self.headers)
        })
        let alertInputNo = UIAlertAction(title: "No", style: .default, handler: nil)
        alertInput.addAction(alertInputOK)
        alertInput.addAction(alertInputNo)
        self.present(alertInput,animated: true, completion: nil)
    }
    func showPopOverNormWindow(){
        let alertInput = UIAlertController(title: "Normalization", message: "Do you want modify exisiting data or create new variable?", preferredStyle: .alert)
        let alertInputOK = UIAlertAction(title: "Exisiting", style: .destructive, handler: { (UIAlertAction) in
            self.normAsNewVar = false
            self.prepareForNormalize()
        })
        let alertInputNo = UIAlertAction(title: "New", style: .default, handler: { (UIAlertAction) in
            self.normAsNewVar = true
            self.prepareForNormalize()
        })
        alertInput.addAction(alertInputOK)
        alertInput.addAction(alertInputNo)
        self.present(alertInput,animated: true, completion: nil)
    }
}

//MARK: ADD Observations View

extension ObservationsSpreedsheetView : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == basedOnChoose{
            return optionsBasedOn.count
        }else if pickerView == normPicker{
            return normalizationOptions.count
        }else if pickerView == normChooseVar{
            return optionsBasedOn.count
        }else{
            return optionsFunction.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == basedOnChoose{
            return optionsBasedOn[row]
        }else if pickerView == normPicker{
            return normalizationOptions[row]
        }else if pickerView == normChooseVar{
            return optionsBasedOn[row]
        }else{
            return optionsFunction[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == basedOnChoose{
            if optionsBasedOn[row] == "nothing"{
                optionsFunction = ["Ascending", "Descending"]
                functionChoose.reloadAllComponents()
            }else{
                optionsFunction = ["Logarithm", "Power of 2", "Squere root","Exponent"]
                choosenVariable = optionsBasedOn.firstIndex(of: optionsBasedOn[row])!
                functionChoose.reloadAllComponents()
            }
        }else if pickerView == normPicker{
            normalizationChosen = normalizationOptions[row]
        }else if pickerView == normChooseVar{
            normVarChosen = optionsBasedOn[row]
        }else{
            choosenFunction = optionsFunction[row]
        }
    }
    
    func loadAddObservationsView(){
        self.view.addSubview(addObservationView)
        viewToBlur.isHidden = false
        addObservationView.alpha = 0
        addObservationView.center = self.view.center
        addObservationView.transform = CGAffineTransform(translationX: 0.0, y: 300)
        UIView.animate(withDuration: 0.4) {
            self.viewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.addObservationView.alpha = 1
            self.addObservationView.transform = CGAffineTransform.identity
        }
    }
    
    func closeAddObservationsView(){
        viewToBlur.isHidden = true
        UIView.animate(withDuration: 0.4, animations: {
            self.addObservationView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.addObservationView.alpha = 0
            self.viewToBlur.effect = nil
        }) { (success) in
            self.addObservationView.removeFromSuperview()
        }
    }
    
    func loadNormObservationsView(){
        self.view.addSubview(normView)
        viewToBlur.isHidden = false
        normView.alpha = 0
        normView.center = self.view.center
        normView.transform = CGAffineTransform(translationX: 0.0, y: 300)
        UIView.animate(withDuration: 0.4) {
            self.viewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.normView.alpha = 1
            self.normView.transform = CGAffineTransform.identity
        }
    }
    
    func closeNormObservationsView(){
        viewToBlur.isHidden = true
        UIView.animate(withDuration: 0.4, animations: {
            self.normView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.normView.alpha = 0
            self.viewToBlur.effect = nil
        }) { (success) in
            self.normView.removeFromSuperview()
        }
    }
    
    //ADD ERROR
    func addVariableFunction(f: (Double) -> Double){
        var tmp = [Double]()
        observations.forEach { (obs) in
            tmp.append(f(obs.observationArray[choosenVariable]))
        }
        for i in 0..<observations.count{
            observations[i].observationArray.append(tmp[i])
        }
        headers.append(choosenFunction + "_" + (headers[choosenVariable]))
    }
    func addVariableFunction(f: (Double,Double) -> Double, n: Double){
        var tmp = [Double]()
        observations.forEach { (obs) in
            tmp.append(f(obs.observationArray[choosenVariable],n))
        }
        for i in 0..<observations.count{
            observations[i].observationArray.append(tmp[i])
        }
        headers.append(choosenFunction + "_" + (headers[choosenVariable]))
    }
    func addVariableFunction(newValues : [Double]){
        for i in 0..<observations.count{
            observations[i].observationArray.append(newValues[i])
        }
        headers.append(choosenFunction)
    }

    func prepareForNormalize(){
        let chosenVarIndex = optionsBasedOn.firstIndex(of: normVarChosen)
        switch normalizationChosen{
        case "Standarization":
            normalize(varNum: chosenVarIndex!, top: model.avarage[chosenVarIndex!], bottom: model.SeCore[chosenVarIndex!])
        case "Unitarization":
            normalize(varNum: chosenVarIndex!, top: model.avarage[chosenVarIndex!], bottom: model.range[chosenVarIndex!])
        default : break
        }
        self.closeNormObservationsView()
    }
    func normalize(varNum : Int, top : Double, bottom : Double){
        if varNum == 0{
            normalizeAll(top: top, bottom: bottom)
            return
        }
        if normAsNewVar{
            var tmp = [Double]()
            for row in 0..<observations.count{
                var x = observations[row].observationArray[varNum]
                x = (x-top)/bottom
                tmp.append(x)
            }
            for i in 0..<observations.count{
                observations[i].observationArray.append(tmp[i])
            }
            headers.append("n_" + (headers[varNum]))
        }else{
            for row in 0..<observations.count{
                var x = observations[row].observationArray[varNum]
                x = (x-top)/bottom
                observations[varNum].observationArray[col] = x
            }
        }
        self.spreedsheet.reloadData()
        self.backUpdateObservationsDelegate?.updatedObservations(observations: self.observations, headers: self.headers)
    }
    func normalizeAll(top : Double, bottom : Double){
        if normAsNewVar{
            var tmp = [Double]()
            for varNum in 0..<observations[0].observationArray.count{
                for row in 0..<observations.count{
                    var x = observations[row].observationArray[varNum]
                    x = (x-top)/bottom
                    tmp.append(x)
                }
                for i in 0..<observations.count{
                    observations[i].observationArray.append(tmp[i])
                }
                headers.append("n_" + (headers[varNum]))
            }
        }else{
            for varNum in 0..<observations[0].observationArray.count{
                for row in 0..<observations.count{
                    var x = observations[row].observationArray[varNum]
                    x = (x-top)/bottom
                    observations[row].observationArray[varNum] = x
                }
            }
            headers = headers.compactMap(){"n_" + $0}
        }
        self.spreedsheet.reloadData()
        self.backUpdateObservationsDelegate?.updatedObservations(observations: self.observations, headers: self.headers)
    }
}

protocol BackUpdatedObservations {
    func updatedObservations(observations: [Observation], headers: [String])
}
extension BackUpdatedObservations where Self : ViewController{
    func updatedObservations(observations: [Observation], headers: [String]){
        model.allObservations = observations
        model.headers = headers
        newModel = true
        chosenX.removeAll()
        chosenY.removeAll()
        topTableView.reloadData()
        chooseXTableView.reloadData()
        chooseYTableView.reloadData()
        topLabel.reloadInputViews()
    }
}


//MARK: Cells

class TextCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class HeaderCell: Cell {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
