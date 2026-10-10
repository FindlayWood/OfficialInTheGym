//
//  JumpMeasureViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
import Combine


/// Jump height from flight time: **h = t² × 1.22625**, in metres, where t is
/// the time between the tagged take-off and landing. The constant is g / 8
/// (9.81 / 8): a body in the air for t seconds rises for t / 2 of them. Moved
/// from the app target as it was.
///
/// The times are valid only when both are tagged and take-off comes first.
/// A time of exactly zero counts as untagged, which is why the very first
/// frame of a video cannot be chosen.
struct JumpMeasureViewModel {
    
    // MARK: - Callbacks
    var timeValidationCallback: ((Bool) -> Void)?
    var heightCalculatedCallback:((Double) -> Void)?
    
    
    // MARK: - Properties
    var fileURL: URL!
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
