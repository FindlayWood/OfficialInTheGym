//
//  LiveWorkoutModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Live Workout Model
/// This represents a live workout
/// A live workout is initially uploaded to database then converted to WorkoutModel
struct LiveWorkoutModel: Codable {
    
    var id: String
    var title: String
    var creatorID: String
    var createdBy: String
    var assignedTo: String
    var isPrivate: Bool
    var completed: Bool
    var liveWorkout: Bool
    var startTime: TimeInterval
}

// MARK: - Time Ordered Model
extension LiveWorkoutModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Workouts/\(assignedTo)"
    }
}
