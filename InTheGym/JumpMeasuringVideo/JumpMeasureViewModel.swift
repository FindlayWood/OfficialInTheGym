//
//  JumpMeasureViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine


struct JumpMeasureViewModel {
    
    // MARK: - Callbacks
    var timeValidationCallback: ((Bool) -> Void)?
    var heightCalculatedCallback:((Double) -> Void)?
    
    
    // MARK: - Properties
    var takeOffTime: Double = 0.0
    var landingTime: Double = 0.0
    
    let calulationConstant: Double = 1.22625
    
    // MARK: - Validation
    func areTimesValid() -> Bool {
        if takeOffTime == 0.0 || landingTime == 0.0 {
            return false
        } else if takeOffTime >= landingTime {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Actions
    func calculate() {
        heightCalculatedCallback?(calculateJumpHeight())
    }
    
    // MARK: - Calculation
    func calculateJumpHeight() -> Double {
        /// h = t^2 * 1.22625
        /// where h is the height
        /// and t is the time in the air
        
        let timeInAir = landingTime - takeOffTime
        let heightInMetres = pow(timeInAir, 2) * calulationConstant
        let heightInCM = heightInMetres * 100
        return heightInCM.rounded(toPlaces: 2)
        
    }
    
    // MARK: - Update Functions
    mutating func updateTakeOffTime(with newValue: Double) {
        takeOffTime = newValue
        timeValidationCallback?(areTimesValid())
    }
    mutating func updateLandingTime(with newValue: Double) {
        landingTime = newValue
        timeValidationCallback?(areTimesValid())
    }
}
