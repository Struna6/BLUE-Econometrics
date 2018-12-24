//
//  OtherProtocols.swift
//  BLUE
//
//  Created by Karol Struniawski on 24/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation

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
