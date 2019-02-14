//
//  IV.swift
//  BLUE
//
//  Created by Karol Struniawski on 11/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import Foundation
import Accelerate
import Surge

protocol IVCalculable{
    func SRIV(Z: [[Double]]) -> [Double]
    func SSRIV(Z: [[Double]]) -> Double
    func seIV(Z: [[Double]]) -> Double
    func IVestimatedY(Z: [[Double]]) -> [Double]
    func SEBIV(Z: [[Double]]) -> [Double]
    
    func getGIVRegressionEquation(Z : [[Double]]) -> [Double]
}

extension IVCalculable where Self==Model{
    func SRIV(Z: [[Double]]) -> [Double]{
        var tmp = [Double]()
        for i in 0..<flatY.count{
            tmp.append(pow((flatY[i]-IVestimatedY(Z: Z)[i]), 2.0))
        }
        return tmp
    }
    func SSRIV(Z: [[Double]]) -> Double{
        return sum(SRIV(Z: Z))
    }
    func seIV(Z: [[Double]]) -> Double{
            return sqrt(1.0/((Double(n)-Double(Z[0].count)-1.0))*SSRIV(Z: Z))
    }
    func IVestimatedY(Z: [[Double]]) -> [Double]{
        var returnTmp = [Double]()
        var tmpY = [[Double]]()
        tmpY.append(getGIVRegressionEquation(Z: Z))
        let Y = Matrix<Double>(tmpY)
        let Z = Matrix<Double>(Z)
        let result = mul(Z, y: Surge.transpose(Y))
        result.forEach({ (slice) in
            returnTmp.append(Array(slice)[0])
        })
        return returnTmp
    }
    func SEBIV(Z: [[Double]]) -> [Double]{
        let Z0 = Matrix<Double>(Z)
        let ZT = transpose(Z0)
        let matrix = mul((seIV(Z:Z)*seIV(Z:Z)), x: inv(mul(ZT, y: Z0)))
        var result = [Double]()
        var i = 0
        matrix.forEach { (row) in
            result.append(Array(row)[i])
            i = i + 1
        }
        return result
    }
    
    func getGIVRegressionEquation(Z : [[Double]]) -> [Double]{
        let X = Matrix(chosenX)
        let Z = Matrix(Z)
        let Y = Matrix(chosenY)
        
        let X2 = mul(mul(Z, y: inv(mul(transpose(Z), y: Z))), y: mul(transpose(Z),y: X))
        let b = mul(inv(mul(transpose(X2), y: X2)), y: mul(transpose(X2), y: Y))
        
        var result = [Double]()
        b.forEach { (array) in
            array.forEach(){
                result.append($0)
            }
        }
        return result
    }
}

protocol IVTestable : Statisticable{
    
    func HausmannTest(Z: [[Double]]) -> Double
    
}

private var hValue = 0.0
private var hTestValue = 0.0

extension IVTestable where Self==Model{
    
    func HausmannTest(Z: [[Double]]) -> Double{
        let bOLS = getOLSRegressionEquation()
        let bGIV = getGIVRegressionEquation(Z: Z)
        
        var bOt = Array(repeating: Array(repeating: 0.0, count: 1), count: bOLS.count)
        var bGt = Array(repeating: Array(repeating: 0.0, count: 1), count: bGIV.count)
        
        for i in 0..<bOLS.count{
            bOt[0][i] = bOLS[i]
            bGt[0][i] = -bGIV[i]
        }
        let bO = Matrix(bOt)
        let bG = Matrix(bGt)
        let q = add(bO, y: bG)
        
        let sbO = Matrix([SEB])
        let sbG = Matrix([SEBIV(Z: Z)])
        let s = add(sbO, y: mul(-1.0, x: sbG))
        
        let H0 = mul(mul(transpose(q), y: inv(s)),y:q)
        var H = 0.0
        H0.forEach { (row) in
            H = row[0]
        }
        
        if H == hValue{
            return hTestValue
        }else{
            hValue = H
            let result = chiICDF(x: H, k: Double(Z[0].count-chosenX[0].count))
            hTestValue = result
            return result
        }
    }
}
