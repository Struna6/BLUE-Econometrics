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
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        return CGFloat(spreedsheet.frame.height) / CGFloat(row + 1) - 5
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return CGFloat(spreedsheet.frame.width) / CGFloat(col) - 5
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return col
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
        if indexPath.row == 0 {
            let cell = spreedsheet.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            cell.label.text = String(headers[indexPath.column])
            return cell
        }
        else{
            let cell = spreedsheet.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
            cell.label.text = String(observations[indexPath.row-1].observationArray[indexPath.column])
            return cell
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
    }
    
    
    @IBOutlet weak var spreedsheet: SpreadsheetView!
    override func viewDidLoad() {
        super.viewDidLoad()
        spreedsheet.register(TextCell.self, forCellWithReuseIdentifier: "TextCell")
        spreedsheet.register(HeaderCell.self, forCellWithReuseIdentifier: "HeaderCell")
        spreedsheet.delegate = self
        spreedsheet.dataSource = self
    }
}

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
