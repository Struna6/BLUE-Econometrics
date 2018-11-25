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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var k  = KMNK(withHeaders: false,observationLabeled: false,path: Bundle.main.path(forResource: "test1", ofType: "txt")!)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textLabel: UILabel!
    var newPath = ""{
        didSet{
            k = KMNK(withHeaders: false, observationLabeled: false, path: newPath)
            textLabel.textAlignment = .center
            textLabel.text = "Statictical parameters to be calculated"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return k.observations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        var text = ""
        k.observations[indexPath.row].observationArray.forEach { (element) in
            text +=  String(element) + "   "
        }
        cell.textLabel?.text = text
        return cell
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.textAlignment = .center
        textLabel.text = "Statictical parameters to be calculated"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChart"{
            let tmp = segue.destination as! ChartView
            var X = [Double]()
            for i in Int(min(k.Ytmp) - 2) ..< Int(max(k.Ytmp) + 2){
                X.append(Double(i))
            }
            tmp.estimatedX = X
            tmp.estimatedY = KMNK.calculateYFromX(X: X, Y: k.equation)
            tmp.X = k.Xtmp
            tmp.Y = k.Ytmp
        }
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion:  nil)
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton){
        textLabel.text = ("Equation: \(k.equation)\nSSR: \(k.SSR)\nSe: \(k.se)\nR^2: \(k.squareR)\nFi^2: \(k.squereFi)")
    }
    
    private func reloadModel(){
        
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
