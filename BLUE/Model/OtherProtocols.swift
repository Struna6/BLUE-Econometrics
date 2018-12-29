//
//  OtherProtocols.swift
//  BLUE
//
//  Created by Karol Struniawski on 24/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation
import UIKit
import Darwin

protocol Transposable{
    func transposeArray(array : [[Double]], rows : Int, cols : Int) -> [[Double]]
}
extension Transposable{
    func transposeArray(array : [[Double]], rows : Int, cols : Int) -> [[Double]]{
        var tmpX2 = Array(repeating: Array(repeating: 0.0, count: rows), count: cols)
        var i = 0
        var j = 0
        array.forEach { (row) in
            j = 0
            row.forEach({ (item) in
                tmpX2[j][i] = item
                j = j + 1
            })
            i = i + 1
        }
        return tmpX2
    }
}


protocol QuantileCalculable{
    func quantile(n: Double, _ numbers: [Double]) -> Double
}
extension QuantileCalculable{
    func quantile(n: Double, _ numbers: [Double]) -> Double{
        var nums = numbers
        nums.sort(by: {$0 < $1})
        let n1 = Int(floor(Double(numbers.count)*n))
        let n2 = Int(ceil(Double(numbers.count)*n))
        return (nums[n1]+nums[n2]) / 2
    }
}

protocol oddObservationQuantileSpotter : QuantileCalculable {
    func calculateNumberOfOddObservations() -> Int
}
extension oddObservationQuantileSpotter where Self==Model {
    func calculateNumberOfOddObservations() -> Int{
        var sum = 0
        for i in 0..<allObservations[0].observationArray.count{
            var tmp = [Double]()
            allObservations.forEach { (obs) in
                tmp.append(obs.observationArray[i])
            }
            let q1=quantile(n: 0.25, tmp)
            let q3=quantile(n: 0.75, tmp)
            tmp.forEach { (num) in
                if num > q3+(1.5*(q3-q1)) || num < q3-(1.5*(q3-q1)){
                    sum = sum + 1
                }
            }
        }
        return sum
    }
}

protocol Statisticable{
    func chiPValue(dof : Int, cv : Double) -> Double
    func incompleteGammaF(s : Double, z : Double) -> Double
    func beta(a : Double, b: Double, x: Double) -> Double
    func tStudentCDF(t : Double, dof v : Double) -> Double
    func fSnedecorCDF(F : Double, d1 : Double, d2 : Double) -> Double
}

extension Statisticable{
    //dof - degrees of freedom  cv - critical value
    func chiPValue(dof : Int, cv : Double) -> Double{
        if cv < 0 || dof < 1{
            return 0.0
        }
        let k = Double(dof) * 0.5
        let x = cv * 0.5
        
        if dof == 2{
            return exp(-1.0 * x)
        }
        
        var pValue = incompleteGammaF(s: k,z: x)
        if pValue.isNaN || pValue.isInfinite || pValue < 1e-8{
            return 1e-14
        }
        pValue = pValue / tgamma(k)
        return (1.0 - pValue)
    }

    func incompleteGammaF(s : Double, z : Double) -> Double{
        var s = s
        if z < 0.0{
            return 0.0
        }
        var sc = 1.0 / s
        sc = sc * pow(z,s)
        sc = sc * exp(-z)
        
        var sum = 1.0
        var nom = 1.0
        var denom = 1.0
        
        for _ in 0..<200{
            nom = nom * z
            s = s + 1
            denom = denom * s
            if (nom/denom).isNaN{
                break
            }
            sum = sum + (nom/denom)
        }
        return sum * sc
    }

    func beta(a : Double, b: Double, x: Double) -> Double{
        
        if x < 0.0 || x > 1.0{
            return 0.0
        }
        
        if x > (a+1.0)/(a+b+2.0) {
            return 1.0-beta(a:b,b:a,x:1.0-x)
        }
        
        let lbeta = lgamma(a)+lgamma(b)-lgamma(a+b)
        let front = exp(log(x)*a+log(1.0-x)*b-lbeta)/a
        var f = 1.0
        var c = 1.0
        var d = 0.0
        
        var m : Double
        for i in 0..<200{
            m = Double(i)/2
            var numerator : Double
            if i == 0 {
                numerator = 1.0
            } else if (i % 2 == 0) {
                numerator = (m*(b-m)*x)/((a+2.0*m-1.0)*(a+2.0*m))
            } else {
                numerator = -((a+m)*(a+b+m)*x)/((a+2.0*m)*(a+2.0*m+1))
            }
            
            d = 1.0 + numerator * d
            if abs(d) < 1.0e-20{
                d = 1.0e-20
            }
            d = 1.0 / d
            c = 1.0 + numerator / c
            if abs(c) < 1.0e-20{
                c = 1.0e-20
            }
            let cd = c*d;
            f = f * cd;
            
            if abs(1.0-cd) < 1.0e-8 {
                return front * (f-1.0);
            }
        }
        return 1.0/0.0
    }

    func tStudentCDF(t : Double, dof v : Double) -> Double{
        if v == 1{
            return (1/2) + ((1/Double.pi)*atan(t))
        }
        if v == 2{
            return (1/2) + (t/(2*sqrt(2+(t*t))))
        }
        /*The cumulative distribution function (CDF) for Student's t distribution*/
        let x = (t + sqrt(t * t + v)) / (2.0 * sqrt(t * t + v))
        let prob = beta(a: v/2.0,b: v/2.0,x: x)
        return prob
    }

    func fSnedecorCDF(F : Double, d1 : Double, d2 : Double) -> Double{
        let x = (d1*F)/((d1*F)+d2)
        return beta(a: d1/2, b: d2/2, x: x)
    }

    func chiCDF(x : Double, k : Double) -> Double{
        let upper = incompleteGammaF(s: k/2, z: x/2)
        return upper/tgamma(k/2)
    }
}
