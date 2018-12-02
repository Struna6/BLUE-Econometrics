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

protocol Transposable{
    func transpose(array : [[Double]], rows : Int, cols : Int) -> [[Double]]
}
extension Transposable where Self:ViewController{
    func transpose(array : [[Double]], rows : Int, cols : Int) -> [[Double]]{
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

class ViewController: UIViewController, Transposable{
    var model = Model(withHeaders: false, observationLabeled: false, path: "")
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var visualViewToBlur: UIVisualEffectView!
    @IBOutlet var chooseXYView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chooseYTableView: UITableView!
    @IBOutlet weak var chooseXTableView: UITableView!
    @IBOutlet weak var textLabel: UILabel!
    var chosenY = String()
    var chosenX = [String]()
    var newPath = ""{
        didSet{
//            k = KMNK(withHeaders: false, observationLabeled: false, path: newPath)
            textLabel.textAlignment = .center
            textLabel.text = "Statictical parameters to be calculated"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.textAlignment = .center
        textLabel.text = "Statictical parameters to be calculated"
        tableView.delegate = self
        tableView.dataSource = self
        chooseXTableView.delegate = self
        chooseXTableView.dataSource = self
        chooseYTableView.delegate = self
        chooseYTableView.dataSource = self
        chooseXYView.layer.cornerRadius = 10
        visualViewToBlur.effect = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChart"{
        }
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        documentPicker.delegate = self
       present(documentPicker, animated: true, completion:  nil)
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton){
        textLabel.text = ("n: \(model.n)\nk :\(model.k)\nEquation: \(model.getOLSRegressionEquation())\nSSR: \(model.SSR)\nSe: \(model.se)\nR^2: \(model.squareR)\nFi^2: \(model.squereFi)")
    }
    
    private func reloadModel(){
    }
    
    @IBAction func choosingXYDone(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.chooseXYView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.chooseXYView.alpha = 0
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
            model.chosenX = transpose(array: tmpX, rows: i+1, cols: self.model.n)
        }
    }
    @IBAction func chooseXYButtonPressed(_ sender: UIBarButtonItem) {
        self.view.addSubview(chooseXYView)
        chooseXYView.alpha = 0
        chooseXYView.center = self.view.center
        chooseXYView.transform = CGAffineTransform(translationX: 0.0, y: 300)
        UIView.animate(withDuration: 0.4) {
            self.visualViewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.chooseXYView.alpha = 1
            self.chooseXYView.transform = CGAffineTransform.identity
        }
    }
}


extension ViewController : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var filePath = urls[0].absoluteString
        let start = filePath.index(filePath.startIndex, offsetBy: 7)
        filePath = String(filePath[start..<filePath.endIndex])
        self.newPath = filePath
        //ADD ALERT YES?NO
    }
}

extension ViewController :  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView{
            return model.allObservations[0].observationArray.count
        }
        else{
            return model.headers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
            var text = ""
            model.allObservations.forEach { (observation) in
                text = text + String(observation.observationArray[indexPath.row]) + "  "
            }
            text = model.headers[indexPath.row] + "   " + text
            cell.textLabel?.text = text
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
            let text = model.headers[indexPath.row]
            cell.textLabel?.text = text
            cell.textLabel?.textAlignment = NSTextAlignment.center
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView != self.tableView {
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
                    chosenX.remove(at: chosenX.firstIndex(of: text)!)
                }else{
                    chosenX.append(text)
                }
            }
        }        
    }
    

}
