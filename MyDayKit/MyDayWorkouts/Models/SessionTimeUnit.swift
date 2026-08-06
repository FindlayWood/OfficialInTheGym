//
//  SessionTimeUnit.swift
//  MyDayKit
//
//  Created by Findlay Wood on 06/08/2026.
//

import Foundation

/// The unit a time is *entered* in on `SessionSetValueSheet`.
///
/// **Never persisted.** `WorkoutSetModel.time` and `WorkoutSetRecord.time` are
/// both a plain second count, exactly as `MyDayWorkoutBuilderTimeScreen` stores
/// them — that screen has no unit at all, it steps a total in seconds and draws
/// it as `Xm Ys`. This only decides what the number on the pad means, so "3"
/// under `min` becomes 180 before it is stored. Adding a real unit to the model
/// would fork two screens that currently agree.
enum SessionTimeUnit: String, CaseIterable, Identifiable {
    case seconds = "sec"
    case minutes = "min"

    var id: String { rawValue }

    var fullName: String {
        switch self {
        case .seconds: return "Seconds"
        case .minutes: return "Minutes"
        }
    }

    /// Whole numbers only in both units. A decimal minute is the classic way to
    /// get this wrong — "1.30 min" reads as 1m 30s but means 78 seconds — so
    /// 90 seconds is entered as 90 `sec`, not 1.5 `min`.
    func seconds(from value: Int) -> Int {
        switch self {
        case .seconds: return value
        case .minutes: return value * 60
        }
    }

    /// The unit a stored second count is best shown in when seeding the pad: a
    /// clean number of minutes seeds as minutes, anything else as seconds.
    static func seeding(for totalSeconds: Int) -> (unit: SessionTimeUnit, value: Int) {
        if totalSeconds >= 60 && totalSeconds % 60 == 0 {
            return (.minutes, totalSeconds / 60)
        }
        return (.seconds, totalSeconds)
    }

    /// A second count as `1m 30s` / `45s` — the same shape
    /// `MyDayWorkoutBuilderTimeScreen` draws, so a time reads identically
    /// wherever it appears.
    static func display(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return minutes > 0 ? "\(minutes)m \(seconds)s" : "\(seconds)s"
    }
}
