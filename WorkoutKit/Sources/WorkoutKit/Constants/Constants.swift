//
//  File.swift
//  
//
//  Created by Findlay-Personal on 06/05/2023.
//

import Foundation

enum Constants {
    static func workoutsPath(_ userID: String) -> String {
//        "Users/\(userID)/Workouts"
        "Workouts/\(userID)"
    }
    static func workoutPath(_ userID: String, workoutID: String) -> String {
        "Workouts/\(userID)/\(workoutID)"
    }
    static func newWorkoutPath(_ userID: String, workoutID: String) -> String {
        "Users/\(userID)/Workouts/\(workoutID)"
    }
    static func exercisePath(_ workoutID: String, _ userID: String) -> String {
        "Users/\(userID)/Workouts/\(workoutID)/Exercises"
    }
    static func newExercisePath(_ workoutID: String, _ userID: String, exerciseID: String) -> String {
        "Users/\(userID)/Workouts/\(workoutID)/Exercises/\(exerciseID)"
    }
}
