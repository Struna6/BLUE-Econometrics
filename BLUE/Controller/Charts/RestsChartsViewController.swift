//
//  restsChartsViewController.swift
//  BLUE
//
//  Created by Karol Struniawski on 24/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit
import Charts
import Surge

class restsChartsViewController: UIViewController{

    @IBOutlet weak var viewBarChart: BarChartView!
    var e = [Double]()
    var labels : [String]?
    var selectObjectForChart = LongTappableToSaveContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBarChart.xAxis.axisMinimum = -1.0
        viewBarChart.xAxis.axisMaximum = Double(e.count) + 1.0
        viewBarChart.rightAxis.enabled = false
        viewBarChart.xAxis.drawGridLinesEnabled = false
        viewBarChart.xAxis.drawAxisLineEnabled = false
        
        var barChartEntries = [BarChartDataEntry]()
        for i in 0..<e.count{
            barChartEntries.append(BarChartDataEntry(x: Double(0+i), y: e[i]))
        }
        let barChartDataSet = BarChartDataSet(values: barChartEntries, label: nil)
        
        barChartDataSet.axisDependency = .left
        barChartDataSet.colors = [UIColor.blue]
        
        let data = BarChartData(dataSet: barChartDataSet)
        viewBarChart.data = data
        viewBarChart.notifyDataSetChanged()
        
        let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualViewToBlur.frame = self.view.frame
        visualViewToBlur.isHidden = true
        self.navigationController!.view.addSubview(visualViewToBlur)
        
        selectObjectForChart = LongTappableToSaveContext(newObject: self.viewBarChart.superview!, toBlur: visualViewToBlur, targetViewController: self)
        
        let longTapOnChart = UILongPressGestureRecognizer(target: selectObjectForChart, action: #selector(selectObjectForChart.longTapOnObject(sender:)))
        viewBarChart.addGestureRecognizer(longTapOnChart)
        
        viewBarChart.pinchZoomEnabled = true
        viewBarChart.doubleTapToZoomEnabled = true
        viewBarChart.scaleXEnabled = true
        viewBarChart.scaleYEnabled = true
    }
}
