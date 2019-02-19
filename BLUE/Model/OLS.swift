//
//  OLS.swift
//  BLUE
//
//  Created by Karol Struniawski on 30/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation
import Accelerate
import Surge
import CSV

enum ImportError : String, Error{
    case readingFileError = "Reading file filed!"
    case wrongValue = "Wrong value, check file!"
    case doubleError = "Imported value is not a number!"
    case sizeError = "Size of variables are not the same!"
}

protocol ImportableFromTextFile{
    func importFromTextFile(withHeaders : Bool, observationLabeled : Bool, path : String) throws -> (header: [String]?,  n : Int, observations : [Observation], labeled : Bool, headered : Bool)
}
extension ImportableFromTextFile where Self==Model{
    func importFromTextFile(withHeaders : Bool, observationLabeled : Bool, path : String) throws -> (header: [String]?,  n : Int, observations : [Observation], labeled : Bool, headered : Bool){
        //let path = Bundle.main.path(forResource: "test1", ofType: "txt")
        var text = ""
        do {
            text = try String(contentsOfFile: path, encoding: String.Encoding.macOSRoman)
        } catch  {
            throw ImportError.readingFileError
        }
        if let range = text.range(of: "f0\\fs24 \\cf0"){
            text = String(text[range.upperBound...])
        }
        var labeled = false
        var headered = false
        var headers = [String]()
        var observations = [Observation]()
        var result = [[String]]()
        let rows = text.components(separatedBy: ";")
        rows.forEach { (row) in
            let tmpRow = row
            let columns = tmpRow.components(separatedBy: ",")
            result.append(columns)
        }
        let firstRow = result[0]
        
        if firstRow.count < 2{
            throw ImportError.wrongValue
        }
//        if firstRow.count < 2{
//            fatalError("Minimim column number: 2")
//        }
        if firstRow[0] == ""{
            //[0,0] is blank
            labeled = true
            headered = true
        }
        else if let _ = Double(firstRow[0]){
            //[0,0] is number
            headered = false
            labeled = false
        }else{
            //[0,0] is string
            if let _ = Double(firstRow[1]){
                //[0,1] is number
                labeled = true
                headered = false
            }else{
                headered = true
                labeled = false
            }
        }
        var k = 0
        
        var checker = result[0].count
        
        try result.forEach(){
            if $0.count != checker{
                throw ImportError.sizeError
            }else{
                checker = $0.count
            }
        }
        
        try result.forEach { (row) in
            var tmpRow = row
            var tmp = Observation()
            if k==0 && headered{
                headers = row
                if headered && labeled{
                    headers.remove(at: 0)
                }
                tmpRow.removeAll()
            }
            if labeled && k != 0{
                tmp.label = tmpRow.first!
                tmpRow.remove(at: 0)
            }
            var tmpDouble = [Double]()
            try tmpRow.forEach { (i) in
                var tmpI = i
                if tmpI.contains("\n"){
                    tmpI.remove(at: tmpI.firstIndex(of: "\n")!)
                }
                if tmpI.contains(","){
                    tmpI = String(tmpI.map{$0 == "," ? "." : $0})
                }
                tmpI = tmpI.stripped
                if let check = Double(tmpI){
                    tmpDouble.append(check)
                }else{
                    throw ImportError.doubleError
                }
            }
            if tmpDouble.count > 0{
                tmp.observationArray = tmpDouble
                observations.append(tmp)
            }
            k = k + 1
        }
        return(headers,observations.count,observations,labeled,headered)
    }
}

protocol CSVImportable{
    func loadDataFromCSV(path: String) throws -> (labeled : Bool, headered : Bool, headers : [String], observations : [Observation])
}
extension CSVImportable where Self==Model{
    func loadDataFromCSV(path: String) throws -> (labeled : Bool, headered : Bool, headers : [String], observations : [Observation]){
        var text = ""
        do {
            text = try String(contentsOfFile: path, encoding: String.Encoding.isoLatin1)
        } catch  {
            throw ImportError.readingFileError
        }
        text = String(text.dropFirst())
        text = String(text.dropFirst())
        text = String(text.dropFirst())
        
        var labeled = false
        var headered = false
        var headers = [String]()
        var observations = [Observation]()
        
        var result = [[String]]()
        let rows = text.components(separatedBy: "\r\n")
        rows.forEach { (row) in
            let columns = row.components(separatedBy: ";")
            result.append(columns)
        }
        let firstRow = result[0]
        
        if firstRow.count < 2{
            throw ImportError.wrongValue
        }
        
        if firstRow[0] == ""{
            //[0,0] is blank
            labeled = true
            headered = true
        }
        else if let _ = Double(firstRow[0]){
                //[0,0] is number
                headered = false
                labeled = false
            }else{
                //[0,0] is string
                if let _ = Double(firstRow[1]){
                    //[0,1] is number
                    labeled = true
                    headered = false
                }else{
                    headered = true
                    labeled = false
                }
        }
        var k = 0
        var checker = result[0].count
        try result.forEach(){
            if $0.count != checker{
                throw ImportError.sizeError
            }else{
                checker = $0.count
            }
        }
        
        try result.forEach { (row) in
            var tmpRow = row
            var tmp = Observation()
            if k==0 && headered{
                headers = row
                if headered && labeled{
                    headers.remove(at: 0)
                }
                tmpRow.removeAll()
            }
            if labeled && k != 0{
                tmp.label = tmpRow.first!
                tmpRow.remove(at: 0)
            }
            var tmpDouble = [Double]()
            try tmpRow.forEach { (i) in
                var tmpI = i
                if tmpI.contains(","){
                    tmpI = String(tmpI.map{$0 == "," ? "." : $0})
                }
                if let check = Double(tmpI){
                    tmpDouble.append(check)
                }else{
                    throw ImportError.doubleError
                }
            }
            if tmpDouble.count > 0{
                tmp.observationArray = tmpDouble
                observations.append(tmp)
            }
            k = k + 1
        }

        return (labeled,headered,headers,observations)
    }
}

protocol OLSCalculable{
    var estimatedY : [Double] {get}
    var S : [Double] {get}
    var SR : [Double] {get}
    var SSR : Double {get}
    var SSE : Double {get}
    var SST : Double {get}
    var se : Double {get}
    var squareR : Double {get}
    var squereFi : Double {get}
    var MAE : Double {get}
    var SEB : [Double] {get}
    var ELAS : [Double] {get}
    
    var leverageObservations : [Double] {get}

    func getOLSRegressionEquation() -> [Double]
    func influentialObservationDFFITS() -> (inf: [Double], dffits: [Double])
}

extension OLSCalculable where Self==Model{
    var estimatedY: [Double]{
        get{
            var returnTmp = [Double]()
            let X = Matrix<Double>(chosenX)
            var tmpY = [[Double]]()
            tmpY.append(getOLSRegressionEquation())
            let Y = Matrix<Double>(tmpY)

            let result = mul(X, y: Surge.transpose(Y))
            result.forEach({ (slice) in
                    returnTmp.append(Array(slice)[0])
            })
            return returnTmp
        }
    }
    //ei
    var S : [Double]{
        get{
            var tmp = [Double]()
            for i in 0..<flatY.count{
                tmp.append(flatY[i]-estimatedY[i])
            }
            return tmp
        }
    }
    //ei^2
    var SR : [Double]{
        get{
            var tmp = [Double]()
            for i in 0..<flatY.count{
                tmp.append(pow((flatY[i]-estimatedY[i]), 2.0))
            }
            return tmp
        }
    }
    var SSR : Double{
        get{
            return sum(SR)
        }
    }
    var SSE : Double{
        get{
            var tmp = [Double]()
            let meanY = mean(flatY)
            for i in 0..<n{
                tmp.append(pow((estimatedY[i]-meanY),2.0))
            }
            return sum(tmp)
        }
    }
    var SST : Double{
        get{
            var tmp = [Double]()
            let meanY = mean(flatY)
            for i in 0..<flatY.count{
                tmp.append(pow((flatY[i]-meanY),2.0))
            }
            return sum(tmp)
        }
    }
    var se : Double{
        get{
            return sqrt(1.0/((Double(n)-Double(k)-1.0))*SSR)
        }
    }
    var squareR : Double{
        get{
            return self.SSE/self.SST
            }
    }
    var squereFi : Double{
        get{
            return 1-squareR
        }
    }
    var MAE : Double{
        get{
            var tmp = [Double]()
            for i in 0..<flatY.count{
                tmp.append(abs(flatY[i]-estimatedY[i]))
            }
            return mean(tmp)
        }
    }
    var SEB : [Double] {
        get{
            let X = Matrix<Double>(chosenX)
            let XT = transpose(X)
            let matrix = mul((se*se), x: myInv(mul(XT, y: X)))
            var result = [Double]()
            var i = 0
            matrix.forEach { (row) in
                result.append(sqrt(Array(row)[i]))
                i = i + 1
            }
            return result
        }
    }
    var ELAS : [Double]{
        get{
            var tmp = [Double]()
            var means = [Double]()
            let avgY = mean(flatY)
            
            for i in 1..<SEB.count{
                var avg = [Double]()
                chosenX[i].forEach({
                    avg.append($0)
                })
                means.append(mean(avg))
            }
            
            
            for i in 1..<SEB.count{
                let val = (getOLSRegressionEquation()[i] - means[i-1]) / avgY
                tmp.append(val)
            }
            return tmp
        }
    }
    var leverageObservations : [Double]{
        get{
            var result = [Double]()
            let X = Matrix(chosenX)
            let H = mul(X, y: mul(myInv(mul(transpose(X), y: X)),y : transpose(X)))
            
            for i in 0..<n{
                H.forEach { (slice) in
                    let start = slice.startIndex
                    result.append(slice[start + i])
                }
            }
            return result
        }
    }
    
    func influentialObservationDFFITS() -> (inf: [Double], dffits: [Double]){
        var result = [Double]()
        var DFFITS = [Double]()
        
        for i in 0..<n-1{
            let y0 = estimatedY[i]
            var tmpModel = self
            tmpModel.chosenX.remove(at: i)
            tmpModel.chosenY.remove(at: i)
            tmpModel.flatY.remove(at: i)
            let y1 = tmpModel.estimatedY[i]
            let e = y1-y0
            let h = leverageObservations[i]
            result.append(e * (h / (1-h)))
            if tmpModel.se == 0{
                DFFITS.append(0.0)
            }else{
                let tmp = e / tmpModel.se * sqrt(h)
                if tmp.isFinite{
                    DFFITS.append(tmp)
                }else{
                    DFFITS.append(0.0)
                }
                
            }
            
        }
        result.append(Double.nan)
        DFFITS.append(Double.nan)
        return (result, DFFITS)
    }
    
    func getOLSRegressionEquation() -> [Double]{
        var equation = [Double]()
        let X = Matrix<Double>(chosenX)
        let Y = Matrix<Double>(chosenY)
        let result = (mul((myInv(mul(Surge.transpose(X), y: X))), y: mul(Surge.transpose(X), y: Y)))
        result.forEach({ (slice) in
            equation.append(Array(slice)[0])
        })
        return equation
    }
}



protocol CoreDataAnalysable : QuantileCalculable{
    var avarage : [Double]{get}
    var SeCore : [Double]{get}
    var Var : [Double]{get}
    var Ve : [Double]{get}
    var Me : [Double]{get}
    var Q1 : [Double]{get}
    var Q3 : [Double]{get}
    var Qdifference : [Double]{get}
    var kurtosis : [Double]{get}
    var skewness : [Double]{get}
    var skewnessQ : [Double]{get}
    var range : [Double]{get}
    var minCore : [Double]{get}
    var maxCore : [Double]{get}
    
    func makeCorrelationsArray2D() -> [[String]]
}
extension CoreDataAnalysable where Self==Model{
    var avarage : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var sum = 0.0
                for row in 0..<allObservations.count{
                    sum = sum + allObservations[row].observationArray[col]
                }
                result.append(sum/Double(n))
            }
            return result
        }
    }
    var SeCore : [Double]{
        get{
            return Var.compactMap(){sqrt($0)}
        }
    }
    var Var : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var sum = 0.0
                for row in 0..<allObservations.count{
                    sum = sum + pow((allObservations[row].observationArray[col])-avarage[col],2.0)
                }
                result.append(sum/Double(n))
            }
            return result
        }
    }
    var Ve : [Double]{
        get{
            var result = [Double]()
            for i in 0..<allObservations[0].observationArray.count{
                result.append(SeCore[i]/avarage[i])
            }
            return result
        }
    }
    var Me : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var tmp = [Double]()
                for row in 0..<allObservations.count{
                    tmp.append(allObservations[row].observationArray[col])
                }
                result.append(quantile(n: 0.5, tmp))
            }
            return result
        }
    }
    var Q1 : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var tmp = [Double]()
                for row in 0..<allObservations.count{
                    tmp.append(allObservations[row].observationArray[col])
                }
                result.append(quantile(n: 0.25, tmp))
            }
            return result
        }
    }
    var Q3 : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var tmp = [Double]()
                for row in 0..<allObservations.count{
                    tmp.append(allObservations[row].observationArray[col])
                }
                result.append(quantile(n: 0.75, tmp))
            }
            return result
        }
    }
    var Qdifference : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                result.append((Q3[col]-Q1[col])/2)
            }
            return result
        }
    }
    var kurtosis : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var sum = 0.0
                for row in 0..<allObservations.count{
                    sum = sum + pow((allObservations[row].observationArray[col])-avarage[col],4.0)
                }
                result.append((sum/Double(n)/pow(SeCore[col], 4.0))-3)
            }
            return result
        }
    }
    var skewness : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                result.append(3*(avarage[col]-Me[col])/SeCore[col])
            }
            return result
        }
    }
    var skewnessQ : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                result.append(((Q1[col] + Q3[col]) - 2 * Me[col]) / (2*Qdifference[col]))
            }
            return result
        }
    }
    var range : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var tmp = [Double]()
                for row in 0..<allObservations.count{
                    tmp.append(allObservations[row].observationArray[col])
                }
                result.append(max(tmp) - min(tmp))
            }
            return result
        }
    }
    var minCore : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var tmp = [Double]()
                for row in 0..<allObservations.count{
                    tmp.append(allObservations[row].observationArray[col])
                }
                result.append(min(tmp))
            }
            return result
        }
    }
    var maxCore : [Double]{
        get{
            var result = [Double]()
            for col in 0..<allObservations[0].observationArray.count{
                var tmp = [Double]()
                for row in 0..<allObservations.count{
                    tmp.append(allObservations[row].observationArray[col])
                }
                result.append(max(tmp))
            }
            return result
        }
    }
    
    func makeCorrelationsArray2D() -> [[String]]{
        let nCols = allObservations[0].observationArray.count
        var tmp = Array(repeating: Array(repeating: "-", count: nCols), count: nCols)
        for row in 0..<nCols{
            for col in 0..<nCols{
                if col == row{
                    tmp[row][col] = "1"
                }else{
                    var meanX : Double = 0
                    var meanY : Double = 0
                    var vectorX = [Double]()
                    var vectorY = [Double]()
                    allObservations.forEach { (i) in
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
                    tmp[row][col] = String(format: "%.2f", result)
                }
            }
        }
        return tmp
    }
}

private var fvalueLastCalculated : Double = 0
private var fTestvalueLastCalculated : Double = 0
private var tvalueLastCalculated : [Double] = [Double]()
private var tTestvalueLastCalculated : [Double] = [Double]()
private var tTestStop : Bool = false
private var chivalueLastCalculated : Double = 0
private var chiTestvalueLastCalculated : Double = 0

protocol OLSTestable: OLSCalculable, Statisticable{
    var parametersF : Double{get}
    var parametersT : [Double]{get}
    var JBtest : Double {get}
}

extension OLSTestable where Self==Model{
    var parametersF : Double{
        get{
            let F1 = ((n-k-1)/k)
            let F2 = (squareR/(1-squareR))
            let F = Double(F1) * F2
            
            if F == fvalueLastCalculated{
                return fTestvalueLastCalculated
            }else{

                fvalueLastCalculated = F
                let result = 1 - FSnedeccorCDF(f: F, d1: Double(k), d2: Double(n-k-1))
                fTestvalueLastCalculated = result
                fvalueLastCalculated = F
                return result
            }
        }
    }
    var parametersT : [Double]{
        get{
            var tmp = [Double]()
            for i in 0..<SEB.count{
                var T = getOLSRegressionEquation()[i]/SEB[i]
                T = T.magnitude
                if tvalueLastCalculated.count == k+1{
                    if tvalueLastCalculated[i] == T{
                        tmp.append(tTestvalueLastCalculated[i])
                    }else{
                        let calculatedT = 2 * (1 - TStudentCDF(t: T, v: Double(n-k-1)))
                        tvalueLastCalculated[i] = T
                        tTestvalueLastCalculated[i] = calculatedT
                        tmp.append(calculatedT)
                    }
                }else{
                    let calculatedT = 2 * (1 - TStudentCDF(t: T, v: Double(n-k-1)))
                    tvalueLastCalculated.append(T)
                    tTestvalueLastCalculated.append(calculatedT)
                    tmp.append(calculatedT)
                }
            }
            return tmp
        }
    }
    var JBtest : Double{
        get{
            let se = sqrt(1 / Double(n) * sum(SR))
            var tmp3 = [Double]()
            for i in 0..<flatY.count{
                tmp3.append(pow((flatY[i]-estimatedY[i]), 3.0))
            }
            var tmp4 = [Double]()
            for i in 0..<flatY.count{
                tmp4.append(pow((flatY[i]-estimatedY[i]), 4.0))
            }
            let beta1 = ((1 / Double(n)) * sum(tmp3)) / pow(se, 3.0)
            let beta2 = ((1 / Double(n)) * sum(tmp4)) / pow(se, 4.0)
            let x = Double(n) * ((beta1 / 6) + (pow(beta2 - 3, 2.0) / 24))
            
            if x == chivalueLastCalculated{
                return chiTestvalueLastCalculated
            }else{
                let chiResult =  1 - chiICDF(x: x, k: 2)
                chivalueLastCalculated = x
                chiTestvalueLastCalculated = chiResult
                return chiResult
            }
        }
    }
}

private var RESETvalueLast : Double = 0
private var RESETtestValueLast : Double = 0
private var LMvalueLast : Double = 0
private var LMtestValueLast : Double = 0
private var WhiteTestValueLast : Double = 0
private var WhiteValueLast : Double = 0

struct OLSTestsAdvanced : Statisticable{
    var model1 : Model
    init(baseModel : Model){
        self.model1 = baseModel
    }
    
    func RESET() -> Double{
        var model2 = Model()
        model2 = model1
        var tmp2 = [Double]()
        var tmp3 = [Double]()
        model2.estimatedY.forEach { (el) in
            tmp2.append(el*el)
            tmp3.append(el*el*el)
        }
        var i = 0
        tmp2.forEach { (el) in
            model2.chosenX[i].append(el)
            i = i + 1
        }
        i = 0
        tmp3.forEach { (el) in
            model2.chosenX[i].append(el)
            i = i + 1
        }
        
        let R1 = model1.squareR
        let R2 = model2.squareR
        let k1 = model1.k
        let k2 = model2.k
        
        let top = (R2-R1)/Double(k2-k1)
        let bottom = (1-R2)/Double(model1.n-k2-1)
        let d2 = Double(model1.n-k2-1)
        let d1 = Double(k2-k1)
        
        if d2 < 0{
            return Double.nan
        }
        
        let F = top/bottom
        if F == RESETvalueLast{
            return RESETtestValueLast
        }else{
            let result = 1 - FSnedeccorCDF(f: F, d1: d1, d2: d2)
            RESETvalueLast = F
            RESETtestValueLast = result
            return result
        }
    }
    func LMAutoCorrelation() -> Double{
        var model2 = Model()
        model2 = model1
        model2.chosenY.removeAll()
        var i = 0
        model1.estimatedY.forEach { (row) in
            if i != 0{
                let tmp = [row]
                model2.chosenY.append(tmp)
            }
            i = i + 1
        }
        model2.chosenX.remove(at: 0)
        model2.n = model2.n - 1
        model2.k = model2.k + 1
        model2.flatY = model1.estimatedY
    
        for i in 0..<model2.chosenX.count{
            model2.chosenX[i].append(model1.estimatedY[i])
        }
        let R = model2.squareR
        
        let chi = Double(model1.n - 1) * R
        if chi.rounded() == LMvalueLast.rounded(){
            return LMtestValueLast
        }else{
            let result = 1 - chiICDF(x: chi, k: 1)
            LMvalueLast = chi
            LMtestValueLast = result
            return result
        }
    }
    func WhiteHomo() -> Double{
        var model2 = model1
        var tmpSqueres = model1.chosenX
        
        for i in 1..<model1.k+1{
            for j in 1..<model1.k+1{
                if j >= i{
                    for row in 0..<model1.n{
                        tmpSqueres[row].append(tmpSqueres[row][i] * tmpSqueres[row][j])
                    }
                }
            }
        }
        
        model2.flatY = model1.SR
        model2.chosenX = tmpSqueres
        
        for i in 0..<model1.n{
            model2.chosenY[i] = [model1.SR[i]]
        }
        
        let R = model2.squareR
        let chi = Double(model2.n) * R
        let degrees = model2.k
            //- model1.k
        if chi.rounded() == WhiteValueLast.rounded(){
            return WhiteTestValueLast
        }else{
            let result =  1 - chiICDF(x: chi, k: Double(degrees))
            WhiteValueLast = chi
            WhiteTestValueLast  = result
            return result
        }
    }
}


