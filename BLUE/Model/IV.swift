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
    func getGIVRegressionEquation(Z : [[Double]]) -> [Double]
}

extension IVCalculable where Self==Model{
    func getGIVRegressionEquation(Z : [[Double]]) -> [Double]{
        let X = Matrix(chosenX)
        let Z = Matrix(Z)
        let Y = Matrix(chosenY)
        let X2 = mul(mul(Z,y: inv(mul(Z, y: transpose(Z)))), y: mul(transpose(Z),y: X))
        let b = mul(inv(mul(transpose(X2), y: X2)), y: mul(transpose(X2), y: Y))
        
        var result = [Double]()
        b.forEach { (array) in
            result.append(array[0])
        }
        return result
    }
}

protocol IVTestable : Statisticable{
    func HausmannTest(Z: [[Double]]) -> Double
}

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
        
        
        return 0.0
    }
}
