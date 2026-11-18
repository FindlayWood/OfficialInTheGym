//
//  CompletedWorkoutSession+TestHelpers.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation
@testable import MyDayKit

extension CompletedWorkoutSession {

    /// A finished session of workout `a`, started at `startedAt`. Durations and RPE are only what
    /// the test sets, so an average never includes a value the test did not mean.
    static func fixture(
        id: String = UUID().uuidString,
        templateId: String = "a",
        startedAt: Date = Date(timeIntervalSince1970: 1_800_000_000),
        endedAt: Date? = nil,
        durationSeconds: Int? = nil,
        rpe: Int? = nil,
        deletedAt: Date? = nil
    ) -> CompletedWorkoutSession {
        CompletedWorkoutSession(
            id: id,
            userId: "user",
            templateId: templateId,
            title: "Workout",
            assignedDate: startedAt,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds,
            rpe: rpe,
            setsCompleted: 10,
            setsTargeted: 10,
            exerciseRecords: [],
            deletedAt: deletedAt
        )
    }
}
