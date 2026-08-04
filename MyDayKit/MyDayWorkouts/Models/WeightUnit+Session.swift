//
//  WeightUnit+Session.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/08/2026.
//

import Foundation

extension WeightUnit {

    /// The units that state a load actually lifted. `% of 1RM`, `% of BW` and
    /// `Max` are prescriptions — relative to a number the session does not
    /// hold, or an instruction rather than a value — so they describe a target
    /// and are never stored against a performed set.
    static var loggable: [WeightUnit] { [.kg, .lbs, .bw] }

    /// `BW` and `Max` label a set on their own; every other unit qualifies a
    /// number. `MyDayWorkoutBuilderUnitsScreen` and `CompletedSetView` both
    /// suppress the value for these, so a number stored alongside one of them
    /// is never rendered anywhere.
    var carriesValue: Bool { self != .bw && self != .max }

    /// The unit to log against a set the template prescribes in `unit`. A
    /// prescription that is not itself loggable falls back to kg, so a set
    /// programmed as "80% of 1RM" is logged as the real load performed.
    static func loggableDefault(for unit: WeightUnit?) -> WeightUnit {
        guard let unit, loggable.contains(unit) else { return .kg }
        return unit
    }
}
