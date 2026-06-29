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
    public var setRecords: [WorkoutSetRecord]

    public init(id: String, exerciseId: String, exerciseName: String, setRecords: [WorkoutSetRecord]) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.setRecords = setRecords
    }
}
