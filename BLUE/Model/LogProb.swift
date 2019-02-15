//
//  LogProb.swift
//  BLUE
//
//  Created by Karol Struniawski on 15/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import Foundation

protocol LogProb{
    func isYBinnary() -> Bool
}

extension LogProb where Self==Model{    
    func isYBinnary() -> Bool{
        for i in 0..<n{
            if flatY[i] != 0.0 && flatY[i] != 1.0{
                return false
            }
        }
        return true
    }
}
