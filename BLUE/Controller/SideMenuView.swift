//
//  SideMenuView.swift
//  BLUE
//
//  Created by Karol Struniawski on 22/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit
import Darwin
import Surge

class SideMenuView: UITableViewController{
    
    var model = Model()
    let sections = ["Observations", "Plots", "Data Analysis"]
    let options =
    [
        "Observations": ["All","Selected","Add Variable"],
        "Plots": ["X-Y plot","Candle Chart","Rests Chart"],
        "Data Analysis": ["Correlations", "Data info"]
    ]
    var allObservations = true
    var sendBackSpreedVCDelegate : SendBackSpreedSheetView?
    var isGoToAddVariable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[sections[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        cell.textLabel?.text = options[sections[indexPath.section]]![indexPath.row]
        
        if options[sections[indexPath.section]]![indexPath.row] == "X-Y plot" && model.chosenXHeader.count > 1{
            cell.textLabel?.textColor = UIColor.red
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let num = Int("\(indexPath.section)\(indexPath.row)")
        switch num {
            //All observations
        case 00:
            performSegue(withIdentifier: "toObservations", sender: self)
            //Selected observations
        case 01:
            self.allObservations = false
            performSegue(withIdentifier: "toObservations", sender: self)
            //
        case 02:
            isGoToAddVariable = true
            performSegue(withIdentifier: "toObservations", sender: self)
        case 10:
            performSegue(withIdentifier: "toCharts", sender: self)
        case 11:
            performSegue(withIdentifier: "toCandleChart", sender: self)
        case 12:
            performSegue(withIdentifier: "toRestsChart", sender: self)
        default: break
        }
    }

    func makeCorrelations() -> [[String]]{
        var tmp = [[String]]()
        for row in 0..<model.allObservations.count{
            for col in 0..<model.allObservations[0].observationArray.count{
                if col < row{
                    tmp[row][col] = ""
                }else if col == row{
                    tmp[row][col] = "1"
                }else{
                    var meanX : Double = 0
                    var meanY : Double = 0
                    var vectorX = [Double]()
                    var vectorY = [Double]()
                    model.allObservations.forEach { (i) in
                        vectorX.append(i.observationArray[row])
                        vectorY.append(i.observationArray[col])
                    }
                    meanX = mean(vectorX)
                    meanY = mean(vectorY)
                    var top : Double = 0
                    var bottomX : Double = 0
                    var bottomY : Double = 0
                    
                    for i in 0..<vectorX.count{
                        top = top + ((vectorX[i]-meanX)*(vectorY[i]-meanY))
                        bottomX = bottomX + (pow((vectorX[i]-meanX), 2.0))
                        bottomY = bottomY + (pow((vectorY[i]-meanY), 2.0))
                    }
                    let bottom = sqrt(bottomX)*sqrt(bottomY)
                    let result = top/bottom
                    tmp[row][col] = String(result)
                }
            }
        }
        return tmp
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCharts"{
            let target = segue.destination as! ChartView
            target.scatterY = model.flatY
            target.scatterX = model.chosenX
            target.equation = model.getOLSRegressionEquation()
        }
        else if segue.identifier == "toObservations"{
            let target = segue.destination as! ObservationsSpreedsheetView
            sendBackSpreedVCDelegate?.send(view: target)
            if allObservations{
                target.observations = model.allObservations
            }else{
                var tmp = [Observation]()
                model.allObservations.forEach { (obs) in
                    var tab = [Double]()
                    for i in 0..<model.chosenXHeader.count{
                        for j in 0..<model.headers.count{
                            if model.chosenXHeader[i] == model.headers[j]{
                                tab.append(obs.observationArray[j])
                            }
                        }
                    }
                    var tmpObs = Observation()
                    tmpObs.label = obs.label
                    tmpObs.observationArray = tab
                    tmp.append(tmpObs)
                }
                target.observations = tmp
            }
            target.headers = model.headers
            target.observationsLabeled = model.observationLabeled
            if isGoToAddVariable{
                target.isAddVariableOpenedOnStart = true
            }
        }
        else if segue.identifier == "toCandleChart"{
            let target = segue.destination as! CandleChartViewController
            target.headers = model.headers
            target.observations = model.allObservations
        }
        else if segue.identifier == "toRestsChart"{
            let target = segue.destination as! restsChartsViewController
            target.e = model.S
            target.labels = model.labels
        }
    }
}

protocol SendBackSpreedSheetView{
    func send(view : ObservationsSpreedsheetView)
}
extension SendBackSpreedSheetView where Self : ViewController {
    func send(view : ObservationsSpreedsheetView){
        view.backUpdateObservationsDelegate = self
    }
}
