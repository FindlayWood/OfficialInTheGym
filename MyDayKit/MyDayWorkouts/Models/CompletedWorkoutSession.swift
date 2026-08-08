//
//  CompletedWorkoutSession.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import Foundation

/// A finished workout session as a document of its own.
///
/// The session also lives embedded in the day it was performed on
/// (`DailyWorkoutEntry.sessionRecord`), which answers "what is on my day". This
/// answers the two questions that shape cannot: what workouts have been done
/// across all users (analytics), and what workouts *this* user has done
/// (their history) — neither of which should mean reading every day document.
///
/// The same document is written to both
/// `WorkoutSessions/{id}` and `Users/{userId}/WorkoutSessions/{id}`.
public struct CompletedWorkoutSession: Identifiable, Codable {

    public let id: String
    /// Who performed the session — **not** who wrote the template. A
    /// coach-programmed workout is done by the athlete.
    public let userId: String
    public let templateId: String?
    public let title: String
    public let assignedDate: Date
    public let startedAt: Date
    public let endedAt: Date?
    public let durationSeconds: Int?
    public let rpe: Int?
    public let workload: Double?
    public let notes: String?
    public let setsCompleted: Int
    public let setsTargeted: Int
    public let exerciseRecords: [WorkoutExerciseRecord]

    /// Set on the analytics copy when the workout is removed from the day; the
    /// user's copy is deleted outright. A deletion that was never recorded
    /// cannot be reconstructed later, so it is recorded from the start.
    public let deletedAt: Date?

    public init(
        id: String,
        userId: String,
        templateId: String? = nil,
        title: String,
        assignedDate: Date,
        startedAt: Date,
        endedAt: Date? = nil,
        durationSeconds: Int? = nil,
        rpe: Int? = nil,
        workload: Double? = nil,
        notes: String? = nil,
        setsCompleted: Int,
        setsTargeted: Int,
        exerciseRecords: [WorkoutExerciseRecord],
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.templateId = templateId
        self.title = title
        self.assignedDate = assignedDate
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self.rpe = rpe
        self.workload = workload
        self.notes = notes
        self.setsCompleted = setsCompleted
        self.setsTargeted = setsTargeted
        self.exerciseRecords = exerciseRecords
        self.deletedAt = deletedAt
    }
}
