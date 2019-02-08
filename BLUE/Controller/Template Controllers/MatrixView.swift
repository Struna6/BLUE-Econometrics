//
//  MatrixView.swift
//  BLUE
//
//  Created by Karol Struniawski on 02/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit
import SpreadsheetView

class MatrixView: UIViewController {

    @IBOutlet weak var topLabel: UILabel?
    @IBOutlet weak var spreadSheetView: SpreadsheetView!
    
    var textTopLabel = String()
    var data = [[String]]()
    var headers = [String]()
    var selectObjectForSP = LongTappableToSaveContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spreadSheetView.delegate = self
        spreadSheetView.dataSource = self
        spreadSheetView.register(TextCell.self, forCellWithReuseIdentifier: "TextCell")
        spreadSheetView.register(HeaderCell.self, forCellWithReuseIdentifier: "HeaderCell")
        topLabel?.text = textTopLabel
        
        let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualViewToBlur.frame = self.view.frame
        visualViewToBlur.isHidden = true
        self.navigationController!.view.addSubview(visualViewToBlur)
        
        selectObjectForSP = LongTappableToSaveContext(newObject: self.spreadSheetView, toBlur: visualViewToBlur, targetViewController: self)
        
        let longTapOnLabel = UILongPressGestureRecognizer(target: selectObjectForSP, action: #selector(selectObjectForSP.longTapOnObject(sender:)))
        spreadSheetView.addGestureRecognizer(longTapOnLabel)
    }
}

extension MatrixView : SpreadsheetViewDelegate{
}

extension MatrixView : SpreadsheetViewDataSource{
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let sample = CGFloat(spreadSheetView.frame.height) / CGFloat(data.count) - 5
        if sample < CGFloat(spreadSheetView.frame.height) / 10{
            return CGFloat(spreadSheetView.frame.height) / 10
        }
        return sample
       // return 60
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        let sample = CGFloat(spreadSheetView.frame.width) / CGFloat(data[0].count) - 5
        if sample < CGFloat(spreadSheetView.frame.width) / 10{
            return CGFloat(spreadSheetView.frame.width) / 10
        }
        return sample
       // return 60
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 7
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 7
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 && indexPath.column == 0{
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            cell.label.text = ""
            return cell
        }else{
            if indexPath.row == 0{
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
                cell.label.text = headers[indexPath.column-1]
                return cell
            }else if indexPath.column == 0{
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
                cell.label.text = headers[indexPath.row-1]
                return cell
            }
            else{
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
                cell.label.text = data[indexPath.row][indexPath.column]
                return cell
            }
        }
    }
}
