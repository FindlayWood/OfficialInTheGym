//
//  WorkoutExerciseRecord.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/06/2026.
//

import Foundation

public struct WorkoutExerciseRecord: Identifiable, Codable {
    public let id: String           // matches WorkoutExerciseModel.id
    public let exerciseId: String
    public let exerciseName: String
    public var rpe: Int?
    public var setRecords: [WorkoutSetRecord]

    public init(id: String, exerciseId: String, exerciseName: String, rpe: Int? = nil, setRecords: [WorkoutSetRecord]) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.rpe = rpe
        self.setRecords = setRecords
    }
}
