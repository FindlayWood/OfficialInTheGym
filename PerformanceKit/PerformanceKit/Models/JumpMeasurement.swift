//
//  JumpMeasurement.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// How a jump height is shown. Stored heights are always centimetres.
///
/// PerformanceKit's copy of the app target's `JumpMeasurement`, which stays
/// behind for CMJ. The conversion factors are the app's
/// `convertCMtoInches()` / `convertInchestoCM()`.
enum JumpMeasurement: CaseIterable {
    case cm
    case inches

    var title: String {
        switch self {
        case .cm: "cm"
        case .inches: "in"
        }
    }

    static func inches(fromCentimetres value: Double) -> Double {
        value * 0.393701
    }

    static func centimetres(fromInches value: Double) -> Double {
        value * 2.54
    }
}
