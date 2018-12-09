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
    // MARK: Scatter
    var scatterX : [[Double]]?
    var scatterY : [Double]?
    // MARK: Line
    private var lineX = [Double]()
    private var lineY : [Double]?
    // MARK: To be set too
    var equation = [Double]()
    
    private var chosenX = 0
    private var max : Int {
        get{
            var Xcol = [Double]()
            for i in 0..<scatterX!.count{
                Xcol.append(scatterX![i][chosenX+1])
            }
            return Int(Surge.max(Xcol))
        }
    }
    private var min : Int {
        get{
            var Xcol = [Double]()
            for i in 0..<scatterX!.count{
                Xcol.append(scatterX![i][chosenX+1])
            }
            return Int(Surge.min(Xcol))
        }
    }
    
    private var chartOptions = [String](repeating: "option", count: 5)
    @IBOutlet weak var chartTypePicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartTypePicker.delegate = self
        chartTypePicker.dataSource = self
        lineX.removeAll()
        combinedLinAndScateerUpdate()
    }
    
    private func createLineValues(){
        for i in Int(min-2)...Int(max+2){
            lineX.append(Double(i))
        }
        var returnTmp = [Double]()
        var tmpX = [[Double]]()
        lineX.forEach { (el) in
            var tmp = [Double]()
            tmp.append(1.0)
            tmp.append(el)
            tmpX.append(tmp)
        }
        let X = Matrix<Double>(tmpX)
        let Y = Matrix<Double>([equation])
        let result = mul(X, y: Surge.transpose(Y))
        result.forEach({ (slice) in
            returnTmp.append(Array(slice)[0])
        })
        lineY = returnTmp
    }
    
    private func combinedLinAndScateerUpdate(){
        createLineValues()
        var lineEntries = [ChartDataEntry]()
        for i in 0..<lineX.count{
            let tmp = ChartDataEntry(x: lineX[i], y: lineY![i])
            lineEntries.append(tmp)
        }
        let lineDataSet = LineChartDataSet(values: lineEntries, label: "Estimated Values")
        let lineData = LineChartData(dataSet: lineDataSet)
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.drawValuesEnabled = false
        lineDataSet.lineWidth = 2.5
        lineDataSet.setColor(NSUIColor.init(red: 1, green: 0, blue: 0, alpha: 1))
        
        var scatterEntries = [ChartDataEntry]()
        for i in 0..<scatterY!.count{
            let tmp = ChartDataEntry(x: scatterX![i][chosenX+1], y: scatterY![i])
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
        chartView.xAxis.axisMinimum = Double(min) - 2.0
        chartView.xAxis.axisMaximum = Double(max) + 2.0
        chartView.notifyDataSetChanged()
    }

}

extension ChartView : UIPickerViewDelegate, UIPickerViewDataSource{
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return chartOptions[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return chartOptions.count
    }
}
