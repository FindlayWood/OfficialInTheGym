//
//  MyDayWorkoutModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/04/2026.
//

import Foundation

public struct MyDayWorkoutModel: Identifiable, Codable {
    public let id: String
    let date: Date
    var exercises: [MyDayExerciseModel]
    var rpeEntry: RPEEntry?
}

// MARK: - Workout Template

public struct WorkoutTemplateModel: Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String?
    public let exercises: [WorkoutExerciseModel]
    public let createdBy: String
    public let isPublic: Bool
    public let tags: [String]?
    public let estimatedDuration: Int?
    public let difficulty: WorkoutDifficulty?
    public let createdAt: Date
    public let updatedAt: Date
}

// MARK: - Workout Exercise (blueprint)

public struct WorkoutExerciseModel: Identifiable, Codable {
    public let id: String
    public let exerciseId: String
    public let exerciseName: String
    public let exerciseCategory: ExerciseCategory
    public let orderIndex: Int
    public let sets: [WorkoutSetModel]
    public let restSeconds: Int?
    public let notes: String?

    public init(
        id: String,
        exerciseId: String,
        exerciseName: String,
        exerciseCategory: ExerciseCategory,
        orderIndex: Int,
        sets: [WorkoutSetModel],
        restSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.exerciseCategory = exerciseCategory
        self.orderIndex = orderIndex
        self.sets = sets
        self.restSeconds = restSeconds
        self.notes = notes
    }
}

// MARK: - Workout Set (per-set blueprint)

public struct WorkoutSetModel: Identifiable, Codable {
    public let id: String
    public let orderIndex: Int
    public let reps: Int?
    public let weight: Double?
    public let weightUnit: WeightUnit?
    public let time: Int?
    public let distance: Double?
    public let distanceUnit: DistanceUnit?
    public let tempo: Tempo?
    public let note: String?
    public let eachSide: Bool?

    public init(
        id: String,
        orderIndex: Int,
        reps: Int? = nil,
        weight: Double? = nil,
        weightUnit: WeightUnit? = nil,
        time: Int? = nil,
        distance: Double? = nil,
        distanceUnit: DistanceUnit? = nil,
        tempo: Tempo? = nil,
        note: String? = nil,
        eachSide: Bool? = nil
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.reps = reps
        self.weight = weight
        self.weightUnit = weightUnit
        self.time = time
        self.distance = distance
        self.distanceUnit = distanceUnit
        self.tempo = tempo
        self.note = note
        self.eachSide = eachSide
    }
}

// MARK: - Workout Session

public struct WorkoutSessionModel: Identifiable, Codable {
    public let id: String
    public let templateId: String?
    public let userId: String
    public let title: String
    public let startedAt: Date
    public let completedAt: Date?
    public let notes: String?
    public let status: WorkoutStatus
}

// MARK: - Workout Set Log

public struct WorkoutSetLog: Identifiable, Codable {
    public let id: String
    public let exerciseId: String
    public let userId: String
    public let workoutSessionId: String?
    public let orderIndex: Int
    public let reps: Int?
    public let weight: Double?
    public let weightUnit: WeightUnit?
    public let distance: Double?
    public let distanceUnit: DistanceUnit?
    public let time: Int?
    public let tempo: Tempo?
    public let note: String?
    public let eachSide: Bool?
    public let completedAt: Date
}

// MARK: - Enums

public enum WorkoutDifficulty: String, Codable {
    case beginner
    case intermediate
    case advanced
}

public enum WorkoutStatus: String, Codable {
    case inProgress
    case completed
    case abandoned
}
