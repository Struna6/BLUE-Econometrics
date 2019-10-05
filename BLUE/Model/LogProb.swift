//
//  LogProb.swift
//  BLUE
//
//  Created by Karol Struniawski on 15/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import Foundation
import Surge


protocol LogProb : OLSCalculable, Statisticable{
    func logEstimatedY(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]
    func probEstimatedY(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]
    
    func logSR(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]
    func logSSR(nGroup : [Double], success : [Double], X : [[Double]]) -> Double
    func logSe(nGroup : [Double], success : [Double], X : [[Double]]) -> Double
    func logSEB(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]
    
    func calculateLogitCountedR(nGroup : [Double], success : [Double], X : [[Double]]) -> [String : Double]
    func calculateProbitCountedR(nGroup : [Double], success : [Double], X : [[Double]]) -> [String : Double]
    
    func getLogitEquation(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]
    func getProbitEquation(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]
}

extension LogProb where Self==Model{
    func logEstimatedY(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]{
        var returnTmp = [Double]()
        var tmpY = [[Double]]()
        tmpY.append(getLogitEquation(nGroup: nGroup, success: success, X: X))
        let Y = Matrix<Double>(tmpY)
        let X = Matrix<Double>(self.chosenX)
        let result = mul(X, y: Surge.transpose(Y))
        result.forEach({ (slice) in
            returnTmp.append(Array(slice)[0])
        })
        return returnTmp
    }
    func probEstimatedY(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]{
        var returnTmp = [Double]()
        var tmpY = [[Double]]()
        tmpY.append(getProbitEquation(nGroup: nGroup, success: success, X: X))
        let Y = Matrix<Double>(tmpY)
        let X = Matrix<Double>(self.chosenX)
        let result = mul(X, y: Surge.transpose(Y))
        result.forEach({ (slice) in
            returnTmp.append(Array(slice)[0])
        })
        return returnTmp
    }
    func logSR(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]{
        var tmp = [Double]()
        var logFlatY = [Double]()
        
        for i in 0..<nGroup.count{
            let tmp = success[i]/nGroup[i]
            if tmp < 0.0 || tmp > 1.0{
                return [Double.nan]
            }else{
                logFlatY.append(tmp)
            }
        }
        
        for i in 0..<self.flatY.count{
            tmp.append(pow((logFlatY[i]-logEstimatedY(nGroup: nGroup, success: success, X: X)[i]), 2.0))
        }
        return tmp
    }
    func logSSR(nGroup : [Double], success : [Double], X : [[Double]]) -> Double{
        return sum(logSR(nGroup: nGroup, success: success, X: X))
    }
    func logSe(nGroup : [Double], success : [Double], X : [[Double]]) -> Double{
        return sqrt(1.0/((Double(self.n)-Double(self.k)-1.0))*logSSR(nGroup: nGroup, success: success, X: X))
    }
    func logSEB(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double] {
        let se = logSe(nGroup: nGroup, success: success, X: X)
        let X = Matrix<Double>(self.chosenX)
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
    
    func calculateLogitCountedR(nGroup : [Double], success : [Double], X : [[Double]]) -> [String : Double]{
        var dict = [String : Double]()
        var pTrue = [Double]()
        for i in 0..<nGroup.count{
            let tmp = success[i]/nGroup[i]
            if tmp < 0.0 || tmp > 1.0{
                return ["Error" : Double.nan]
            }else{
                pTrue.append(tmp)
            }
        }
        let pEst = logEstimatedY(nGroup: nGroup, success: success, X: X)
        
        let truePositive = pTrue.filter(){
            if $0 > 0.5{
                return true
            }else{
                return false
            }
        }
        let trueNegative = pTrue.filter(){
            if $0 <= 0.5{
                return true
            }else{
                return false
            }
        }
        let estPositive = pEst.filter(){
            if $0 > 0.5{
                return true
            }else{
                return false
            }
        }
        let estNegative = pEst.filter(){
            if $0 <= 0.5{
                return true
            }else{
                return false
            }
        }
        
        
        dict.updateValue(Double(truePositive.count), forKey: "True Positive")
        dict.updateValue(Double(trueNegative.count), forKey: "True Negative")
        dict.updateValue(Double(estPositive.count), forKey: "Estimated Positive")
        dict.updateValue(Double(estNegative.count), forKey: "Estimated Negative")
        if truePositive.count != 0{
            dict.updateValue(Double(estPositive.count / truePositive.count), forKey: "True Positive %")
        }
        if trueNegative.count != 0 {
            dict.updateValue(Double(estNegative.count / trueNegative.count), forKey: "True Negative %")
        }
        
        return dict
    }
    func calculateProbitCountedR(nGroup : [Double], success : [Double], X : [[Double]]) -> [String : Double]{
        var dict = [String : Double]()
        var pTrue = [Double]()
        for i in 0..<nGroup.count{
            let tmp = success[i]/nGroup[i]
            if tmp < 0.0 || tmp > 1.0{
                return ["Error" : Double.nan]
            }else{
                pTrue.append(tmp)
            }
        }
        let pEst = probEstimatedY(nGroup: nGroup, success: success, X: X)
        
        let truePositive = pTrue.filter(){
            if $0 > 0.5{
                return true
            }else{
                return false
            }
        }
        let trueNegative = pTrue.filter(){
            if $0 <= 0.5{
                return true
            }else{
                return false
            }
        }
        let estPositive = pEst.filter(){
            if $0 > 0.5{
                return true
            }else{
                return false
            }
        }
        let estNegative = pEst.filter(){
            if $0 <= 0.5{
                return true
            }else{
                return false
            }
        }
        
        
        dict.updateValue(Double(truePositive.count), forKey: "True Positive")
        dict.updateValue(Double(trueNegative.count), forKey: "True Negative")
        dict.updateValue(Double(estPositive.count), forKey: "Estimated Positive")
        dict.updateValue(Double(estNegative.count), forKey: "Estimated Negative")
        if truePositive.count != 0{
            dict.updateValue(Double(estPositive.count / truePositive.count), forKey: "True Positive %")
        }
        if trueNegative.count != 0 {
            dict.updateValue(Double(estNegative.count / trueNegative.count), forKey: "True Negative %")
        }
        
        return dict
    }
    
    func getLogitEquation(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]{
        var p = [Double]()
        for i in 0..<nGroup.count{
            let tmp = success[i]/nGroup[i]
            if tmp < 0.0 || tmp > 1.0{
                return [Double.nan]
            }else{
                p.append(tmp)
            }
        }
        
        var Ltmp = [Double]()
        p.forEach(){
            Ltmp.append(log(1/(1 - $0)))
        }
        
        var L2 = [[Double]]()
        Ltmp.forEach(){
            L2.append([$0])
        }
        let L = Matrix(L2)
        
        var om = Array(repeating: Array(repeating: 0.0, count: p.count), count: p.count)
        for i in 0..<om.count{
            om[i][i] = 1 / (nGroup[i] * p[i] * (1 - p[i]))
        }
        
        let omega = Matrix(om)
        let X = Matrix(X)
        
        let b = mul(mul(mul(myInv(mul(mul(transpose(X), y: myInv(omega)),y: X)),y:transpose(X)),y:myInv(omega)),y: L)
        
        var result = [Double]()
        b.forEach { (array) in
            array.forEach(){
                result.append($0)
            }
        }
        return result
    }
    func getProbitEquation(nGroup : [Double], success : [Double], X : [[Double]]) -> [Double]{
        var p = [Double]()
        for i in 0..<nGroup.count{
            let tmp = success[i]/nGroup[i]
            if tmp < 0.0 || tmp > 1.0{
                return [Double.nan]
            }else{
                p.append(tmp)
            }
        }
        
        var Ltmp = [Double]()
        p.forEach(){
            Ltmp.append(normalInverseCDF(p: $0))
        }
        
        var L2 = [[Double]]()
        Ltmp.forEach(){
            L2.append([$0])
        }
        let L = Matrix(L2)
        
        var om = Array(repeating: Array(repeating: 0.0, count: p.count), count: p.count)
        for i in 0..<om.count{
            om[i][i] = (p[i] * (1-p[i]) * pow(normalInverseCDF(p: p[i]),2.0)) / nGroup[i]
        }
        
        let omega = Matrix(om)
        let X = Matrix(X)
        
        let b = mul(mul(mul(myInv(mul(mul(transpose(X), y: myInv(omega)),y: X)),y:transpose(X)),y:myInv(omega)),y: L)
        
        var result = [Double]()
        b.forEach { (array) in
            array.forEach(){
                result.append($0)
            }
        }
        return result
    }
}
