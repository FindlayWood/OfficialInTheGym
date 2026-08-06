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
/// `distanceUnit` is chosen in the session for the same reason: a 400 m target
/// may well be logged as 0.5 km. `time` carries no unit because the model has
/// none — it is always a second count, converted from whatever
/// `SessionTimeUnit` the user entered it in.
///
/// `tempo` and `note` are carried here for the same reason as the measures:
/// they describe the set as performed. The template's own tempo and note stay
/// untouched — they are the prescription, and the workout is reused.
struct SessionSetInput {
    let reps: Int?
    let weight: Double?
    let weightUnit: WeightUnit?
    let time: Int?
    let distance: Double?
    let distanceUnit: DistanceUnit?
    let tempo: Tempo?
    let note: String?
}
