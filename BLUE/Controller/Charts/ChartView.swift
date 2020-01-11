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

//MARK: For Combined Chart

class ChartView: UIViewController{
    @IBOutlet weak var chartView: CombinedChartView!
    
    @IBOutlet weak var bottomLabel: UILabel!
    //MARK: Scatter
    var scatterX : [[Double]]?
    var scatterY : [Double]?
    //MARK: Line
    private var lineX = [Double]()
    private var lineY : [Double]?
    //MARK: To be set too
    var equation = [Double]()
    //MARK: For candleChart
    var observations = [Observation]()
    
    var selectObjectForChart = LongTappableToSaveContext()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        lineX.removeAll()
        combinedLinAndScateerUpdate()
        bottomLabel.text = "X:\nY:"
        
        let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualViewToBlur.frame = self.view.frame
        visualViewToBlur.isHidden = true
        self.navigationController!.view.addSubview(visualViewToBlur)
        
        selectObjectForChart = LongTappableToSaveContext(newObject: self.chartView.superview!, toBlur: visualViewToBlur, targetViewController: self)
        
        let longTapOnChart = UILongPressGestureRecognizer(target: selectObjectForChart, action: #selector(selectObjectForChart.longTapOnObject(sender:)))
        chartView.addGestureRecognizer(longTapOnChart)
        
        chartView.pinchZoomEnabled = true
        chartView.doubleTapToZoomEnabled = true
        chartView.scaleXEnabled = true
        chartView.scaleYEnabled = true
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
        print(tmpX)
        print(equation)
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
        let lineDataSet = LineChartDataSet(entries: lineEntries, label: "Estimated Values")
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
        let scatterDataSet = ScatterChartDataSet(entries: scatterEntries, label: "True Values")
        let scatterData = ScatterChartData(dataSet: scatterDataSet)
        scatterDataSet.setScatterShape(.circle)
        scatterDataSet.setColor(NSUIColor.init(red: 0, green: 0, blue: 1, alpha: 1))
        scatterDataSet.scatterShapeSize = 8
        scatterDataSet.drawValuesEnabled = false
        
        let combinedData = CombinedChartData()
        combinedData.lineData = lineData
        combinedData.scatterData = scatterData
        
        chartView.data = combinedData
        chartView.delegate = self
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView.xAxis.axisMinimum = Double(min) - 2.0
        chartView.xAxis.axisMaximum = Double(max) + 2.0
        chartView.notifyDataSetChanged()
    }
}

extension ChartView : ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        bottomLabel.text = "X: " + String(format: "%.3f", entry.x) + "\nY: " + String(format: "%.3f", entry.y)
    }
}
