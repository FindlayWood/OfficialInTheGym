//
//  SessionSetInput.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/08/2026.
//

import Foundation

/// The values a user actually performed for a set, as entered in
/// `SessionSetDetailOverlay`.
///
/// `weightUnit` is chosen in the session rather than inherited from the
/// template — a set prescribed in `% of 1RM` or `Max` is performed at a real
/// load, and storing the prescription against that number renders it as
/// nonsense ("100 % of 1RM"). It is already resolved here: `nil` when there is
/// nothing to qualify, and `.bw` with no `weight` for a bodyweight set.
/// Time and distance units still come from the template.
struct SessionSetInput {
    let reps: Int?
    let weight: Double?
    let weightUnit: WeightUnit?
    let time: Int?
    let distance: Double?
}
