//
//  KMNK.swift
//  BLUE
//
//  Created by Karol Struniawski on 17/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation
import Accelerate
import Surge


class KMNK : Model{
    
    //SR = ei^2
    var SR = [Double]()
    
    // Regression equation
    var equation = [Double]()
    
    // y^
    var estimatedY = [Double]()
    
    //SSR = sum(ei^2)
    var SSR : Double{
        get{
            for i in 0..<Ytmp.count{
                SR.append(pow((Ytmp[i]-estimatedY[i]), 2.0))
            }
            return sum(SR)
        }
    }
    
    //SSE = Explained Sum of Squares = sum(y^-y|)^2
    var SSE : Double{
        get{
            var tmp = [Double]()
            let meanY = mean(Ytmp)
            for i in 0..<Ytmp.count{
                tmp.append(pow((estimatedY[i]-meanY),2.0))
            }
            return sum(tmp)
        }
    }
    
    //SST = Total Sum of Squares (SST) =sum(y-y|)^2
    var SST : Double{
        get{
            var tmp = [Double]()
            let meanY = mean(Ytmp)
            for i in 0..<Ytmp.count{
                tmp.append(pow((Ytmp[i]-meanY),2.0))
            }
            return sum(tmp)
        }
    }
    
    var se : Double{
        get{
            return sqrt(1.0/((Double(super.n)-Double(super.k)-1.0))*self.SSR)
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
            for i in 0..<Ytmp.count{
                tmp.append(abs(Ytmp[i]-estimatedY[i]))
            }
            return mean(tmp)
        }
    }
    
    override init(withHeaders: Bool, observationLabeled: Bool, path: String) {
        super.init(withHeaders: withHeaders, observationLabeled: observationLabeled, path: path)
        calculateRegression()
        calculateEstimatedY()
    }
    
    private func calculateRegression(){
        let X = Matrix<Double>(prepare().X)
        let Y = Matrix<Double>(prepare().Y)
        let result = (mul((inv(mul(transpose(X), y: X))), y: mul(transpose(X), y: Y)))
        result.forEach({ (slice) in
            equation.append(Array(slice)[0])
        })
    }
    
    private func calculateEstimatedY(){
        let X = Matrix<Double>(prepare().X)
        var tmpY = Array(repeating: Array(repeating: 0.0, count: 1), count: 1)
        tmpY[0]=equation
        let Y = Matrix<Double>(tmpY)
        let result = mul(X, y: transpose(Y))
        result.forEach({ (slice) in
            estimatedY.append(Array(slice)[0])
        })
    }
    
    static func calculateYFromX(X : [Double], Y: [Double]) -> [Double]{
        var calculatedResult = [Double]()
        var tmpX = [[Double]]()
        for i in 0..<X.count{
            let tmpRow = [1.0, X[i]]
            tmpX.append(tmpRow)
        }
        let X = Matrix<Double>(tmpX)
        var tmpY = [[Double]]()
        tmpY.append(Y)
        let Y = Matrix<Double>(tmpY)
        let result = mul(X, y: transpose(Y))
        result.forEach({ (slice) in
            calculatedResult.append(Array(slice)[0])
        })
        return calculatedResult
    }
    
}


