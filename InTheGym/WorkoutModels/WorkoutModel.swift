//
//  WorkoutModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Workout Model
/// Model representing a single workout
/// Important Variables
/// -----> assignedTo = the id of the user assigned this workout - could be self id or ither user id
/// -----> savedID = the ID of where the workout is saved - all workouts are stored in the savedWorkouts ref - EXCEPT Live Workouts 
/// -----> workoutID = the ID of this specific workout - different from savedID as you may do the same saved workout more than once
class WorkoutModel: Codable, Hashable {
    var title: String
    var id: String
    var savedID: String?
    var creatorID: String
    var assignedTo: String
    var isPrivate: Bool
    var completed: Bool
    var clipData: [WorkoutClipModel]?
    var score: Int?
    var startTime: TimeInterval?
    var timeToComplete: Int?
    var workload: Int?
    var summary: String?
    var exercises: [ExerciseModel]?
    var liveWorkout: Bool?
//    var id: String {
//        return workoutID
//    }
    
    init(newSavedModel: NewSavedWorkoutModel, assignTo: String) {
        title = newSavedModel.title
        id = UUID().uuidString
        savedID = newSavedModel.savedID
        creatorID = newSavedModel.creatorID
        assignedTo = assignTo
        isPrivate = newSavedModel.isPrivate
        completed = false
        exercises = newSavedModel.exercises
    }
    init(savedModel: SavedWorkoutModel, assignTo: String) {
        title = savedModel.title
        id = UUID().uuidString
        savedID = savedModel.id
        creatorID = savedModel.creatorID
        assignedTo = assignTo
        isPrivate = savedModel.isPrivate
        completed = false
        exercises = savedModel.exercises
    }
    
    init(liveModel: LiveWorkoutModel) {
        title = liveModel.title
        id = liveModel.id
        creatorID = liveModel.creatorID
        assignedTo = liveModel.assignedTo
        isPrivate = liveModel.isPrivate
        completed = liveModel.completed
        liveWorkout = liveModel.liveWorkout
        startTime = Date().timeIntervalSince1970
    }
    
    static func == (lhs: WorkoutModel, rhs: WorkoutModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension WorkoutModel {
    func totalExerciseCount() -> Int {
        var totalExerciseCount = 0
        totalExerciseCount += exercises?.count ?? 0
        return totalExerciseCount
    }
    func averageRPE() -> Double {
        guard let exercises = exercises else {return 0.0}
        let scores = exercises.map( { $0.rpe ?? 0 })
        let totalScore = scores.reduce(0, +)
        let averageRPE = Double(totalScore) / Double(exercises.count)
        return averageRPE.rounded(toPlaces: 1)
    }
    func getWorkload() -> Int {
        guard let timeToComplete = timeToComplete,
              let rpe = score
        else {return 0}
        let minutes = timeToComplete / 60
        return minutes * rpe
    }
}
extension WorkoutModel: FirebaseModel {
    static var path: String {
        return "Workouts/\(UserDefaults.currentUser.uid)"
    }
}
extension WorkoutModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Workouts/\(assignedTo)"
    }
}
extension WorkoutModel {
    func getTimeUpdatePoint() -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: startTime, path: "Workouts/\(UserDefaults.currentUser.uid)/\(id)/startTime")
    }
    func getRPEUploadPoint(_ exercise: ExerciseModel) -> FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: exercise.rpe, path: "Workouts/\(UserDefaults.currentUser.uid)/\(id)/exercises/\(exercise.workoutPosition)/rpe")
    }
    func getSetUploadPoint(_ exercise: ExerciseModel, setNumber: Int) -> FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: true, path: "Workouts/\(UserDefaults.currentUser.uid)/\(id)/exercises/\(exercise.workoutPosition)/completedSets/\(setNumber)")
    }
}
