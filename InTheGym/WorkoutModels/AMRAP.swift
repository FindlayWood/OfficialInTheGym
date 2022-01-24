//
//  AMRAP.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class AMRAP: WorkoutType {
    
    var exercise: String? = "AMRAP"
    var timeLimit: Int?
    var exercises: [exercise]?
    var completed: Observable<Bool> = Observable<Bool>()
    var roundsCompleted: Observable<Int> = Observable<Int>()
    var exercisesCompleted: Int?
    var amrap: Bool = true
    var rpe: Int?
    var started: Bool?
    var startTime: TimeInterval?
    
    
    init?(data: [String:AnyObject]) {
        self.timeLimit = data["timeLimit"] as? Int ?? 10
        self.completed.value = data["completed"] as? Bool ?? false
        self.roundsCompleted.value = data["roundsCompleted"] as? Int ?? 0
        self.amrap = true
        self.exercise = "AMRAP"
        self.exercisesCompleted = data["exercisesCompleted"] as? Int ?? 0
        self.started = data["started"] as? Bool ?? false
        self.startTime = data["startTime"] as? TimeInterval
        if let exs = data["exercises"] as? [[String:AnyObject]] {
            self.exercises = exs.map {(InTheGym.exercise(exercises: $0)!)}
        }
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snap = snapshot.value as? [String:AnyObject] else {return}
        self.exercise = "AMRAP"
        self.timeLimit = snap["timeLimit"] as? Int ?? 20
        self.completed.value = snap["completed"] as? Bool ?? false
        self.roundsCompleted.value = snap["roundsCompleted"] as? Int ?? 0
        self.exercisesCompleted = snap["exercisesCompleted"] as? Int ?? 0
        self.rpe = snap["rpe"] as? Int ?? 10
        self.started = snap["started"] as? Bool ?? false
        self.startTime = snap["startTime"] as? TimeInterval
        if let ex = snap["exercises"] as? [[String:AnyObject]]{
            self.exercises = ex.map { (InTheGym.exercise(exercises: $0)!)}
        }
    }
    
    
    func toObject() -> [String : AnyObject] {
        var object = ["exercise": exercise!,
                      "timeLimit": timeLimit!,
                      "amrap": amrap] as [String:AnyObject]
        
        if let completedBool = completed.value {
            object["completed"] = completedBool as AnyObject
        }
        if let rounds = roundsCompleted.value {
            object["roundsCompleted"] = rounds as AnyObject
        }
        if let exercisesCompleted = exercisesCompleted {
            object["exercisesCompleted"] = exercisesCompleted as AnyObject
        }
        if let rpe = rpe {
            object["rpe"] = rpe as AnyObject
        }
        if let started = started {
            object["started"] = started as AnyObject
        }
        if let startTime = startTime {
            object["startTime"] = startTime as AnyObject
        }
        if let exerciseData = exercises{
            object["exercises"] = exerciseData.map { ($0.toObject()) } as AnyObject
        }
        return object
    }
}

// MARK: - AMRAP Model
struct AMRAPModel: ExerciseType, Codable, Hashable {
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


