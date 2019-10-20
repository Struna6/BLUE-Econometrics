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

class SideMenuView: UITableViewController, PlayableLoadingScreen, Storage, ErrorScreenPlayable{
    
    var model = Model()
    let sections = ["Observations", "Plots", "Data Analysis","Regression", "Comparing", "Other Models", "Settings"]
    let options =
    [
        "Observations": ["All","Selected","Add Variable", "Normalization", "Untypical"],
        "Plots": ["X-Y plot","Candle Chart","Rests Chart"],
        "Data Analysis": ["Correlations", "Data info"],
        "Regression": ["Parameters", "Testing"],
        "Comparing" : ["Compare Created Models"],
        "Other Models" : ["Instrumental Variables", "Logit", "Probit"],
        "Settings" : ["User Settings"]
    ]
    let notPremiumIndexes = ["12","20","30","60"]
    var allObservations = true
    var sendBackSpreedVCDelegate : SendBackSpreedSheetView?
    var isGoToAddVariable = false
    var isGoToNormalize = false
    var docPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open)
    var paths = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        docPicker.delegate = self
        docPicker.allowsMultipleSelection = true
        docPicker.modalPresentationStyle = .formSheet
        tableView.separatorColor = UIColor.clear
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
    
    let defaults = UserDefaults.standard
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        cell.textLabel?.text = options[sections[indexPath.section]]![indexPath.row]
        
        if options[sections[indexPath.section]]![indexPath.row] == "X-Y plot" && model.chosenXHeader.count > 1{
            cell.textLabel?.textColor = UIColor.red
            cell.isUserInteractionEnabled = false
        }
        
        if !defaults.bool(forKey: "premium"){
            let num = "\(indexPath.section)\(indexPath.row)"
            
            if !notPremiumIndexes.contains(num){
                cell.isUserInteractionEnabled = false
                cell.alpha = 0.8
                cell.imageView?.image = UIImage(named: "pro")
            }
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
        case 03:
            isGoToNormalize = true
            performSegue(withIdentifier: "toObservations", sender: self)
        case 04:
            performSegue(withIdentifier: "toUntypical", sender: self)
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
        case 30:
            performSegue(withIdentifier: "toParameters", sender: self)
        case 31:
            performSegue(withIdentifier: "toTesting", sender: self)
        case 40:
            present(docPicker, animated: true)
        case 50:
            performSegue(withIdentifier: "toOther", sender: self)
        case 51:
            performSegue(withIdentifier: "toLogit", sender: self)
        case 52:
            performSegue(withIdentifier: "toProbit", sender: self)
        case 60:
            performSegue(withIdentifier: "toSettings", sender: self)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let placeForRows = view.frame.height - (CGFloat(self.sections.count) * 40.0) - 80
        var numRows = 0
        for o in options{
            numRows += o.value.count
        }
        return placeForRows / CGFloat(numRows)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
                    target.parametersResults.append(ModelParameters(name: "Avarage for: \(self.model.headers[i])", value: avarage[i], description: "The arithmetic mean is the most commonly used and readily understood measure of central tendency in a data set. In statistics, the term average refers to any of the measures of central tendency. The arithmetic mean of a set of observed data is defined as being equal to the sum of the numerical values of each and every observation divided by the total number of observations.", imageName: "avg", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Standard deviation for: \(self.model.headers[i])", value: se[i], description: "In statistics, the standard deviation (SD, also represented by the lower case Greek letter sigma σ or the Latin letter s) is a measure that is used to quantify the amount of variation or dispersion of a set of data values. A low standard deviation indicates that the data points tend to be close to the mean (also called the expected value) of the set, while a high standard deviation indicates that the data points are spread out over a wider range of values.", imageName: "se", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Coefficient of variation for: \(self.model.headers[i])", isLess: false, criticalFloor: 0.1, warningFloor: 0.05, value: v[i], description: "In probability theory and statistics, the coefficient of variation (CV), also known as relative standard deviation (RSD), is a standardized measure of dispersion of a probability distribution or frequency distribution. It is often expressed as a percentage, and is defined as the ratio of the standard deviation to mean", imageName: "cov", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Variance for: \(self.model.headers[i])", value: Var[i], description: "In probability theory and statistics, variance is the expectation of the squared deviation of a random variable from its mean. Informally, it measures how far a set of (random) numbers are spread out from their average value. Variance has a central role in statistics, where some ideas that use it include descriptive statistics, statistical inference, hypothesis testing, goodness of fit, and Monte Carlo sampling. Variance is an important tool in the sciences, where statistical analysis of data is common. The variance is the square of the standard deviation, the second central moment of a distribution, and the covariance of the random variable with itself.", imageName: "var", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Median for: \(self.model.headers[i])", value: Me[i], description: "The median is the value separating the higher half from the lower half of a data sample (a population or a probability distribution). For a data set, it may be thought of as the middle value. For example, in the data set {1, 3, 3, 6, 7, 8, 9}, the median is 6, the fourth largest, and also the fourth smallest, number in the sample. For a continuous probability distribution, the median is the value such that a number is equally likely to fall above or below it. The median is a commonly used measure of the properties of a data set in statistics and probability theory. The basic advantage of the median in describing data compared to the mean (often simply described as the average) is that it is not skewed so much by extremely large or small values, and so it may give a better idea of a typical value. For example, in understanding statistics like household income or assets which vary greatly, a mean may be skewed by a small number of extremely high or low values. Median income, for example, may be a better way to suggest what a typical income is.", imageName: "me_q", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "First Quartile for: \(self.model.headers[i])", value: Q1[i], description: "A quartile is a type of quantile. The first quartile (Q1) is defined as the middle number between the smallest number and the median of the data set. The second quartile (Q2) is the median of the data. The third quartile (Q3) is the middle value between the median and the highest value of the data set.In applications of statistics such as epidemiology, sociology and finance, the quartiles of a ranked set of data values are the four subsets whose boundaries are the three quartile points. Thus an individual item might be described as being \"on the upper quartile\".", imageName: "me_q", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Third Quartile for: \(self.model.headers[i])", value: Q3[i], description: "A quartile is a type of quantile. The first quartile (Q1) is defined as the middle number between the smallest number and the median of the data set. The second quartile (Q2) is the median of the data. The third quartile (Q3) is the middle value between the median and the highest value of the data set.In applications of statistics such as epidemiology, sociology and finance, the quartiles of a ranked set of data values are the four subsets whose boundaries are the three quartile points. Thus an individual item might be described as being \"on the upper quartile\".", imageName: "me_q", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Quartile deviation for: \(self.model.headers[i])", value: Qdiff[i], description: "The Quartile Deviation is a simple way to estimate the spread of a distribution about a measure of its central tendency (usually the mean). So, it gives you an idea about the range within which the central 50% of your sample data lies. Consequently, based on the quartile deviation, the Coefficient of Quartile Deviation can be defined, which makes it easy to compare the spread of two or more different distributions.", imageName: "q_dev", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Kurtosis for: \(self.model.headers[i])", value: kurtosis[i], description: "The kurtosis of any univariate normal distribution is 3. It is common to compare the kurtosis of a distribution to this value. Distributions with kurtosis less than 3 are said to be platykurtic, although this does not imply the distribution is \"flat-topped\" as sometimes reported. Rather, it means the distribution produces fewer and less extreme outliers than does the normal distribution. An example of a platykurtic distribution is the uniform distribution, which does not produce outliers. Distributions with kurtosis greater than 3 are said to be leptokurtic. An example of a leptokurtic distribution is the Laplace distribution, which has tails that asymptotically approach zero more slowly than a Gaussian, and therefore produces more outliers than the normal distribution.", imageName: "skew_kurth", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Skewness for: \(self.model.headers[i])", isLess: false, value: skewness[i], description: "In probability theory and statistics, skewness is a measure of the asymmetry of the probability distribution of a real-valued random variable about its mean. The skewness value can be positive or negative, or undefined.For a unimodal distribution, negative skew commonly indicates that the tail is on the left side of the distribution, and positive skew indicates that the tail is on the right. In cases where one tail is long but the other tail is fat, skewness does not obey a simple rule. For example, a zero value means that the tails on both sides of the mean balance out overall; this is the case for a symmetric distribution, but can also be true for an asymmetric distribution where one tail is long and thin, and the other is short but fat.", imageName: "skew_kurth", variable: self.model.headers[i]))
                }
                for i in 0..<self.model.headers.count{
                    target.parametersResults.append(ModelParameters(name: "Range for: \(self.model.headers[i])", value: range[i], description: "In statistics, the range of a set of data is the difference between the largest and smallest values.However, in descriptive statistics, this concept of range has a more complex meaning. The range is the size of the smallest interval (statistics) which contains all the data and provides an indication of statistical dispersion. It is measured in the same units as the data. Since it only depends on two of the observations, it is most useful in representing the dispersion of small data sets", imageName: "range", variable: self.model.headers[i]))
                }
            }, tasksToMainBack: {
                target.tableView.reloadData()
            }, mainView: target.self.view)
        }
        else if segue.identifier == "toTesting"{
            let target = segue.destination as! TableViewControllerSorted
            target.textTopLabel = "Model Testing"
            target.pickerSections = model.headers
            target.pickerSections.insert("All", at: 0)
            
            playLoadingAsync(tasksToDoAsync: {
                let testsAdvanced = OLSTestsAdvanced(baseModel: self.model)
                target.parametersResults = [ModelParameters(name: "R\u{00B2}", isLess: true, criticalFloor: 0.5, warningFloor: 0.75, value: self.model.squareR, description: "The better the linear regression (on the right) fits the data in comparison to the simple average (on the left graph), the closer the value of R\u{00B2} is to 1. The areas of the blue squares represent the squared residuals with respect to the linear regression. The areas of the red squares represent the squared residuals with respect to the average value.", imageName: "R", videoName: "squareR")
                    ,ModelParameters(name: "Test F significance", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: self.model.parametersF, description: "The F value in regression is the result of a test where the null hypothesis is that all of the regression coefficients are equal to zero. In other words, the model has no predictive capability. Basically, the f-test compares your model with zero predictor variables (the intercept only model), and decides whether your added coefficients improved the model. If you get a significant result, then whatever coefficients you included in your model improved the model’s fit.", imageName: "F", videoName: "fTest")
                    ,ModelParameters(name: "RESET test of stability of model", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: testsAdvanced.RESET(), description: "In statistics, the Ramsey Regression Equation Specification Error Test (RESET) test is a general specification test for the linear regression model. More specifically, it tests whether non-linear combinations of the fitted values help explain the response variable. The intuition behind the test is that if non-linear combinations of the explanatory variables have any power in explaining the response variable, the model is misspecified in the sense that the data generating process might be better approximated by a polynomial or another non-linear functional form.", imageName: "F", videoName: "RESET")
                    ,ModelParameters(name: "Jarque-Berry test of normality", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: self.model.JBtest, description: "The Jarque-Bera Test,a type of Lagrange multiplier test, is a test for normality. Normality is one of the assumptions for many statistical tests, like the t test or F test; the Jarque-Bera test is usually run before one of these tests to confirm normality. ", imageName: "CHI", videoName: "JBtest")
                    ,ModelParameters(name: "Lagrange test of autocorrelation", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: testsAdvanced.LMAutoCorrelation(), description: "Autocorrelation, also known as serial correlation, is the correlation of a signal with a delayed copy of itself as a function of delay. Informally, it is the similarity between observations as a function of the time lag between them. The analysis of autocorrelation is a mathematical tool for finding repeating patterns, such as the presence of a periodic signal obscured by noise, or identifying the missing fundamental frequency in a signal implied by its harmonic frequencies. It is often used in signal processing for analyzing functions or series of values, such as time domain signals.", imageName: "CHI", videoName: "LMtest"),
                     ModelParameters(name: "White test of homoskedasticity", isLess: true, criticalFloor: 0.05, warningFloor: 0.1, value: testsAdvanced.WhiteHomo(), description: "In statistics, the White test is a statistical test that establishes whether the variance of the errors in a regression model is constant: that is for homoskedasticity.These methods have become extremely widely used, making this paper one of the most cited articles in economics.[2]In cases where the White test statistic is statistically significant, heteroskedasticity may not necessarily be the cause; instead the problem could be a specification error. In other words, the White test can be a test of heteroskedasticity or specification error or both. If no cross product terms are introduced in the White test procedure, then this is a test of pure heteroskedasticity. If cross products are introduced in the model, then it is a test of both heteroskedasticity and specification bias.", imageName: "CHI", videoName: "WhiteHomo")
                ]
                let tResults = self.model.parametersT
                target.parametersResults.append(ModelParameters(name: "Test t for free variable", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: tResults[0], description: "A statistically significant t-test result is one in which a difference between two groups is unlikely to have occurred because the sample happened to be atypical. Statistical significance is determined by the size of the difference between the group averages, the sample size, and the standard deviations of the groups. For practical purposes statistical significance suggests that the two larger populations from which we sample are “actually” different.", imageName: "T", videoName: "tTest"))
                for i in 0..<self.model.k{
                    let tmpElement = ModelParameters(name: "Test t for \(self.model.chosenXHeader[i]) variable", isLess: false, criticalFloor: 0.05, warningFloor: 0.1, value: tResults[i+1], description: "A statistically significant t-test result is one in which a difference between two groups is unlikely to have occurred because the sample happened to be atypical. Statistical significance is determined by the size of the difference between the group averages, the sample size, and the standard deviations of the groups. For practical purposes statistical significance suggests that the two larger populations from which we sample are “actually” different.", imageName: "T", videoName: "tTest")
                target.parametersResults.append(tmpElement)
                }
            }, tasksToMainBack: {
                target.tableView.reloadData()
                target.pickerView.isHidden = true
            }, mainView: target.view)
        }
        else if segue.identifier == "toParameters"{
            let target = segue.destination as! TableViewControllerSorted
            target.textTopLabel = "Regression parameters"
            target.pickerSections = model.headers
            target.pickerSections.insert("All", at: 0)
            
            target.mainModelParameter = [ModelParameters(name: "Regression parameters", isLess: nil, criticalFloor: nil, warningFloor: nil, value: 0, description: "In linear regression, the relationships are modeled using linear predictor functions whose unknown model parameters are estimated from the data. Such models are called linear models. Most commonly, the conditional mean of the response given the values of the explanatory variables (or predictors) is assumed to be an affine function of those values; less commonly, the conditional median or some other quantile is used. Like all forms of regression analysis, linear regression focuses on the conditional probability distribution of the response given the values of the predictors, rather than on the joint probability distribution of all of these variables, which is the domain of multivariate analysis.", imageName: "regression")]
            
            for i in 0..<model.getOLSRegressionEquation().count{
                target.parametersResultsShort.append(ModelParametersShort(name: "b\(i)", value: model.getOLSRegressionEquation()[i], isLess: false, criticalFloor: nil, warningFloor: nil, variable: nil))
            }
            
            for i in 0..<model.ELAS.count{
                target.parametersResultsShort.append(ModelParametersShort(name: "ELAS for b\(i)", value: model.ELAS[i], isLess: false, criticalFloor: nil, warningFloor: nil, variable: nil))
            }
            
            for i in 0..<model.SEB.count{
                target.parametersResultsShort.append(ModelParametersShort(name: "Se for b\(i)", value: model.SEB[i], isLess: false, criticalFloor: nil, warningFloor: nil, variable: nil))
            }
           
            target.isHiddenPicker = true
        }
        else if segue.identifier == "toUntypical"{
            let target = segue.destination as! MatrixView
            target.headers = ["Leverage", "Influancial", "DFFITS"]
            target.textTopLabel = "Untypical"
            target.data = Array(repeating: Array(repeating: "", count: 3), count: model.n)
            
            for i in 1..<self.model.n{
                target.leftHeaders.append(String(i))
            }
            
            playLoadingAsync(tasksToDoAsync: {
                 for i in 0..<self.model.n{
                    target.data[i][0] = String(format: "%.2f",self.model.leverageObservations[i])
                }
                let results = self.model.influentialObservationDFFITS()
                
                for i in 0..<self.model.n{
                    target.data[i][1] = String(format: "%.2f",results.inf[i])
                    target.data[i][2] = String(format: "%.2f",results.dffits[i])
                }
                
            }, tasksToMainBack: {
                target.spreadSheetView.reloadData()
            }, mainView: target.view)
        }
        else if segue.identifier == "toCompare"{
            let target = segue.destination as! MatrixView
            target.textTopLabel = "Compare Models"
            //F, R^2, unimportant var num, reset, jb, lm, homo   REGRESSOR, REGRESSANDS, OTHER R, CHECK T AFTER
            var models = [Model]()
            let modelsNum = paths.count
            
            
            //load models
            paths.forEach(){
                var model = Model()
                do{
                    model = try get(path: $0) as Model
                }catch let er as SavingErrors{
                    let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                    visualViewToBlur.frame = self.view.frame
                    visualViewToBlur.isHidden = true
                    self.view.addSubview(visualViewToBlur)
                    
                    playErrorScreen(msg: er.rawValue, blurView: visualViewToBlur, mainViewController: self, alertToDismiss: nil)
                }catch{
                    
                }
                models.append(model)
            }
            
            target.leftHeaders = ["n", "k", "Test F", "R\u{00B2}", "Test t var failed", "RESET test", "JB test", "LM test", "White test"]

            models.forEach(){
                if let modelName = $0.name{
                    target.headers.append(modelName)
                }else{
                    let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                    visualViewToBlur.frame = self.view.frame
                    visualViewToBlur.isHidden = true
                    self.view.addSubview(visualViewToBlur)
                    playErrorScreen(msg: "Choose models correctly!", blurView: visualViewToBlur, mainViewController: self, alertToDismiss: nil)
                    return
                }
            }
            
            target.data = Array(repeating: Array(repeating: "", count: modelsNum), count: target.leftHeaders.count)
            
            target.toCompare = true
            playLoadingAsync(tasksToDoAsync: {
                for i in 0..<models.count{
                    target.data[0][i] = String(models[i].n)
                    target.data[1][i] = String(models[i].k)
                    target.data[2][i] = String(format: "%.2f",models[i].parametersF)
                    target.data[3][i] = String(format: "%.2f",models[i].squareR)
                    var j = 0
                    models[i].parametersT.forEach(){
                        if $0 > 0.05{
                            j = j + 1
                        }
                    }
                    target.data[4][i] = String(j)
                    let testAdv = OLSTestsAdvanced(baseModel: models[i])
                    target.data[5][i] = String(format: "%.2f",testAdv.RESET())
                    target.data[6][i] = String(format: "%.2f",models[i].JBtest)
                    target.data[7][i] = String(format: "%.2f",testAdv.LMAutoCorrelation())
                    target.data[8][i] = String(format: "%.2f",testAdv.WhiteHomo())
                }
            }, tasksToMainBack: {
                target.spreadSheetView.reloadData()
                self.playShortAnimationOnce(mainViewController: target)
            }, mainView: target.view)
            
        }
        else if segue.identifier == "toOther"{
            let target = segue.destination as! OtherEstimationVC
            target.model = self.model
        }
        else if segue.identifier == "toLogit"{
            let target = segue.destination as! OtherEstimationVC
            target.model = self.model
            target.isLogitProbit = true
        }
        else if segue.identifier == "toProbit"{
            let target = segue.destination as! OtherEstimationVC
            target.model = self.model
            target.isLogitProbit = true
            target.isProbit = true
        }
    }
    
    func toCompare(){
        let plists = self.paths.filter{$0.contains(".plist")}.count
        if self.paths.count > 1 && plists == self.paths.count{
            self.performSegue(withIdentifier: "toCompare", sender: self)
        }else{
            let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            visualViewToBlur.frame = self.view.frame
            visualViewToBlur.isHidden = true
            self.view.addSubview(visualViewToBlur)

            self.playErrorScreen(msg: "Choose models correctly!", blurView: visualViewToBlur, mainViewController: self, alertToDismiss: nil)
        }
    }
}

extension SideMenuView : UIDocumentPickerDelegate{
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        //error
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        paths = urls.compactMap(){
            $0.path
        }
        toCompare()
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
