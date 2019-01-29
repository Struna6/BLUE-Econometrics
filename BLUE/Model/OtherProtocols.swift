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
import Lottie

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
        let n2 = Int(floor(Double(numbers.count)*n))
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
    func incompleteGammaF(s : Double, z : Double) -> Double
    func chiCDF(x : Double, k : Double) -> Double
    func betaValue(x : Double, a : Double, b : Double) -> Double
    func betaIncomplete(x : Double, a : Double, b : Double) -> Double
    func betaComplete(a : Double, b : Double) -> Double
    func betaRegularizedIncomplete(x : Double, a : Double, b : Double) -> Double
    func FSnedeccorCDF(f : Double, d1 : Double, d2 : Double) -> Double
    func TStudentCDF(t : Double, v : Double) -> Double
    func normalValue(x: Double) -> Double
    func normalCDF(x: Double) -> Double
    func normalInverseCDF(p : Double) -> Double
}

extension Statisticable{
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
    
    func chiCDF(x : Double, k : Double) -> Double{
        print("calculating")
        let upper = incompleteGammaF(s: k/2, z: x/2)
        return upper/tgamma(k/2)
    }
    
    func betaValue(x : Double, a : Double, b : Double) -> Double{
        return pow(x, (a - 1)) * pow((1 - x), (b - 1))
    }
    
    func betaIncomplete(x : Double, a : Double, b : Double) -> Double{
        let width = (x - 0) / 200
        var result : Double = 0
        var i : Double = 0
        while i < x{
            result = result + (betaValue(x: i, a: a, b: b) * width)
            i = i + width
        }
        return result
    }
    
    func betaComplete(a : Double, b : Double) -> Double{
        return (tgamma(a)*tgamma(b))/tgamma(a+b)
    }
    
    func betaRegularizedIncomplete(x : Double, a : Double, b : Double) -> Double{
        return betaIncomplete(x: x, a: a, b: b)/betaComplete(a: a, b: b)
    }
    
    func FSnedeccorCDF(f : Double, d1 : Double, d2 : Double) -> Double{
        let x = (d1*f)/((d1*f)+d2)
        return betaRegularizedIncomplete(x: x, a: d1/2, b: d2/2)
    }
    
    func TStudentCDF(t : Double, v : Double) -> Double{
        let x = v/((t*t) + v)
        return 1 - 0.5*betaRegularizedIncomplete(x: x, a: v/2, b: 0.5)
    }
    
    func normalValue(x: Double) -> Double{
        return exp(-(x*x)/2)
    }
    
    func normalCDF(x: Double) -> Double{
        if x < -5{
            return 0
        }
        let width = (x + 5) / 200
        var result : Double = 0
        var i : Double = -5
        while i < x{
            result = result + (normalValue(x: i)*width)
            i = i + width
        }
        return result / (sqrt(2*Double.pi))
    }
    
    func normalInverseCDF(p : Double) -> Double{
        if p < 0 || p > 1{
            return Double.nan
        }
        let width : Double = 16 / 1000
        var i : Double = -8
        var result : Double = 0
        let pTmp = p * sqrt(2*Double.pi)
        while true{
            result = result + (normalValue(x: i)*width)
            if result >= pTmp{
                return i
            }
            i = i + width
        }
    }
}


protocol PlayableLoadingScreen{
    func playLoadingAsync(tasksToDoAsync: @escaping () -> Void, tasksToMainBack: @escaping () -> Void)
}

extension PlayableLoadingScreen where Self : ViewController{
    func playLoadingAsync(tasksToDoAsync: @escaping () -> Void, tasksToMainBack: @escaping () -> Void){
        let animationView = LOTAnimationView(name: "loading")
        animationView.loopAnimation = true
        animationView.sizeToFit()
        self.view.addSubview(animationView)
        animationView.frame = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 500, height: 500)
        animationView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        animationView.play()
        Dispatch.DispatchQueue.global(qos: .background).async {
            tasksToDoAsync()
            DispatchQueue.main.async {
                tasksToMainBack()
                animationView.stop()
                animationView.removeFromSuperview()
            }
        }
    }
}

