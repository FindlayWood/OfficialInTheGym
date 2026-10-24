//
//  ExerciseStatsSaveModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/11/2025.
//

import Foundation

/// One raw stats log — `Users/{uid}/ExerciseStats/{exerciseID}/RawLogs/{id}`.
///
/// **`muscleGroups` and `movementPatterns` are what this log was counted
/// under, fixed at completion.** The DailyTotals triggers split the log's
/// volume across them, and they used to look the exercise up in `Exercises`
/// every time they ran — on create, on every edit and on delete. Once an
/// exercise's muscle groups changed, deleting an old log took volume away
/// from groups it had never been added to, and some went negative. A log now
/// carries its own copy, and the triggers read that.
///
/// **Absent means unknown, not none.** Logs written before this, and sets
/// from templates built before `WorkoutExerciseModel` carried body parts,
/// have neither key, and the triggers fall back to looking the exercise up.
/// Never coerce a missing value to `[]` here: an empty list is read as
/// "counted under nothing" and the lookup is skipped.
public struct ExerciseStatsSaveModel: Codable {
    public let id: String
    public let exerciseID: String
    public let exerciseName: String
    public let dateComplete: Date
    public let reps: Int
    public let weight: Double
    public let time: Int
    public let muscleGroups: [String]?
    public let movementPatterns: [String]?
}
