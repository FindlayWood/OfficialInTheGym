//
//  Double+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

extension Double {
    func convertMilesToKm() -> Double {
        return self * 1.60934
    }
    func convertPoundsToKG() -> Double {
        return self / 2.205
    }
}
