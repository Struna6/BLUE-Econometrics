//
//  Observation.swift
//  BLUE
//
//  Created by Karol Struniawski on 17/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation

struct Observation : Codable {
    var label : String?
    var observationArray = [Double]()
    
    init(){
    }
}
