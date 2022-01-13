//
//  SavedWorkoutModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Saved Workout Model
/// This represents a saved workout
/// A saved workout cannot be completed - only for viewing
/// A saved workout may then be added to workouts
class SavedWorkoutModel: Codable, Hashable {
    var savedID: String
    var views: Int
    var downloads: Int
    var completions: Int
    var totalRPE: Int
    var totalTime: Int
    var createdBy: String
    var creatorID: String
    var title: String
    var exercises: [ExerciseModel]?
    var circuits: [CircuitModel]?
    var amraps: [AMRAPModel]?
    var emoms: [EMOMModel]?
    
    static func == (lhs: SavedWorkoutModel, rhs: SavedWorkoutModel) -> Bool {
        return lhs.savedID == rhs.savedID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(savedID)
    }
}
extension SavedWorkoutModel: FirebaseResource {
    static var path: String {
        return "SavedWorkouts"
    }
    var internalPath: String {
        return "SavedWorkouts/\(savedID)"
    }
}

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
    var exercises: [ExerciseModel]?
    var circuits: [CircuitModel]?
    var amraps: [AMRAPModel]?
    var emoms: [EMOMModel]?
}
extension NewSavedWorkoutModel: FirebaseInstance {
    var internalPath: String {
        return "SavedWorkouts/\(savedID)"
    }
}
