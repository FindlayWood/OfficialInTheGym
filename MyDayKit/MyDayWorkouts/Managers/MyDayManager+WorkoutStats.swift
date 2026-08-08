//
//  MyDayManager+WorkoutStats.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import Foundation

extension MyDayManager {

    /// Write the raw stats log for a set performed in a workout session.
    ///
    /// This is the workout counterpart to the log `addNewCompletion` writes for
    /// a single exercise, and it lands in the same collection: work done inside
    /// a session and work logged on its own are the same work, and stats that
    /// only counted one of them would depend on how the user chose to record it.
    func saveWorkoutSetStats(_ stats: ExerciseStatsSaveModel) {
        Task {
            try await workoutStatsSaver.save(stats)
        }
    }

    /// Remove the raw stats log for a set that was un-logged or discarded with
    /// its session. Same path shape as `deleteCompletion` uses.
    func deleteWorkoutSetStats(exerciseId: String, logId: String) {
        Task {
            try await deleter.delete(at: "\(exerciseId)/RawLogs/\(logId)")
        }
    }

    /// Remove the raw logs for every set performed under a workout entry.
    ///
    /// Called when the entry itself goes away. `cancelSession()` discards its
    /// own logs, but taking a workout off the day is the other way a session's
    /// sets stop existing, and logs left behind would go on counting toward
    /// stats for a workout the user can no longer see.
    func deleteWorkoutStats(for entry: DailyWorkoutEntry) {
        guard let record = entry.sessionRecord else { return }
        for exerciseRecord in record.exerciseRecords {
            for set in exerciseRecord.setRecords where set.isCompleted {
                deleteWorkoutSetStats(
                    exerciseId: exerciseRecord.exerciseId,
                    logId: WorkoutSetRecord.statsLogId(sessionId: record.id, setId: set.id)
                )
            }
        }
    }
}
