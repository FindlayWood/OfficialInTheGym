//
//  JumpMeasurement.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// How a jump height is shown. Stored heights are always centimetres.
///
/// The conversion factor is the app target's `convertCMtoInches()`.
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

    /// A stored height, in centimetres, in this unit.
    func display(centimetres value: Double) -> Double {
        switch self {
        case .cm: value
        case .inches: Self.inches(fromCentimetres: value)
        }
    }
}
