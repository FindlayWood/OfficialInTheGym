//
//  Workout.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import UIKit


class workout: WorkoutDelegate, Completeable{
    var title: String!
    var creatorID: String!
    var liveWorkout: Bool!
    var fromDiscover: Bool!
    var workoutID: String?
    var savedID:String!
    var createdBy:String?
    var completed:Bool!
    var exercises:[WorkoutType]?
    var numberOfDownloads:Int?
    var numberOfCompletes:Int?
    var score:Int?
    var startTime:TimeInterval?
    var timeToComplete:String?
    var workload:Int?
    var assigned:Bool?
    
    init?(snapshot:DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return
        }
        self.title = snap["title"] as? String
        self.creatorID = snap["creatorID"] as? String
        self.liveWorkout = snap["liveWorkout"] as? Bool ?? false
        self.fromDiscover = snap["fromDiscover"] as? Bool ?? false
        self.workoutID = snapshot.key
        self.savedID = snap["savedID"] as? String
        self.createdBy = snap["createdBy"] as? String
        self.completed = snap["completed"] as? Bool
        self.score = snap["score"] as? Int
        self.startTime = snap["startTime"] as? TimeInterval
        self.workload = snap["workload"] as? Int
        self.assigned = snap["assigned"] as? Bool ?? false
        if let data = snap["exercises"] as? [[String:AnyObject]]{
            var tempEx : [WorkoutType] = []
            for item in data{
                if let _ = item["circuit"] as? Bool{
                    tempEx.append(circuit(item: item)!)
                } else {
                    tempEx.append(exercise(exercises: item)!)
                }
            }
            self.exercises = tempEx
             //self.exercises = data.map {(exercise(exercises: $0)!)}
        }
    }
    
    init?(object:[String:AnyObject]){
        self.createdBy = object["createdBy"] as? String
        self.completed = object["completed"] as? Bool
        if let data = object["exercises"] as? [[String:AnyObject]]{
            var tempEx : [WorkoutType] = []
            for item in data{
                if let _ = item["circuit"] as? Bool{
                    tempEx.append(circuit(item: item)!)
                } else {
                    tempEx.append(exercise(exercises: item)!)
                }
            }
            self.exercises = tempEx
            //self.exercises = ex.map { (exercise(exercises: $0)!)}
        }
        self.numberOfDownloads = object["NumberOfDownloads"] as? Int
        self.numberOfCompletes = object["NumberOfCompletes"] as? Int
        self.score = object["score"] as? Int
        self.timeToComplete = object["timeToComplete"] as? String
        self.workload = object["workload"] as? Int
        self.fromDiscover = object["fromDiscover"] as? Bool
        self.title = object["title"] as? String
        self.liveWorkout = object["liveWorkout"] as? Bool ?? false
        self.creatorID = object["creatorID"] as? String
        self.savedID = object["savedID"] as? String
        self.assigned = object["assigned"] as? Bool ?? false
        self.workoutID = object["workoutID"] as? String
    }
    
    func toObject() -> [String : AnyObject] {
        var objectToReturn = [
            "title":self.title!,
            "creatorID":self.creatorID!,
            "liveWorkout":self.liveWorkout!,
            "fromDiscover":self.fromDiscover!,
            "createdBy":self.createdBy!,
            "completed":self.completed!,
            "assigned":self.assigned!
        ] as [String:AnyObject]
        
        if let workoutID = workoutID {
            objectToReturn["workoutID"] = workoutID as AnyObject
        }
        
        if let savedID = savedID {
            objectToReturn["savedID"] = savedID as AnyObject
        }
        
        if let data = exercises{
            objectToReturn["exercises"] = data.map { ($0.toObject())} as AnyObject
        }
        return objectToReturn
    }
    
}

struct circuitExercise : Codable{
    var exercise:String!
    var reps:Int!
    var sets:Int!
    //var type:bodyType!
    var weight:Double?
    var completedSets:[Bool]!
    
    init?(item:[String:AnyObject]){
        self.exercise = item["exercise"] as? String
        self.reps = item["reps"] as? Int
        self.sets = item["sets"] as? Int
        self.weight = item["weight"] as? Double
        self.completedSets = item["completedSets"] as? [Bool]
    }
    
    func toObject() -> [String:AnyObject]{
        var object = ["exercise": exercise!,
                      "reps": reps!,
                      "sets": sets!,
                      "completedSets": completedSets!,] as [String : AnyObject]
        
        if let weight = weight{
            object["weight"] = weight as AnyObject
        }
        
        return object
    }
}

class circuit : WorkoutType{
    var exercise:String!
    var exercises:[circuitExercise]?
    var circuitName:String!
    var createdBy:String!
    var creatorID:String!
    var savedID:String!
    var integrated:Bool!
    var circuit: Bool = true
    var completed: Observable<Bool> = Observable<Bool>()
    var startTime:TimeInterval!
    var rpe: Int?
    var newRPE: Observable<Int> = Observable<Int>()
    
    init?(item: [String:AnyObject]) {
        self.exercise = item["exercise"] as? String
        self.circuitName = item["exercise"] as? String
        self.createdBy = item["createdBy"] as? String
        self.creatorID = item["creatorID"] as? String
        self.integrated = item["integrated"] as? Bool
        self.completed.value = item["completed"] as? Bool
        self.startTime = item["startTime"] as? TimeInterval
        self.integrated = item["integrated"] as? Bool
        self.newRPE.value = item["rpe"] as? Int
        if let data = item["exercises"] as? [[String:AnyObject]] {
            self.exercises = data.map {(circuitExercise(item: $0)!)}
        }
        
    }
    
    func toObject() -> [String:AnyObject]{
        var object = ["exercise":exercise!,
                      "createdBy":createdBy!,
                      "creatorID":creatorID!,
                      "completed":completed.value!,
                      "circuit":circuit] as [String:AnyObject]
        
        if let exerciseData = exercises{
            object["exercises"] = exerciseData.map { ($0.toObject()) } as AnyObject
        }
        if let saved = savedID{
            object["savedID"] = saved as AnyObject
        }
        if let rpe = newRPE.value{
            object["rpe"] = rpe as AnyObject
        }
        
        return object
    }
    
    func integrate() -> [CircuitTableModel]{
        var reps: [Int] = []
        var sets: [Int] = []
        var originalSets: [Int] = []
        var exerciseNames:[String] = []
        var circuitTableModels: [CircuitTableModel] = []
        var exerciseCompletions : [[Bool]] = []
        for exercise in exercises!{
            reps.append(exercise.reps)
            sets.append(exercise.sets)
            originalSets.append(exercise.sets)
            exerciseNames.append(exercise.exercise)
            exerciseCompletions.append(exercise.completedSets)
        }
        
        while sets.reduce(0,+) != 0 {
            for i in 0..<sets.count{
                if sets[i] != 0 {
                    let set = originalSets[i] - sets[i]
                    circuitTableModels.append(CircuitTableModel(exerciseName: exerciseNames[i],
                                                                reps: reps[i],
                                                                set: set + 1,
                                                                overallSet: circuitTableModels.count + 1,
                                                                completed: exerciseCompletions[i][set],
                                                                exerciseOrder: i))
                    sets[i] -= 1
                }
            }
        }
        return circuitTableModels
    }
}

class Observable<T>{
    var value : T? {
        didSet{
            if let value = value{
                DispatchQueue.main.async {
                    self.valueChanged?(value)
                }
            }
        }
    }
    var valueChanged: ((T) -> Void)?
}

struct CircuitTableModel{
    var exerciseName:String
    var reps:Int
    var set:Int
    var overallSet:Int
    var completed:Bool
    var exerciseOrder:Int
}

protocol WorkoutType {
    var exercise:String! {get}
    func toObject() -> [String:AnyObject]
}



class exercise : WorkoutType{
    
    var exercise:String!
    var reps:String?
    var sets:String?
    var type:bodyType?
    var weight:String?
    var repArray:[String]?
    var weightArray:[String]?
    var completedSets:[Bool]?
    var rpe:String?
    var note:String?
    
    init?(exercises: [String:AnyObject]){
        self.exercise = exercises["exercise"] as? String
        self.reps = exercises["reps"] as? String
        self.repArray = exercises["reps"] as? [String]
        self.sets = exercises["sets"] as? String
        self.type = TransformWorkout.stringToBodyType(from: exercises["type"] as? String ?? "UB")
        self.weight = exercises["weight"] as? String
        self.weightArray = exercises["weight"] as? [String]
        self.completedSets = exercises["completedSets"] as? [Bool]
        self.rpe = exercises["rpe"] as? String
        self.note = exercises["note"] as? String
    }
    
    func toObject() -> [String:AnyObject]{
        var object = ["exercise": exercise!,
                      "sets": sets!,
                      "type": TransformWorkout.bodyTypeToString(from: type!),
                      "completedSets": completedSets!,] as [String : AnyObject]
        
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
        
        if let reps = reps{
            object["reps"] = reps as AnyObject
        }
        if let repArray = repArray{
            object["reps"] = repArray as AnyObject
        }
        
        
        return object
    }
    
}

enum bodyType{
        case UB
        case LB
        case CO
        case CA
    }


struct liveWorkout : WorkoutDelegate, Completeable {
    
    var title: String!
    var creatorID: String!
    var savedID:String!
    var exercises: [WorkoutType]?
    var completed: Bool!
    var liveWorkout : Bool!
    var createdBy:String!
    var score:Int?
    var startTime:TimeInterval!
    var timeToComplete:String?
    var workload:Int?
    var fromDiscover:Bool!
    var workoutID: String?
    var assigned: Bool!
    
    init?(data : [String:AnyObject]){
        self.title = data["title"] as? String
        self.creatorID = data["creatorID"] as? String
        self.completed = false
        self.liveWorkout = true
        self.createdBy = data["createdBy"] as? String
        self.startTime = data["startTime"] as? TimeInterval
        self.fromDiscover = false
        self.assigned = false
    }
    
    func toObject() -> [String : AnyObject] {
        var object = ["title":title!,
                      "creatorID":creatorID!,
                      "createdBy":createdBy!,
                      "savedID":savedID!,
                      "completed":completed!,
                      "liveWorkout":true,
                      "fromDiscover":false,
                      "workoutID":workoutID!,
                      "assigned":false] as [String:AnyObject]
        
        if timeToComplete != nil{
            object["timeToComplete"] = timeToComplete as AnyObject
        }
        if let data = exercises{
            object["exercises"] = data.map { ($0.toObject())} as AnyObject
        }
        return object
    }
    
    
}

struct discoverWorkout : WorkoutDelegate {
    
    var title: String!
    var creatorID: String!
    var savedID:String!
    var exercises: [WorkoutType]?
    var completed: Bool!
    var liveWorkout : Bool!
    var createdBy:String!
    var fromDiscover:Bool!
    var numberOfDownloads:Int?
    var numberOfCompletes:Int?
    var views:Int?
    var totalTime:Int?
    var totalScore:Int?
    var timeToComplete:String?
    var workoutID: String?
    
    init?( snapshot: DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return
        }
        self.title = snap["title"] as? String
        self.creatorID = snap["creatorID"] as? String
        self.createdBy = snap["createdBy"] as? String
        self.savedID = snapshot.key
        self.timeToComplete = snap["timeToComplete"] as? String
        self.completed = snap["completed"] as? Bool
        self.liveWorkout = snap["liveWorkout"] as? Bool ?? false
        self.fromDiscover = true
        self.numberOfDownloads = snap["NumberOfDownloads"] as? Int
        self.numberOfCompletes = snap["NumberOfCompletes"] as? Int
        self.views = snap["Views"] as? Int
        self.totalTime = snap["TotalTime"] as? Int
        self.totalScore = snap["TotalScore"] as? Int
        if let ex = snap["exercises"] as? [[String:AnyObject]]{
            self.exercises = ex.map { (exercise(exercises: $0)!)}
        }
    }
    
    init?(object:[String:AnyObject]){
        self.title = object["title"] as? String
        self.creatorID = object["creatorID"] as? String
        self.createdBy = object["createdBy"] as? String
        self.savedID = object["savedID"] as? String
        self.timeToComplete = object["timeToComplete"] as? String
        self.completed = object["completed"] as? Bool
        self.liveWorkout = object["liveWorkout"] as? Bool ?? false
        self.fromDiscover = true
        self.numberOfDownloads = object["NumberOfDownloads"] as? Int
        self.numberOfCompletes = object["NumberOfCompletes"] as? Int
        self.views = object["Views"] as? Int
        self.totalTime = object["TotalTime"] as? Int
        self.totalScore = object["TotalScore"] as? Int
        if let ex = object["exercises"] as? [[String:AnyObject]]{
            self.exercises = ex.map { (exercise(exercises: $0)!)}
        }
    }
    
    func toObject() -> [String : AnyObject] {
        var object = ["title":title!,
                      "creatorID":creatorID!,
                      "createdBy":createdBy!,
                      "savedID":savedID!,
                      "completed":completed!,
                      "liveWorkout":liveWorkout!,
                      "fromDiscover":true,
                      "NumberOfDownloads":numberOfDownloads!,
                      "NumberOfCompletes":numberOfCompletes!,
                      "Views":views!,
                      "TotalTime":totalTime!,
                      "TotalScore":totalScore!] as [String:AnyObject]
        
        if timeToComplete != nil{
            object["timeToComplete"] = timeToComplete as AnyObject
        }
        if let data = exercises{
            object["exercises"] = data.map { ($0.toObject())} as AnyObject
        }
        return object
    }
    
}

