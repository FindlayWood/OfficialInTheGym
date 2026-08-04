//
//  SessionSetPillValue.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/08/2026.
//

import Foundation

/// One value rendered on a set pill.
///
/// A pill shows **at most two** of these. The frame is 72×88 and a set carrying
/// reps, weight, time and distance overflows it, clipping the top and bottom of
/// the text — so the list is capped in priority order rather than laid out to
/// fit whatever the set happens to hold.
struct SessionSetPillValue: Identifiable {

    let id: String
    let value: String
    let unit: String?

    /// At most two values, in priority order reps → weight → time → distance.
    ///
    /// Reads the record once the set is logged so the pill reflects what was
    /// actually performed. A logged set is read wholesale and never merged with
    /// the target: logging bodyweight clears the weight, and falling back
    /// per-field would resurrect the target's number against a `BW` unit.
    static func values(for set: WorkoutSetModel, record: WorkoutSetRecord?) -> [SessionSetPillValue] {
        let logged = (record?.isCompleted ?? false) ? record : nil

        let reps = logged.map(\.reps) ?? set.reps
        let weight = logged.map(\.weight) ?? set.weight
        let weightUnit = logged.map(\.weightUnit) ?? set.weightUnit
        let time = logged.map(\.time) ?? set.time
        let distance = logged.map(\.distance) ?? set.distance
        let distanceUnit = logged.map(\.distanceUnit) ?? set.distanceUnit

        var values: [SessionSetPillValue] = []

        if let reps {
            values.append(
                SessionSetPillValue(id: "reps", value: "\(reps)", unit: reps == 1 ? "rep" : "reps")
            )
        }

        if let weightUnit, !weightUnit.carriesValue {
            values.append(SessionSetPillValue(id: "weight", value: weightUnit.rawValue, unit: nil))
        } else if let weight {
            values.append(
                SessionSetPillValue(
                    id: "weight",
                    value: format(weight),
                    unit: weightUnit?.rawValue ?? "kg"
                )
            )
        }

        if let time {
            values.append(SessionSetPillValue(id: "time", value: formatTime(time), unit: nil))
        }

        if let distance {
            values.append(
                SessionSetPillValue(
                    id: "distance",
                    value: format(distance),
                    unit: distanceUnit?.rawValue ?? "m"
                )
            )
        }

        return Array(values.prefix(2))
    }

    // MARK: - Formatting

    private static func format(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))" : "\(v)"
    }

    private static func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m\(s)s" : "\(s)s"
    }
}
