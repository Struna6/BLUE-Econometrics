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

protocol ChoosableColumns {
    func addY(label : String) -> [[Double]]
    func addX(label : String) -> [[Double]]
}
extension ChoosableColumns where Self==Model{
    func addY(label : String) -> [[Double]]{
        //let colNum = headers.firstIndex(of: label)
        return[[0.0]]
    }
    func addX(label : String) -> [[Double]]{
        return[[0.0]]
    }
}

protocol ImportableFromTextFile{
    func importFromTextFile(withHeaders : Bool, observationLabeled : Bool, path : String) -> (header: [String]?,  n : Int, observations : [Observation])
}
extension ImportableFromTextFile where Self==Model{
    func importFromTextFile(withHeaders : Bool, observationLabeled : Bool, path : String) -> (header: [String]?, n : Int, observations : [Observation]){
        //let path = Bundle.main.path(forResource: "test1", ofType: "txt")
        var text = ""
        do {
            text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        } catch  {
            print("error getting data " + path)
            exit(1)
        }
        var seperatedObservations = [String]()
        var seperatedValuesStr = [String]()
        var seperatedValues = [Double]()
        var i = 0
        var observations = [Observation]()
        var headers = [String]()
        let end = text.index(text.endIndex, offsetBy: -1)
        text = String(text[..<end])
        seperatedObservations = text.components(separatedBy: ";")

        seperatedObservations.forEach { (obs) in
            seperatedValuesStr = obs.components(separatedBy: ",")
            var observation = Observation()
            if withHeaders && i==0{
                headers = seperatedValuesStr
            }
            else{
                seperatedValues = seperatedValuesStr.compactMap{Double($0)}
                if observationLabeled && (i != 0){
                    observation.label = seperatedValuesStr[0]
                    seperatedValues.removeFirst()
                }
                observation.observationArray = seperatedValues
                observations.append(observation)
            }
            i=i+1
        }
        return (headers, i, observations)
    }
}

protocol OLSCalculable{
    var estimatedY : [Double] {get}
    var SR : [Double] {get}
    var SSR : Double {get}
    var SSE : Double {get}
    var SST : Double {get}
    var se : Double {get}
    var squareR : Double {get}
    var squereFi : Double {get}
    var MAE : Double {get}
    func getOLSRegressionEquation() -> [Double]
    
}
extension OLSCalculable where Self==Model{
    var  estimatedY: [Double]{
        get{
            var returnTmp = [Double]()
            let X = Matrix<Double>(chosenX)
            var tmpY = [[Double]]()
            tmpY.append(getOLSRegressionEquation())
            let Y = Matrix<Double>(tmpY)
            let result = mul(X, y: transpose(Y))
            result.forEach({ (slice) in
                    returnTmp.append(Array(slice)[0])
            })
            return returnTmp
        }
    }
    var SR : [Double]{
        get{
            var tmp = [Double]()
            for i in 0..<chosenY[0].count{
                tmp.append(pow((chosenY[0][i]-estimatedY[i]), 2.0))
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
            let meanY = mean(chosenY[0])
            for i in 0..<chosenY[0].count{
                tmp.append(pow((estimatedY[i]-meanY),2.0))
            }
            return sum(tmp)
        }
    }
    var SST : Double{
        get{
            var tmp = [Double]()
            let meanY = mean(chosenY[0])
            for i in 0..<chosenY[0].count{
                tmp.append(pow((chosenY[0][i]-meanY),2.0))
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
            for i in 0..<chosenY[0].count{
                tmp.append(abs(chosenY[0][i]-estimatedY[i]))
            }
            return mean(tmp)
        }
    }
    func getOLSRegressionEquation() -> [Double]{
        var equation = [Double]()
        let X = Matrix<Double>(chosenX)
        let Y = Matrix<Double>(chosenY)
        let result = (mul((inv(mul(transpose(X), y: X))), y: mul(transpose(X), y: Y)))
            result.forEach({ (slice) in
            equation.append(Array(slice)[0])
        })
        return equation
    }
}

struct Model : OLSCalculable, ImportableFromTextFile, ChoosableColumns{
    var allObservations = [Observation]()
    var chosenX = [[Double]](){
        didSet{
            k = chosenX[0].count - 1
        }
    }
    var chosenY = [[Double]]()
    var flatY = [Double]()

    var withHeaders : Bool
    var observationLabeled : Bool
    var headers = [String]()
    var n : Int = 0
    var k : Int = 0
    var path : String 
    
    init(withHeaders : Bool, observationLabeled : Bool, path : String){
        self.withHeaders = withHeaders
        self.observationLabeled = observationLabeled
        self.path = Bundle.main.path(forResource: "test1", ofType: "txt")!
        let result = importFromTextFile(withHeaders: withHeaders, observationLabeled: observationLabeled, path: self.path)
        self.allObservations = result.observations
        self.n = result.n
        self.headers = result.header!
        if !withHeaders{
            for i in 0..<allObservations[0].observationArray.count{
                headers.append(String(UnicodeScalar(i+65)!))
            }
        }
    }
}
