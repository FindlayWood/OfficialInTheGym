//
//  Exercise.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import CodableFirebase


class exercise: WorkoutType, Codable {
    
    var exercise: String?
    var reps: Int?
    var repString: String?
    var sets: Int?
    var setString: String?
    var type: bodyType?
    var weight: String?
    var repStringArray: [String]?
    var repArray: [Int]?
    var weightArray: [String]?
    var completedSets: [Bool]?
    var rpe: String?
    var note: String?
    var time: [Int]?
    var distance: [String]?
    var restTime: [Int]?
    
    init?(){}
    
    init?(exercises: [String:AnyObject]){
        self.exercise = exercises["exercise"] as? String
        self.reps = exercises["reps"] as? Int
        self.repArray = exercises["reps"] as? [Int]
        self.repString = exercises["reps"] as? String
        self.repStringArray = exercises["reps"] as? [String]
        self.sets = exercises["sets"] as? Int
        self.setString = exercises["sets"] as? String
        self.type = TransformWorkout.stringToBodyType(from: exercises["type"] as? String ?? "UB")
        self.weight = exercises["weight"] as? String
        self.weightArray = exercises["weight"] as? [String]
        self.completedSets = exercises["completedSets"] as? [Bool]
        self.rpe = exercises["rpe"] as? String
        self.note = exercises["note"] as? String
        self.time = exercises["time"] as? [Int]
        self.distance = exercises["distance"] as? [String]
        self.restTime = exercises["restTime"] as? [Int]

    }
    
    func toObject() -> [String:AnyObject]{
        var object = ["exercise": exercise!,
                      "type": TransformWorkout.bodyTypeToString(from: type!)] as [String : AnyObject]
        
        if let completedsets = completedSets{
            object["completedSets"] = completedsets as AnyObject
        }
        if weight != nil{
            object["weight"] = weight! as AnyObject
        }
        if let weightArray = weightArray{
            object["weight"] = weightArray as AnyObject
        }
        
        if let rpe = rpe{
            object["rpe"] = rpe as AnyObject
        }
        if note != nil{
            object["note"] = note! as AnyObject
        }
        
        if let reps = reps {
            object["reps"] = reps as AnyObject
        }
        if let repArray = repArray{
            object["reps"] = repArray as AnyObject
        }
        if let repString = repString {
            object["reps"] = repString as AnyObject
        }
        
        if let repStringArray = repStringArray {
            object["reps"] = repStringArray as AnyObject
        }
        
        if let set = sets {
            object["sets"] = set as AnyObject
        }
        
        if let set = setString {
            object["sets"] = set as AnyObject
        }
        if let time = time {
            object["time"] = time as AnyObject
        }
        if let distance = distance {
            object["time"] = distance as AnyObject
        }
        if let resTime = restTime {
            object["time"] = resTime as AnyObject
        }
        return object
    }
}

//enum ExerciseType: String, Codable {
//    case regularExercise = "regularExercise"
//    case emom = "emom"
//}


struct ExerciseModel: ExerciseType, Codable, Hashable {
    
    var id: String = UUID().uuidString
    var workoutPosition: Int
    var exercise: String
    var reps: [Int]?
    var weight: [String]?
    var type: bodyType
    var completedSets: [Bool]?
    var sets: Int
    var rpe: Int?
    var time: [Int]?
    var distance: [String]?
    var restTime: [Int]?
    var note: String?
    
    init(exercise: String, type: bodyType) {
        self.workoutPosition = 0
        self.exercise = exercise
        self.reps = [Int]()
        self.weight = [String]()
        self.type = type
        self.completedSets = [Bool]()
        self.sets = 0
    }
    
    init(workoutPosition: Int) {
        self.workoutPosition = workoutPosition
        self.exercise = ""
        self.reps = [Int]()
        self.weight = [String]()
        self.type = .CU
        self.completedSets = [Bool]()
        self.sets = 0
    }
    
    func getSets() -> [ExerciseSet] {
        var setModels = [ExerciseSet]()
        guard let reps = reps, let weight = weight, let completedSets = completedSets else {return setModels}
        for i in 0..<sets {
            setModels.append(ExerciseSet(set: i + 1, reps: reps[i], weight: weight[i], completed: completedSets[i]))
        }
        return setModels
    }
    
//    static func == (lhs: ExerciseModel, rhs: ExerciseModel) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
}

//class EMOMModel: Codable {
//    var exerciseType: ExerciseType = .emom
//    var exercise: String? = "EMOM"
//    var exercises: [ExerciseModel]
//    var timeLimit: Int
//    var completed: Bool
//    //var completed: Observable<Bool> = Observable<Bool>()
//    //var emom: Bool = true
//    var rpe: Int?
//    var started: Bool
//    var startTime: TimeInterval?
//}


