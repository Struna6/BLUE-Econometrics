//
//  Model.swift
//  BLUE
//
//  Created by Karol Struniawski on 17/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation

class Model{
    var header : [String]?
    var k, n : Int
    var observations = [Observation]()
    let withHeaders : Bool
    let observationLabeled : Bool
    var Ytmp = [Double]()
    var Xtmp = [Double]()
    private var i = 0
    
    init(header: [String]?, k : Int, n : Int, observations : [Observation], withHeaders : Bool, observationLabeled : Bool){
        self.header = header
        self.k = k-1
        self.n = n
        self.observations = observations
        self.withHeaders = withHeaders
        self.observationLabeled = observationLabeled
        self.observations.forEach({ (obs) in
            self.Ytmp.append(obs.observationArray[0])
            obs.observationArray.forEach({ (el) in
                if i != 0 {
                    Xtmp.append(el)
                }
                i = i + 1
            })
            i = 0
        })
    }
    
    init(){
        k = 0
        n = 0
        withHeaders = false
        observationLabeled = false
    }
    
    func prepare() -> (X: [[Double]],Y: [[Double]]){
        var X = Array(repeating: Array(repeating: 0.0, count: self.k+1), count: self.n)
        var Y = Array(repeating: Array(repeating: 0.0, count: 1), count: self.n)
        var k = 0
        for i in 0..<self.n{
            X[i][0] = 1.0
            for j in 1..<self.k+1{
                X[i][j] = self.Xtmp[k]
                Y[i][0] = self.Ytmp[i]
                k=k+1
            }
        }
        return (X,Y)
    }
}
