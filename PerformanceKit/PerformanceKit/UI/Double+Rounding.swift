//
//  Double+Rounding.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

extension Double {

    /// PerformanceKit's copy of the app target's `rounded(toPlaces:)`.
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
