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

extension SessionSetInput {

    /// The prescription resolved into a performable set — exactly what
    /// "Complete Set" stores if the overlay is opened on an unlogged set and
    /// pressed without touching a field. `SessionSetPill`'s quick-complete tap
    /// is that press with the detour through the overlay removed, so it logs
    /// through here rather than reading `WorkoutSetModel` itself.
    ///
    /// **Must stay in step with `SessionSetDetailOverlay.resetInputsToTarget()`
    /// feeding `input`** — the same idea in two shapes, this one resolved and
    /// that one as editable text. A set logged either way has to come out
    /// identical, or the quick path and the long path disagree about what the
    /// user just did.
    static func target(for set: WorkoutSetModel) -> SessionSetInput {
        // The prescribed unit may be one the session cannot log (`% of 1RM`,
        // `Max`), and its number is then not a load at all — so the weight only
        // carries over when the unit survives `loggableDefault` unchanged.
        let unit = WeightUnit.loggableDefault(for: set.weightUnit)
        let keepsWeight = unit.carriesValue && (set.weightUnit == nil || set.weightUnit == unit)
        let weight = keepsWeight ? set.weight : nil

        return SessionSetInput(
            reps: set.reps,
            weight: weight,
            // A bodyweight set is stated by its unit alone; otherwise the unit
            // only means something once there is a weight.
            weightUnit: unit.carriesValue ? (weight != nil ? unit : nil) : unit,
            time: set.time,
            distance: set.distance,
            distanceUnit: set.distance != nil ? (set.distanceUnit ?? .metres) : nil,
            // All zeros is the builder's empty default, not a prescription.
            tempo: (set.tempo?.isEmpty ?? true) ? nil : set.tempo,
            // Never the prescribed note. It is the coach's instruction, and
            // storing it as performed would put words in the user's mouth.
            note: nil
        )
    }

    /// Whether anything here could stand as a performed set. Mirrors the
    /// overlay's `canLog`: bodyweight counts on its own, a bare note does not.
    var isLoggable: Bool {
        reps != nil
            || weight != nil
            || time != nil
            || distance != nil
            || weightUnit?.carriesValue == false
    }
}
