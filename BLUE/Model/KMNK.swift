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
    
    var error = [Double]()
    var SSR : Double{
        get{
            calculateSSR()
            return sum(error)
        }
    }
    var se : Double{
        get{
            return sqrt(1.0/((Double(super.n)-Double(super.k)-1.0))*self.SSR)
        }
    }
    var squareR : Double{
        get{
            let meanY = mean(Ytmp)
            var arrayUp = [Double]()
            var arrayDown = [Double]()
            for i in 0..<n{
                arrayUp.append(pow(calculatedY[i]-meanY, 2.0))
                arrayDown.append(pow(Ytmp[i]-meanY, 2.0))
                }
            return sum(arrayUp)/sum(arrayDown)
            }
    }
    var squereFi : Double{
        get{
            return 1-squareR
        }
    }
    var equation = [Double]()
    var calculatedY = [Double]()
    
    override init(header: [String]?, k: Int, n: Int, observations: [Observation], withHeaders: Bool, observationLabeled: Bool) {
        super.init(header: header, k: k, n: n, observations: observations, withHeaders: withHeaders, observationLabeled: observationLabeled)
        calculateRegression()
        calculateY()
    }
    
    private func calculateRegression(){
        let X = Matrix<Double>(prepare().X)
        let Y = Matrix<Double>(prepare().Y)
        let result = (mul((inv(mul(transpose(X), y: X))), y: mul(transpose(X), y: Y)))
        result.forEach({ (slice) in
            equation.append(Array(slice)[0])
        })
    }
    
    private func calculateY(){
        let X = Matrix<Double>(prepare().X)
        var tmpY = Array(repeating: Array(repeating: 0.0, count: 1), count: 1)
        tmpY[0]=equation
        let Y = Matrix<Double>(tmpY)
        let result = mul(X, y: transpose(Y))
        result.forEach({ (slice) in
            calculatedY.append(Array(slice)[0])
        })
    }
    
    private func calculateSSR(){
        for i in 0..<Ytmp.count{
            error.append(pow((Ytmp[i]-calculatedY[i]), 2.0))
        }
    }
}


