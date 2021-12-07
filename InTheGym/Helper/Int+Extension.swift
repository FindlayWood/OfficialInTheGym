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
    func convertToWorkoutTime() -> String {
        let formatter = DateComponentsFormatter()
        
        if self > 3600 {
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .abbreviated
        } else {
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .abbreviated
        }
        
        guard let timeString = formatter.string(from: TimeInterval(self)) else {return ""}
        
        return timeString
    }
}
