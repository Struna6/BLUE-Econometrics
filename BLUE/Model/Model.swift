////
////  Model.swift
////  BLUE
////
////  Created by Karol Struniawski on 17/11/2018.
////  Copyright © 2018 Karol Struniawski. All rights reserved.
////
//
//import Foundation
//
//class Model{
//    
//    private func createModelFromFile(withHeaders : Bool, observationLabeled : Bool, path : String) -> (header: [String]?, k : Int, n : Int, observations : [Observation]){
//        //let path = Bundle.main.path(forResource: "test1", ofType: "txt")
//        var text = ""
//        do {
//            text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
//        } catch  {
//            print("error getting data")
//        }
//        var seperatedObservations = [String]()
//        var seperatedValuesStr = [String]()
//        var seperatedValues = [Double]()
//        var i = 0
//        var observations = [Observation]()
//        var headers = [String]()
//        let end = text.index(text.endIndex, offsetBy: -1)
//        text = String(text[..<end])
//        seperatedObservations = text.components(separatedBy: ";")
//        
//        seperatedObservations.forEach { (obs) in
//            seperatedValuesStr = obs.components(separatedBy: ",")
//            var observation = Observation()
//            if withHeaders && i==0{
//                headers = seperatedValuesStr
//            }
//            else{
//                seperatedValues = seperatedValuesStr.compactMap{Double($0)}
//                if observationLabeled && (i != 0){
//                    observation.label = seperatedValuesStr[0]
//                    seperatedValues.removeFirst()
//                }
//                observation.observationArray = seperatedValues
//                observations.append(observation)
//            }
//            i=i+1
//        }
//        return (headers, seperatedValues.count - 1, i, observations)
//    }
//    
//    var header = [String]()
//    var k = 0, n = 0
//    var observations = [Observation]()
//    var withHeaders = false
//    var observationLabeled = false
//    var Ytmp = [Double]()
//    var Xtmp = [Double]()
//    private var i = 0
//    
//    init(withHeaders : Bool, observationLabeled : Bool, path : String){
//        let result = self.createModelFromFile(withHeaders: withHeaders, observationLabeled: observationLabeled, path: path)
//        self.header = result.header!
//        self.k = result.k
//        self.n = result.n
//        self.observations = result.observations
//        self.withHeaders = withHeaders
//        self.observationLabeled = observationLabeled
//        self.observations.forEach({ (obs) in
//            self.Ytmp.append(obs.observationArray[0])
//            obs.observationArray.forEach({ (el) in
//                if i != 0 {
//                    Xtmp.append(el)
//                }
//                i = i + 1
//            })
//            i = 0
//        })
//    }
//    
//    func prepare() -> (X: [[Double]],Y: [[Double]]){
//        var X = Array(repeating: Array(repeating: 0.0, count: self.k+1), count: self.n)
//        var Y = Array(repeating: Array(repeating: 0.0, count: 1), count: self.n)
//        var k = 0
//        for i in 0..<self.n{
//            X[i][0] = 1.0
//            for j in 1..<self.k+1{
//                X[i][j] = self.Xtmp[k]
//                Y[i][0] = self.Ytmp[i]
//                k=k+1
//            }
//        }
//        return (X,Y)
//    }
//}
