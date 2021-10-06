//
//  EMOM.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

/// EMOM - Every Minute On the Minute
/// A list of exercises and a time is given. Then these exercises are performed every minute on the minute until the time is up

class EMOM: WorkoutType {
    
    var exercise: String? = "EMOM"
    var exercises: [exercise]?
    var timeLimit: Int?
    var completed: Observable<Bool> = Observable<Bool>()
    var emom: Bool = true
    var rpe: Int?
    var started: Bool?
    var startTime: TimeInterval?
    
    init?(data : [String: AnyObject]) {
        self.timeLimit = data["timeLimit"] as? Int ?? 10
        self.completed.value = data["completed"] as? Bool ?? false
        self.emom = true
        self.exercise = "EMOM"
        self.started = data["started"] as? Bool ?? false
        self.startTime = data["startTime"] as? TimeInterval
        if let exs = data["exercises"] as? [[String:AnyObject]] {
            self.exercises = exs.map {(InTheGym.exercise(exercises: $0)!)}
        }
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snap = snapshot.value as? [String:AnyObject] else {return}
        self.exercise = "EMOM"
        self.timeLimit = snap["timeLimit"] as? Int ?? 20
        self.completed.value = snap["completed"] as? Bool ?? false
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
                      "emom": emom] as [String:AnyObject]
        
        if let completedBool = completed.value {
            object["completed"] = completedBool as AnyObject
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
