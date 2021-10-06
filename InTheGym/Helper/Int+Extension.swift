//
//  Int+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

extension Int {
    func convertToTime() -> String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
