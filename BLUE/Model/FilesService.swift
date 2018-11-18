//
//  FilesService.swift
//  BLUE
//
//  Created by Karol Struniawski on 17/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation

class FilesService {
    
    static let path = Bundle.main.path(forResource: "test1", ofType: "txt")
    static var text = ""
    
    static private func readFromTxt(){
        do {
            text = try String(contentsOfFile: self.path!, encoding: String.Encoding.utf8)
        } catch  {
            print("error getting data")
        }
    }
    
    static func createModelFromFile(withHeaders : Bool, observationLabeled : Bool) -> KMNK{
        readFromTxt()
        
        var seperatedObservations = [String]()
        var seperatedValuesStr = [String]()
        var seperatedValues = [Double]()
        var i = 0
        var observations = [Observation]()
        var headers = [String]()
        let end = text.index(text.endIndex, offsetBy: -1)
        text = String(text[..<end])
        seperatedObservations = text.components(separatedBy: ";")
        
        seperatedObservations.forEach { (obs) in
            seperatedValuesStr = obs.components(separatedBy: ",")
            var observation = Observation()
            if withHeaders && i==0{
                headers = seperatedValuesStr
            }
            else{
                seperatedValues = seperatedValuesStr.compactMap{Double($0)}
                if observationLabeled && (i != 0){
                    observation.label = seperatedValuesStr[0]
                    seperatedValues.removeFirst()
                }
            observation.observationArray = seperatedValues
            observations.append(observation)
            }
            i=i+1
        }
        return KMNK(header: headers, k: seperatedValues.count, n: i, observations: observations, withHeaders: withHeaders, observationLabeled: observationLabeled)
    }
}
