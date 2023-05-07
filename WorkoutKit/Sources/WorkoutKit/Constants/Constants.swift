//
//  File.swift
//  
//
//  Created by Findlay-Personal on 06/05/2023.
//

import Foundation

enum Constants {
    static func workoutPath(_ userID: String) -> String {
        "Users/\(userID)/Workouts"
    }
    static func exercisePath(_ workoutID: String, _ userID: String) -> String {
        "Users/\(userID)/Workouts/\(workoutID)/Exercises"
    }
}
