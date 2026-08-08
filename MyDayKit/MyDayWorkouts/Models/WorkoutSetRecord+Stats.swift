//
//  WorkoutSetRecord+Stats.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import Foundation

extension WorkoutSetRecord {

    /// The raw stats log for this performed set.
    ///
    /// A set performed inside a workout session is the same event as an
    /// exercise logged on its own, so it produces the same
    /// `ExerciseStatsSaveModel` and is written to the same
    /// `Users/{uid}/ExerciseStats/{exerciseID}/RawLogs` collection. Keep this in
    /// step with `ExerciseCompletions.getStats()` — anything either one records
    /// that the other does not becomes a gap in the stats that depends on how
    /// the user happened to log the work.
    func getStats(exerciseId: String, exerciseName: String, sessionId: String) -> ExerciseStatsSaveModel {
        ExerciseStatsSaveModel(
            id: WorkoutSetRecord.statsLogId(sessionId: sessionId, setId: id),
            exerciseID: exerciseId,
            exerciseName: exerciseName,
            dateComplete: completedAt ?? Date(),
            reps: reps ?? 0,
            weight: WeightUnit.kilograms(weight, unit: weightUnit),
            time: time ?? 0
        )
    }

    /// The document id for a set's raw log.
    ///
    /// **The set id alone will not do.** Set ids are only unique within an
    /// exercise, and a template is reused on later days with the *same* ids —
    /// so keying the log by set id alone would have next week's session
    /// overwrite this week's logs. The session id is regenerated for every
    /// session (including a restart after a cancel), which makes the pair
    /// unique within an exercise's `RawLogs` collection.
    ///
    /// It is derived rather than stored so that un-logging a set, or cancelling
    /// the session, can address the log it already wrote.
    static func statsLogId(sessionId: String, setId: String) -> String {
        "\(sessionId)-\(setId)"
    }
}
