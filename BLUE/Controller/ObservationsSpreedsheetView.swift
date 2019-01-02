//
//  ObservationsSpreedsheetView.swift
//  BLUE
//
//  Created by Karol Struniawski on 08/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit
import SpreadsheetView

class ObservationsSpreedsheetView: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
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
    var optionsBasedOn = [String]()
    var optionsFunction = [String]()
    var choosenFunction = String()
    var choosenVariable = Int()
    var backUpdateObservationsDelegate : BackUpdatedObservations?
    var isAddVariableOpenedOnStart = false
    var editModeActive = false{
        didSet{
            var text : String
            if editModeActive{
                text = "activated"
            }else{
                text = "deactivated"
            }
            let alert = UIAlertController.init(title: "Edit mode " + text , message: "", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .default) { (_) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            present(alert,animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
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
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.column == 0 && observationsLabeled{
            let cell = spreedsheet.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            if indexPath.row != 0{
                cell.label.text = observations[indexPath.row-1].label
            }
            return cell
        }
        if indexPath.row == 0 {
            let cell = spreedsheet.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            if observationsLabeled && indexPath.column == 0{
                return cell
            }
            if observationsLabeled{
                cell.label.text = String(headers[indexPath.column-1])
                return cell
            }
            cell.label.text = String(headers[indexPath.column])
            return cell
        }
        else{
            let cell = spreedsheet.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            if observationsLabeled && indexPath.column == 0{
                return cell
            }
            if observationsLabeled{
                cell.label.text = String(observations[indexPath.row-1].observationArray[indexPath.column-1])
                return cell
            }
            cell.label.text = String(observations[indexPath.row-1].observationArray[indexPath.column])
            return cell
        }
    }
    
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
        optionsBasedOn.append("nothing")
        optionsFunction = ["Logarithm", "Power of 2", "Squere root","Exponent"]
        choosenFunction = "Logarithm"
        choosenVariable = 0
        viewToBlur.isHidden = true
        if isAddVariableOpenedOnStart{
            loadAddObservationsView()
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
        editModeActive = editModeActive ? false : true
//        let alert = UIAlertController(title: "Choose option", message: "", preferredStyle: .actionSheet)
//        let headerOption = UIAlertAction(title: "Edit Headers", style: .default, handler: nil)
//        let labelOption = UIAlertAction(title: "Edit Labels", style: .default, handler: nil)
//        let valuesOption = UIAlertAction(title: "Edit Values", style: .default, handler: nil)
//        let headerOptionDel = UIAlertAction(title: "Delete Variables", style: .destructive, handler: nil)
//        let valuesOptionDel = UIAlertAction(title: "Delete Observations", style: .destructive, handler: nil)
//        alert.popoverPresentationController?.barButtonItem = (sender as! UIBarButtonItem)
//        alert.addAction(headerOption)
//        alert.addAction(labelOption)
//        alert.addAction(valuesOption)
//        alert.addAction(headerOptionDel)
//        alert.addAction(valuesOptionDel)
//        present(alert,animated: true)
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
        }else{
            return optionsFunction.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == basedOnChoose{
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
                choosenVariable = headers.firstIndex(of: optionsBasedOn[row])!
                functionChoose.reloadAllComponents()
            }
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
    
    func addVariableFunction(f: (Double) -> Double){
        var tmp = [Double]()
        observations.forEach { (obs) in
            tmp.append(f(obs.observationArray[choosenVariable]))
        }
        for i in 0..<observations.count{
            observations[i].observationArray.append(tmp[i])
        }
        headers.append(choosenFunction+(headers[choosenVariable]))
    }
    
    func addVariableFunction(f: (Double,Double) -> Double, n: Double){
        var tmp = [Double]()
        observations.forEach { (obs) in
            tmp.append(f(obs.observationArray[choosenVariable],n))
        }
        for i in 0..<observations.count{
            observations[i].observationArray.append(tmp[i])
        }
        headers.append(choosenFunction+(headers[choosenVariable]))
    }
    
    func addVariableFunction(newValues : [Double]){
        for i in 0..<observations.count{
            observations[i].observationArray.append(newValues[i])
        }
        headers.append(choosenFunction)
    }
    
}

protocol BackUpdatedObservations {
    func updatedObservations(observations: [Observation], headers: [String])
}
extension BackUpdatedObservations where Self : ViewController{
    func updatedObservations(observations: [Observation], headers: [String]){
        model.allObservations = observations
        model.headers = headers
        topTableView.reloadData()
        chooseXTableView.reloadData()
        chooseYTableView.reloadData()
        topLabel.reloadInputViews()
    }
}

//MARK: Edit Observations Controll


extension ObservationsSpreedsheetView{
    
    
    
}


//MARK: Cells

class TextCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
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
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .gray
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
