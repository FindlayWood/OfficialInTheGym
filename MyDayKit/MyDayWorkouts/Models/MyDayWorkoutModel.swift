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

struct WorkoutTemplateModel: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let exercises: [WorkoutExerciseModel]
    let createdBy: String
    let isPublic: Bool
    let tags: [String]?
    let estimatedDuration: Int?
    let difficulty: WorkoutDifficulty?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Workout Exercise (blueprint)

struct WorkoutExerciseModel: Identifiable, Codable {
    let id: String
    let exerciseId: String
    let orderIndex: Int
    let targetSets: Int
    let targetReps: Int?
    let targetWeight: Double?
    let targetWeightUnit: WeightUnit?
    let targetTime: Int?
    let targetDistance: Double?
    let targetDistanceUnit: DistanceUnit?
    let restSeconds: Int?
    let notes: String?
    let eachSide: Bool?
    let tempo: Tempo?
}

// MARK: - Workout Session

struct WorkoutSessionModel: Identifiable, Codable {
    let id: String
    let templateId: String?
    let userId: String
    let title: String
    let startedAt: Date
    let completedAt: Date?
    let notes: String?
    let status: WorkoutStatus
}

// MARK: - Workout Set Log

struct WorkoutSetLog: Identifiable, Codable {
    let id: String
    let exerciseId: String
    let userId: String
    let workoutSessionId: String?
    let orderIndex: Int
    let reps: Int?
    let weight: Double?
    let weightUnit: WeightUnit?
    let distance: Double?
    let distanceUnit: DistanceUnit?
    let time: Int?
    let tempo: Tempo?
    let note: String?
    let eachSide: Bool?
    let completedAt: Date
}

// MARK: - Enums

enum WorkoutDifficulty: String, Codable {
    case beginner
    case intermediate
    case advanced
}

enum WorkoutStatus: String, Codable {
    case inProgress
    case completed
    case abandoned
}
