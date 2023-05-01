//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/04/2023.
//

import Foundation

struct WorkoutModel: Codable, Identifiable {
    var id: String
    var title: String
    var savedID: String? // if saved workout then id will link here
    var creatorID: String
    var assignedBy: String // the user ID of user who assigned this workout
    var isPrivate: Bool
    var completed: Bool
//    var clipData: [WorkoutClipModel]?
    var rpe: Int?
    var startDate: Date?
    var endDate: Date?
    var secondsToComplete: Int? // time to complete workout in seconds
    var workload: Int?
    var summary: String?
//    var exercises: [ExerciseModel]?
    var liveWorkout: Bool?
}
extension WorkoutModel {
    static let example = WorkoutModel(id: UUID().uuidString, title: "Example", creatorID: "", assignedBy: "", isPrivate: false, completed: false)
}

struct WorkoutCardModel: Identifiable {
    var id: String {
        workout.id
    }
    var workout: WorkoutModel
    var exercises: [ExerciseModel]
//    var clips: [WorkoutClipModel]?
}
