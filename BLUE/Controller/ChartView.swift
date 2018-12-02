//
//  ChartView.swift
//  BLUE
//
//  Created by Karol Struniawski on 25/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit
import Charts
import Surge

class ChartView: UIViewController{
    @IBOutlet weak var chartView: CombinedChartView!
    
    //do more for options like dictionary with X,Y arrays
    //line
    var X = [Double]()
    var Y = [Double]()
    //scatter
    var estimatedX = [Double]()
    var estimatedY = [Double]()
    @IBOutlet weak var chartTypePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        combinedLinAndScateerUpdate()
        
    }
    func combinedLinAndScateerUpdate(){
        var lineEntries = [ChartDataEntry]()
        //make selector of X to choose
        for i in 0..<estimatedY.count{
            let tmp = ChartDataEntry(x: estimatedX[i], y: estimatedY[i])
            lineEntries.append(tmp)
        }
        let lineDataSet = LineChartDataSet(values: lineEntries, label: "Estimated Values")
        let lineData = LineChartData(dataSet: lineDataSet)
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.drawValuesEnabled = false
        lineDataSet.lineWidth = 2.5
        lineDataSet.setColor(NSUIColor.init(red: 1, green: 0, blue: 0, alpha: 1))
        
        var scatterEntries = [ChartDataEntry]()
        for i in 0..<Y.count{
            let tmp = ChartDataEntry(x: X[i], y: Y[i])
            scatterEntries.append(tmp)
        }
        let scatterDataSet = ScatterChartDataSet(values: scatterEntries, label: "True Values")
        let scatterData = ScatterChartData(dataSet: scatterDataSet)
        scatterDataSet.setScatterShape(.circle)
        scatterDataSet.setColor(NSUIColor.init(red: 0, green: 0, blue: 1, alpha: 1))
        scatterDataSet.scatterShapeSize = 8
        scatterDataSet.drawValuesEnabled = false
        
        let combinedData = CombinedChartData()
        combinedData.lineData = lineData
        combinedData.scatterData = scatterData
        
        chartView.data = combinedData
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView.notifyDataSetChanged()
    }

}

extension ChartView : UIPickerViewDelegate{
    
}

extension ChartView : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
}
