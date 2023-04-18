//
//  AMRAP.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation


// MARK: - AMRAP Model
struct AMRAPModel: ExerciseType, Codable, Hashable {
    var id: String = UUID().uuidString
    var amrapPosition: Int
    var workoutPosition: Int
    var timeLimit: Int
    var exercises: [ExerciseModel]
    var completed: Bool
    var roundsCompleted: Int
    var exercisesCompleted: Int
    var rpe: Int?
    var started: Bool
    var startTime: TimeInterval?
    
    func getCurrentExercise() -> ExerciseModel {
        let exerciseCount = exercises.count
        let currentIndex = exercisesCompleted % exerciseCount
        return exercises[currentIndex]
    }
}


