//
//  WeightEntry.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// One day's bodyweight in `Users/{uid}/WeightTracking/{yyyy-MM-dd}`, the
/// collection `createAccount` seeds with the signup weight.
///
/// **One entry per day**, keyed by `WeightDay.key(for:)`. Logging twice in a
/// day replaces the first, because a bodyweight log is a daily reading, not a
/// set of weigh-ins. `unit` is how it was entered, and kilograms is what it is.
public struct WeightEntry: Equatable, Identifiable, Sendable {
    public let id: String
    public let date: Date
    public let weightKilograms: Double
    public let unit: ProfileWeightUnit?

    public init(id: String, date: Date, weightKilograms: Double, unit: ProfileWeightUnit?) {
        self.id = id
        self.date = date
        self.weightKilograms = weightKilograms
        self.unit = unit
    }
}
