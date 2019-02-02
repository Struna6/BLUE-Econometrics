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

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var spreadSheetView: SpreadsheetView!
    
    var data = [[String]]()
    var headers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spreadSheetView.delegate = self
        spreadSheetView.dataSource = self
    }
}

extension MatrixView : SpreadsheetViewDelegate{
    
}

extension MatrixView : SpreadsheetViewDataSource{
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let sample = CGFloat(spreadSheetView.frame.height) / CGFloat(row + 1) - 5
        if sample < CGFloat(spreadSheetView.frame.height) / 30{
            return CGFloat(spreadSheetView.frame.height) / 30
        }
        return CGFloat(spreadSheetView.frame.height) / CGFloat(row + 1) - 5
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        let sample = CGFloat(spreadSheetView.frame.width) / CGFloat(column) - 5
        if sample < CGFloat(spreadSheetView.frame.width) / 4{
            return CGFloat(spreadSheetView.frame.width) / 4
        }
        return CGFloat(spreadSheetView.frame.width) / CGFloat(column) - 10
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return data[0].count + 1
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return data.count + 1
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 || indexPath.column == 0{
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! HeaderCell
            cell.label.text = headers[indexPath.row]
            return cell
        }else{
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            cell.label.text = data[indexPath.row][indexPath.column]
            return cell
        }
    }
}
