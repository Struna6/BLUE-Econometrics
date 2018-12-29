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

protocol ImportableFromTextFile{
    func importFromTextFile(withHeaders : Bool, observationLabeled : Bool, path : String) -> (header: [String]?,  n : Int, observations : [Observation], labeled : Bool, headered : Bool)
}
extension ImportableFromTextFile where Self==Model{
    func importFromTextFile(withHeaders : Bool, observationLabeled : Bool, path : String) -> (header: [String]?,  n : Int, observations : [Observation], labeled : Bool, headered : Bool){
        //let path = Bundle.main.path(forResource: "test1", ofType: "txt")
        var text = ""
        do {
            text = try String(contentsOfFile: path, encoding: String.Encoding.macOSRoman)
        } catch  {
            print("error getting data " + path)
            fatalError(error.localizedDescription)
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
            fatalError("Minimim column number: 2")
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
        result.forEach { (row) in
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
            tmpRow.forEach { (i) in
                var tmpI = i
                if tmpI.contains("\n"){
                    tmpI.remove(at: tmpI.firstIndex(of: "\n")!)
                }
                if tmpI.contains(","){
                    tmpI = String(tmpI.map{$0 == "," ? "." : $0})
                }
                tmpDouble.append(Double(tmpI)!)
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
    func loadDataFromCSV(path: String) -> (labeled : Bool, headered : Bool, headers : [String], observations : [Observation])
}
extension CSVImportable where Self==Model{
    func loadDataFromCSV(path: String) -> (labeled : Bool, headered : Bool, headers : [String], observations : [Observation]){
        var text = ""
        do {
            text = try String(contentsOfFile: path, encoding: String.Encoding.isoLatin1)
        } catch  {
            print("error getting data " + path)
            fatalError(error.localizedDescription)
        }
        var labeled = false
        var headered = false
        var headers = [String]()
        var observations = [Observation]()
        
        var result = [[String]]()
        let rows = text.components(separatedBy: "\n")
        rows.forEach { (row) in
            var tmpRow = row
            tmpRow.removeLast()
            let columns = tmpRow.components(separatedBy: ";")
            result.append(columns)
        }
        let firstRow = result[0]
        if firstRow.count < 2{
            fatalError("Minimim column number: 2")
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
        result.forEach { (row) in
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
            tmpRow.forEach { (i) in
                var tmpI = i
                if tmpI.contains(","){
                    tmpI = String(tmpI.map{$0 == "," ? "." : $0})
                }
                tmpDouble.append(Double(tmpI)!)
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
    func getOLSRegressionEquation() -> [Double]
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
    var S : [Double]{
        get{
            var tmp = [Double]()
            for i in 0..<flatY.count{
                tmp.append(flatY[i]-estimatedY[i])
            }
            return tmp
        }
    }
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
            for i in 0..<flatY.count{
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
            let matrix = mul((se*se), x: inv(mul(XT, y: X)))
            var result = [Double]()
            var i = 0
            matrix.forEach { (row) in
                result.append(Array(row)[i])
                i = i + 1
            }
            return result
        }
    }
    func getOLSRegressionEquation() -> [Double]{
        var equation = [Double]()
        let X = Matrix<Double>(chosenX)
        let Y = Matrix<Double>(chosenY)
        let result = (mul((inv(mul(Surge.transpose(X), y: X))), y: mul(Surge.transpose(X), y: Y)))
            result.forEach({ (slice) in
            equation.append(Array(slice)[0])
        })
        return equation
    }
}

protocol OLSTestable: OLSCalculable, Statisticable{
    var parametersF : Double{get}
    var parametersT : [Double]{get}
}

extension OLSTestable where Self==Model{
    var parametersF : Double{
        get{
            let F1 = ((n-k-1)/k)
            let F2 = (squareR/(1-squareR))
            let F = Double(F1) * F2
            let result = fSnedecorCDF(F: F, d1: Double(k), d2: Double(n-k-1))
            return result.isInfinite ? 1 : result
        }
    }
    var parametersT : [Double]{
        get{
            var tmp = [Double]()
            for i in 0..<SEB.count{
                tmp.append(tStudentCDF(t: SEB[i]-getOLSRegressionEquation()[i], dof: Double(n-k-1)))
            }
            return tmp
        }
    }
}

struct OLSTestsAdvanced : Statisticable{
    var model1 = Model()
    var model2 = Model()
    
    mutating func RESET(modelBase : Model) -> Double{
        model1 = modelBase
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
        model2.k = model2.k + 2
        
        let R1 = model1.squareR
        let R2 = model2.squareR
        let k1 = model1.k
        let k2 = model2.k
        
        let top = (R2-R1)/Double(k2-k1)
        let bottom = (1-R2)/Double(model1.n-k2-1)
        let d2 = Double(model1.n-k2-1)
        let d1 = Double(k2-k1)
        
        print("F:\(top/bottom) d1: \(d1) d2: \(d2)")
        
        if d2 < 0{
            return Double.nan
        }
        return fSnedecorCDF(F: top/bottom, d1: d1, d2: d2)
    }
}




