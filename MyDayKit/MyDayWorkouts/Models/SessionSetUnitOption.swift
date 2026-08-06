//
//  SessionSetUnitOption.swift
//  MyDayKit
//
//  Created by Findlay Wood on 06/08/2026.
//

import Foundation

/// One button in `SessionSetValueSheet`'s unit picker, flattened out of
/// whichever unit type the measure actually uses.
///
/// Weight, distance and time each have their own enum and none of them share a
/// protocol, but the picker they need is the same picker. This is what lets the
/// sheet draw one, rather than three near-identical rows.
struct SessionSetUnitOption: Identifiable, Hashable {

    let id: String

    /// The short form on the button — "kg", "km", "min".
    let label: String

    /// The word underneath, mirroring `MyDayWorkoutBuilderDistanceScreen`'s
    /// unit buttons. `nil` leaves the button label-only, which is how the
    /// weight picker has always looked.
    let fullName: String?

    /// False for units that state a set on their own — `BW`, `Max`. Selecting
    /// one clears the entered value and hides the number pad, because there is
    /// nothing left to type.
    let carriesValue: Bool

    init(id: String, label: String, fullName: String? = nil, carriesValue: Bool = true) {
        self.id = id
        self.label = label
        self.fullName = fullName
        self.carriesValue = carriesValue
    }
}
