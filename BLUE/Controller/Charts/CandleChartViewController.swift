//
//  CandleChartViewController.swift
//  BLUE
//
//  Created by Karol Struniawski on 23/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit
import Charts
import Surge

class CandleChartViewController: UIViewController,QuantileCalculable {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var chartView: CandleStickChartView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var observations = [Observation]()
    var chosenVariable = 0{
        didSet{
            drawChart()
        }
    }
    var headers = [String]()
    
    var selectObjectForChart = LongTappableToSaveContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chosenVariable = 0
        pickerView.showHint(text: "Choose variable")
        
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
    
    func drawChart(){
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        var numbers = [Double]()
        observations.forEach { (obs) in
            numbers.append(obs.observationArray[chosenVariable])
        }
        chartView.xAxis.axisMinimum = 0.0
        chartView.xAxis.axisMaximum = 2.0
        chartView.rightAxis.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        
        //let me = quantile(n: 0.5, numbers)
        let high = quantile(n: 0.75, numbers)
        let low = quantile(n: 0.25, numbers)
        let topEnd = high + (1.5*(high-low))
        let bottomEnd = low - (1.5*(high-low))
        let maxValue = [max(numbers),topEnd]
        let minValue = [min(numbers),bottomEnd]
        chartView.leftAxis.axisMaximum = max(maxValue) + abs(0.1*max(minValue))
        chartView.leftAxis.axisMinimum = min(minValue) - abs(0.1*min(minValue))
        let dataEntry = CandleChartDataEntry(x: 1, shadowH: topEnd, shadowL: bottomEnd, open: high, close: low)
        let dataEntriesSet = CandleChartDataSet(values: [dataEntry], label: headers[chosenVariable])
        
        dataEntriesSet.axisDependency = .left
        dataEntriesSet.colors = [UIColor.blue]
        dataEntriesSet.shadowColor = .darkGray
        dataEntriesSet.shadowWidth = 3.0
        dataEntriesSet.drawValuesEnabled = true
        
        let data = CandleChartData(dataSet: dataEntriesSet)
        chartView.data = data
        chartView.notifyDataSetChanged()
        //chartView.leftAxis.addLimitLine(ChartLimitLine(limit: me, label: "Q2"))
        chartView.leftAxis.removeAllLimitLines()
        chartView.leftAxis.addLimitLine(ChartLimitLine(limit: topEnd))
        chartView.leftAxis.addLimitLine(ChartLimitLine(limit: bottomEnd))
        chartView.leftAxis.addLimitLine(ChartLimitLine(limit: max(numbers), label: "Max Value"))
        chartView.leftAxis.addLimitLine(ChartLimitLine(limit: min(numbers), label: "Min Value"))
        
        chartView.leftAxis.limitLines[2].lineDashPhase = 1.0
        chartView.leftAxis.limitLines[2].lineDashLengths = [2.0,2.0]
        chartView.leftAxis.limitLines[3].lineDashPhase = 1.0
        chartView.leftAxis.limitLines[3].lineDashLengths = [2.0,2.0]
        chartView.leftAxis.limitLines[2].labelPosition = .rightBottom
        chartView.leftAxis.limitLines[3].labelPosition = .rightTop
        
        chartView.leftAxis.limitLines[0].lineWidth = 3.0
        chartView.leftAxis.limitLines[1].lineWidth = 3.0
        chartView.leftAxis.limitLines[0].lineColor = UIColor.black
        chartView.leftAxis.limitLines[1].lineColor = UIColor.black
        
        topLabel.text = "Candle chart of variable: " + headers[chosenVariable]
    }
}

extension CandleChartViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return headers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return headers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let num = headers[row]
        chosenVariable = headers.firstIndex(of: num)!
    }
}
