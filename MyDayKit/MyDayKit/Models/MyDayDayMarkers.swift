//
//  MyDayDayMarkers.swift
//  MyDayKit
//
//  Created by Findlay Wood on 17/10/2026.
//

import Foundation

/// What a day in the date strip has on it: a wellness check-in, recorded work, and a day RPE.
/// Each is a yes / no read straight off the day document, so the strip can say which days are
/// complete without the user opening every one of them.
///
/// **Recorded work counts a set logged inside a workout, not just an exercise logged on its
/// own.** Work done in a session and work logged on its own are the same work — a marker that
/// lit for one and not the other would depend on how the user happened to record it, the same
/// rule the stats raw logs follow. A workout that is only *on* the day, planned or started with
/// nothing logged, is not recorded work.
struct MyDayDayMarkers: Equatable {
    let hasCheckIn: Bool
    let hasExercise: Bool
    let hasRPE: Bool

    static let none = MyDayDayMarkers(hasCheckIn: false, hasExercise: false, hasRPE: false)

    var isEmpty: Bool { !hasCheckIn && !hasExercise && !hasRPE }

    init(hasCheckIn: Bool, hasExercise: Bool, hasRPE: Bool) {
        self.hasCheckIn = hasCheckIn
        self.hasExercise = hasExercise
        self.hasRPE = hasRPE
    }

    init(day: MyDayFullDayModel) {
        let loggedExercise = day.exercises.contains { !$0.completions.isEmpty }
        let loggedWorkoutSet = day.workouts.contains { entry in
            entry.sessionRecord?.exerciseRecords.contains { exercise in
                exercise.setRecords.contains { $0.isCompleted }
            } ?? false
        }
        self.init(
            hasCheckIn: day.wellnessEntry != nil,
            hasExercise: loggedExercise || loggedWorkoutSet,
            hasRPE: day.rpeEntry != nil
        )
    }
}
