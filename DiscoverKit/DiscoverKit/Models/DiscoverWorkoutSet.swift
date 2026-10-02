//
//  DiscoverWorkoutSet.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// One prescribed set. Units arrive as the strings MyDay stores them under —
/// "kg", "% of 1RM", "BW", "km" — which are already how they read.
public struct DiscoverWorkoutSet: Hashable, Sendable {
    public let reps: Int?
    public let weight: Double?
    public let weightUnit: String?
    /// Seconds, as MyDay stores every time.
    public let time: Int?
    public let distance: Double?
    public let distanceUnit: String?

    public init(reps: Int?, weight: Double?, weightUnit: String?, time: Int?, distance: Double?, distanceUnit: String?) {
        self.reps = reps
        self.weight = weight
        self.weightUnit = weightUnit
        self.time = time
        self.distance = distance
        self.distanceUnit = distanceUnit
    }

    /// `80 kg`, or a unit that labels the set alone — `BW`, `Max`.
    var loadText: String? {
        switch (weight, weightUnit) {
        case let (weight?, unit?): return "\(Self.number(weight)) \(unit)"
        case let (weight?, nil): return Self.number(weight)
        case let (nil, unit?): return unit
        case (nil, nil): return nil
        }
    }

    /// `45s`, `1m 30s`, `2m`.
    var timeText: String? {
        guard let time, time > 0 else { return nil }
        let minutes = time / 60, seconds = time % 60
        if minutes == 0 { return "\(seconds)s" }
        return seconds == 0 ? "\(minutes)m" : "\(minutes)m \(seconds)s"
    }

    var distanceText: String? {
        guard let distance, distance > 0 else { return nil }
        return "\(Self.number(distance)) \(distanceUnit ?? "")".trimmingCharacters(in: .whitespaces)
    }

    /// `80`, `22.5` — no trailing `.0` on a whole number.
    private static func number(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(value)
    }
}
