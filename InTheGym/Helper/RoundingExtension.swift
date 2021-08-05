//
//  RoundingExtension.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

extension Double {
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
