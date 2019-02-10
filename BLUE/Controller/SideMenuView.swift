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

class SideMenuView: UITableViewController, PlayableLoadingScreen{
    
    var model = Model()
    let sections = ["Observations", "Plots", "Data Analysis"]
    let options =
    [
        "Observations": ["All","Selected","Add Variable", "Normalisation"],
        "Plots": ["X-Y plot","Candle Chart","Rests Chart"],
        "Data Analysis": ["Correlations", "Data info"]
    ]
    var allObservations = true
    var sendBackSpreedVCDelegate : SendBackSpreedSheetView?
    var isGoToAddVariable = false
    var isGoToNormalize = false
    
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
    
    var readytoTableViewSorted = false
    
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
        case 03:
            isGoToNormalize = true
            performSegue(withIdentifier: "toObservations", sender: self)
        case 10:
            performSegue(withIdentifier: "toCharts", sender: self)
        case 11:
            performSegue(withIdentifier: "toCandleChart", sender: self)
        case 12:
            performSegue(withIdentifier: "toRestsChart", sender: self)
        case 20:
            performSegue(withIdentifier: "toMatrixView", sender: self)
        case 21:
            performSegue(withIdentifier: "toTableViewSorted", sender: self)
        default: break
        }
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
            target.model = model
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
            if isGoToNormalize{
                target.isNormalizeOpenedOnStart = true
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
        else if segue.identifier == "toMatrixView"{
            let target = segue.destination as! MatrixView
            target.data = model.makeCorrelationsArray2D()
            target.headers = model.headers
            target.textTopLabel = "Variables Correlations"
        }
            //Have to pass topLabelName, mainModelParameter?, shortParameters and picker with All and headers
        else if segue.identifier == "toTableViewSorted"{
            let target = segue.destination as! TableViewControllerSorted
            target.textTopLabel = "Core Data Info"
            target.pickerSections = model.headers
            target.pickerSections.insert("All", at: 0)
            
            readytoTableViewSorted = false
            
            playLoadingAsync(tasksToDoAsync: {
                let avarage = self.model.avarage
                let se = self.model.SeCore
                let v = self.model.Ve
                let Var = self.model.Var
                let Me = self.model.Me
                let Q1 = self.model.Q1
                let Q3 = self.model.Q3
                let Qdiff = self.model.Qdifference
                let kurtosis = self.model.kurtosis
                let skewness = self.model.skewness
                let range = self.model.range
                
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Avarage for: \(self.model.headers[i])", value: avarage[i], description: "The arithmetic mean is the most commonly used and readily understood measure of central tendency in a data set. In statistics, the term average refers to any of the measures of central tendency. The arithmetic mean of a set of observed data is defined as being equal to the sum of the numerical values of each and every observation divided by the total number of observations.", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Standard deviation for: \(self.model.headers[i])", value: se[i], description: "In statistics, the standard deviation (SD, also represented by the lower case Greek letter sigma σ or the Latin letter s) is a measure that is used to quantify the amount of variation or dispersion of a set of data values. A low standard deviation indicates that the data points tend to be close to the mean (also called the expected value) of the set, while a high standard deviation indicates that the data points are spread out over a wider range of values.", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Coefficient of variation for: \(self.model.headers[i])", isLess: false, criticalFloor: 0.1, warningFloor: 0.05, value: v[i], description: "In probability theory and statistics, the coefficient of variation (CV), also known as relative standard deviation (RSD), is a standardized measure of dispersion of a probability distribution or frequency distribution. It is often expressed as a percentage, and is defined as the ratio of the standard deviation to mean", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Variance for: \(self.model.headers[i])", value: Var[i], description: "In probability theory and statistics, variance is the expectation of the squared deviation of a random variable from its mean. Informally, it measures how far a set of (random) numbers are spread out from their average value. Variance has a central role in statistics, where some ideas that use it include descriptive statistics, statistical inference, hypothesis testing, goodness of fit, and Monte Carlo sampling. Variance is an important tool in the sciences, where statistical analysis of data is common. The variance is the square of the standard deviation, the second central moment of a distribution, and the covariance of the random variable with itself.", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Median for: \(self.model.headers[i])", value: Me[i], description: "The median is the value separating the higher half from the lower half of a data sample (a population or a probability distribution). For a data set, it may be thought of as the middle value. For example, in the data set {1, 3, 3, 6, 7, 8, 9}, the median is 6, the fourth largest, and also the fourth smallest, number in the sample. For a continuous probability distribution, the median is the value such that a number is equally likely to fall above or below it. The median is a commonly used measure of the properties of a data set in statistics and probability theory. The basic advantage of the median in describing data compared to the mean (often simply described as the average) is that it is not skewed so much by extremely large or small values, and so it may give a better idea of a typical value. For example, in understanding statistics like household income or assets which vary greatly, a mean may be skewed by a small number of extremely high or low values. Median income, for example, may be a better way to suggest what a typical income is.", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "First Quartile for: \(self.model.headers[i])", value: Q1[i], description: "A quartile is a type of quantile. The first quartile (Q1) is defined as the middle number between the smallest number and the median of the data set. The second quartile (Q2) is the median of the data. The third quartile (Q3) is the middle value between the median and the highest value of the data set.In applications of statistics such as epidemiology, sociology and finance, the quartiles of a ranked set of data values are the four subsets whose boundaries are the three quartile points. Thus an individual item might be described as being \"on the upper quartile\".", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Third Quartile for: \(self.model.headers[i])", value: Q3[i], description: "A quartile is a type of quantile. The first quartile (Q1) is defined as the middle number between the smallest number and the median of the data set. The second quartile (Q2) is the median of the data. The third quartile (Q3) is the middle value between the median and the highest value of the data set.In applications of statistics such as epidemiology, sociology and finance, the quartiles of a ranked set of data values are the four subsets whose boundaries are the three quartile points. Thus an individual item might be described as being \"on the upper quartile\".", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Quartile deviation for: \(self.model.headers[i])", value: Qdiff[i], description: "The Quartile Deviation is a simple way to estimate the spread of a distribution about a measure of its central tendency (usually the mean). So, it gives you an idea about the range within which the central 50% of your sample data lies. Consequently, based on the quartile deviation, the Coefficient of Quartile Deviation can be defined, which makes it easy to compare the spread of two or more different distributions.", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Kurtosis for: \(self.model.headers[i])", value: kurtosis[i], description: "The kurtosis of any univariate normal distribution is 3. It is common to compare the kurtosis of a distribution to this value. Distributions with kurtosis less than 3 are said to be platykurtic, although this does not imply the distribution is \"flat-topped\" as sometimes reported. Rather, it means the distribution produces fewer and less extreme outliers than does the normal distribution. An example of a platykurtic distribution is the uniform distribution, which does not produce outliers. Distributions with kurtosis greater than 3 are said to be leptokurtic. An example of a leptokurtic distribution is the Laplace distribution, which has tails that asymptotically approach zero more slowly than a Gaussian, and therefore produces more outliers than the normal distribution.", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Skewness for: \(self.model.headers[i])", isLess: false, value: skewness[i], description: "In probability theory and statistics, skewness is a measure of the asymmetry of the probability distribution of a real-valued random variable about its mean. The skewness value can be positive or negative, or undefined.For a unimodal distribution, negative skew commonly indicates that the tail is on the left side of the distribution, and positive skew indicates that the tail is on the right. In cases where one tail is long but the other tail is fat, skewness does not obey a simple rule. For example, a zero value means that the tails on both sides of the mean balance out overall; this is the case for a symmetric distribution, but can also be true for an asymmetric distribution where one tail is long and thin, and the other is short but fat.", imageName: "me_avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Range for: \(self.model.headers[i])", value: range[i], description: "In statistics, the range of a set of data is the difference between the largest and smallest values.However, in descriptive statistics, this concept of range has a more complex meaning. The range is the size of the smallest interval (statistics) which contains all the data and provides an indication of statistical dispersion. It is measured in the same units as the data. Since it only depends on two of the observations, it is most useful in representing the dispersion of small data sets", imageName: "me_avg", variable: self.model.headers[i]))
                }
            }, tasksToMainBack: {
                self.readytoTableViewSorted = true
                target.tableView.reloadData()
            }, mainView: self.view)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toTableViewSorted"{
            return readytoTableViewSorted
        }else{
            return true
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
