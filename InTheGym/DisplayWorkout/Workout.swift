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


struct workout: WorkoutDelegate, Completeable{
    var title: String!
    var creatorID: String!
    var liveWorkout: Bool!
    var fromDiscover: Bool!
    var workoutID: String!
    var savedID:String!
    var createdBy:String?
    var completed:Bool!
    var exercises:[exercise]?
    var numberOfDownloads:Int?
    var numberOfCompletes:Int?
    var score:Int?
    var startTime:TimeInterval?
    var timeToComplete:String?
    var workload:Int?
    var fromDicover:Bool?
    var assigned:Bool?
    
    
    init?(object:[String:AnyObject]){
        self.createdBy = object["createdBy"] as? String
        self.completed = object["completed"] as? Bool
        if let ex = object["exercises"] as? [[String:AnyObject]]{
            self.exercises = ex.map { (exercise(exercises: $0)!)}
        }
        self.numberOfDownloads = object["NumberOfDownloads"] as? Int
        self.numberOfCompletes = object["NumberOfCompletes"] as? Int
        self.score = object["score"] as? Int
        self.timeToComplete = object["timeToComplete"] as? String
        self.workload = object["workload"] as? Int
        self.fromDiscover = object["fromDiscover"] as? Bool
        self.title = object["title"] as? String
        self.liveWorkout = object["liveWorkout"] as? Bool
        self.creatorID = object["creatorID"] as? String
        self.savedID = object["savedID"] as? String
        self.assigned = object["assigned"] as? Bool ?? false
        self.workoutID = object["workoutID"] as? String
    }
    
    func toObject() -> [String : AnyObject] {
        return [:]
    }
    
}





struct exercise{
    
    var exercise:String!
    var reps:String?
    var sets:String?
    var type:bodyType?
    var weight:String?
    var repArray:[Int]?
    var weightArray:[Double]?
    var completedSets:[Bool]?
    var rpe:Int?
    var note:String?
    
    init?(exercises: [String:AnyObject]){
        self.exercise = exercises["exercise"] as? String
        self.reps = exercises["reps"] as? String
        self.sets = exercises["sets"] as? String
        self.type = TransformWorkout.stringToBodyType(from: exercises["type"] as? String ?? "UB")
        self.weight = exercises["weight"] as? String
        self.completedSets = exercises["completedSets"] as? [Bool]
        self.rpe = exercises["rpe"] as? Int
        self.note = exercises["note"] as? String
    }
    
    func toObject() -> [String:AnyObject]{
        var object = ["exercise": exercise!,
                      "reps" : reps!,
                      "sets": sets!,
                      "type": TransformWorkout.bodyTypeToString(from: type!),
                      "completedSets": completedSets!,] as [String : AnyObject]
        
        if weight != nil{
            object["weight"] = weight! as AnyObject
        }
        if rpe != nil{
            object["rpe"] = rpe! as AnyObject
        }
        if note != nil{
            object["note"] = note! as AnyObject
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
    var exercises: [exercise]?
    var completed: Bool!
    var liveWorkout : Bool!
    var createdBy:String!
    var score:Int?
    var startTime:TimeInterval!
    var timeToComplete:String?
    var workload:Int?
    var fromDiscover:Bool!
    var workoutID: String!
    
    init?(data : [String:AnyObject]){
        self.title = data["title"] as? String
        self.creatorID = data["creatorID"] as? String
        self.completed = false
        self.liveWorkout = true
        self.createdBy = data["createdBy"] as? String
        self.startTime = data["startTime"] as? TimeInterval
        self.fromDiscover = false
    }
    
    func toObject() -> [String : AnyObject] {
        var object = ["title":title!,
                      "creatorID":creatorID!,
                      "createdBy":createdBy!,
                      "savedID":savedID!,
                      "completed":completed!,
                      "liveWorkout":liveWorkout!,
                      "fromDiscover":fromDiscover!,
                      "workoutID":workoutID!] as [String:AnyObject]
        
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
    var exercises: [exercise]?
    var completed: Bool!
    var liveWorkout : Bool!
    var createdBy:String!
    var fromDiscover:Bool!
    var numberOfDownloads:Int?
    var numberOfCompletes:Int?
    var totalTime:Int?
    var totalScore:Int?
    var timeToComplete:String?
    
    init?( snapshot: DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return
        }
        self.title = snap["title"] as? String
        self.creatorID = snap["creatorID"] as? String
        self.createdBy = snap["createdBy"] as? String
        self.savedID = snap["savedID"] as? String
        self.timeToComplete = snap["timeToComplete"] as? String
        self.completed = snap["completed"] as? Bool
        self.liveWorkout = snap["liveWorkout"] as? Bool
        self.fromDiscover = true
        self.numberOfDownloads = snap["NumberOfDownloads"] as? Int
        self.numberOfCompletes = snap["NumberOfCompletes"] as? Int
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
        self.liveWorkout = object["liveWorkout"] as? Bool
        self.fromDiscover = true
        self.numberOfDownloads = object["NumberOfDownloads"] as? Int
        self.numberOfCompletes = object["NumberOfCompletes"] as? Int
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
                      "fromDiscover":fromDiscover!,
                      "NumberOfDownloads":numberOfDownloads!,
                      "NumberOfCompletes":numberOfCompletes!,
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

