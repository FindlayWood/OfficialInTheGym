//
//  WorkoutSessionRecord.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/06/2026.
//

import Foundation

public struct WorkoutSessionRecord: Identifiable, Codable {
    public let id: String
    public let startedAt: Date
    public var endedAt: Date?
    public var rpe: Int?            // 1–10, set by user at session end
    public var workload: Double?    // duration (minutes) × rpe; nil until both are present
    public var exerciseRecords: [WorkoutExerciseRecord]

    public init(
        id: String,
        startedAt: Date,
        endedAt: Date? = nil,
        rpe: Int? = nil,
        workload: Double? = nil,
        exerciseRecords: [WorkoutExerciseRecord]
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.rpe = rpe
        self.workload = workload
        self.exerciseRecords = exerciseRecords
    }
}
