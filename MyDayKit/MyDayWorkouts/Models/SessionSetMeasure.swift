//
//  SessionSetMeasure.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/08/2026.
//

import Foundation

/// Which value of a set is being entered in `SessionSetValueSheet`.
enum SessionSetMeasure: String, Identifiable {
    case reps
    case weight
    case time
    case distance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .reps:     return "Reps"
        case .weight:   return "Weight"
        case .time:     return "Time"
        case .distance: return "Distance"
        }
    }

    var icon: String {
        switch self {
        case .reps:     return "repeat"
        case .weight:   return "scalemass"
        case .time:     return "clock"
        case .distance: return "ruler"
        }
    }

    /// Reps and time are whole numbers; weight and distance are not.
    var allowsDecimal: Bool {
        switch self {
        case .reps, .time:      return false
        case .weight, .distance: return true
        }
    }
}
