//
//  SavedWorkoutModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Saved Workout Model
/// This represents a saved workout
/// A saved workout cannot be completed - only for viewing
/// A saved workout may then be added to workouts
class SavedWorkoutModel: Codable, Hashable {
    var id: String
    var views: Int
    var downloads: Int
    var completions: Int
    var totalRPE: Int
    var totalTime: Int
    var createdBy: String
    var creatorID: String
    var timeCreated: TimeInterval?
    var title: String
    var isPrivate: Bool
    var exercises: [ExerciseModel]?
    var circuits: [CircuitModel]?
    var amraps: [AMRAPModel]?
    var emoms: [EMOMModel]?
    
    init(title: String, isPrivate: Bool, exercises: [ExerciseModel], circuits: [CircuitModel], amraps: [AMRAPModel], emoms: [EMOMModel]) {
        self.id = UUID().uuidString
        self.views = 0
        self.downloads = 0
        self.completions = 0
        self.totalRPE = 0
        self.totalTime = 0
        self.createdBy = FirebaseAuthManager.currentlyLoggedInUser.username
        self.creatorID = FirebaseAuthManager.currentlyLoggedInUser.uid
        self.timeCreated = Date().timeIntervalSince1970
        self.title = title
        self.isPrivate = isPrivate
        self.exercises = exercises
        self.circuits = circuits
        self.amraps = amraps
        self.emoms = emoms
    }
    
    static func == (lhs: SavedWorkoutModel, rhs: SavedWorkoutModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Saved Model Functions
extension SavedWorkoutModel {
    func averageTime() -> String {
        guard completions > 0 else { return "0" }
        return (totalTime / completions).convertToWorkoutTime()
    }
    func averageScore() -> Double {
        guard completions > 0 else { return 0 }
        return Double(totalRPE / completions).rounded(toPlaces: 1)
    }
    func totalExerciseCount() -> Int {
        var totalExerciseCount = 0
        totalExerciseCount += exercises?.count ?? 0
        totalExerciseCount += circuits?.count ?? 0
        totalExerciseCount += emoms?.count ?? 0
        totalExerciseCount += amraps?.count ?? 0
        return totalExerciseCount
    }
}
// MARK: - Multi Upload Points
extension SavedWorkoutModel {
    func viewUploadPoint() -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: ServerValue.increment(1),
                                            path: "SavedWorkouts/\(id)/views")
    }
    func downloadUploadPoint() -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: ServerValue.increment(1),
                                            path: "SavedWorkouts/\(id)/downloads")
    }
}

// MARK: - Firebase Resource
extension SavedWorkoutModel: FirebaseModel {
    static var path: String {
        return "SavedWorkouts"
    }
}
extension SavedWorkoutModel: FirebaseTimeOrderedModel {
    var internalPath: String { 
        return "SavedWorkouts"
    }
}

// MARK: - New Saved Workout Struct
struct NewSavedWorkoutModel: Codable {
    var savedID: String
    var views: Int
    var downloads: Int
    var completions: Int
    var totalRPE: Int
    var totalTime: Int
    var createdBy: String
    var creatorID: String
    var title: String
    var isPrivate: Bool
    var exercises: [ExerciseModel]?
    var circuits: [CircuitModel]?
    var amraps: [AMRAPModel]?
    var emoms: [EMOMModel]?
    
    init(title: String, isPrivate: Bool, exercises: [ExerciseModel], circuits: [CircuitModel], amraps: [AMRAPModel], emoms: [EMOMModel]) {
        self.savedID = UUID().uuidString
        self.views = 0
        self.downloads = 0
        self.completions = 0
        self.totalRPE = 0
        self.totalTime = 0
        self.createdBy = FirebaseAuthManager.currentlyLoggedInUser.username
        self.creatorID = FirebaseAuthManager.currentlyLoggedInUser.uid
        self.title = title
        self.isPrivate = isPrivate
        self.exercises = exercises
        self.circuits = circuits
        self.amraps = amraps
        self.emoms = emoms
    }
}
extension NewSavedWorkoutModel: FirebaseInstance {
    var internalPath: String {
        return "SavedWorkouts/\(savedID)"
    }
}


