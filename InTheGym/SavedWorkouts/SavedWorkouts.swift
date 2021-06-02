//
//  SavedWorkouts.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase


protocol savedWorkoutDelegate: WorkoutDelegate {
    var title:String! { get }
    var exercises:[WorkoutType]? { get set}
    var isPrivate:Bool? { get }
}

struct publicSavedWorkout : savedWorkoutDelegate {
    
    var title: String!
    var creatorID: String!
    var completed: Bool
    var liveWorkout: Bool!
    var fromDiscover: Bool!
    var isPrivate: Bool?
    var workoutID: String?
    var savedID:String!
    var exercises:[WorkoutType]?
    var createdBy: String!
    var views:Int?
    var completes:Int?
    var downloads:Int?
    var totalTime:Int?
    var totalScore:Int?
    
    
    init?( snapshot: DataSnapshot) {
        guard let snap = snapshot.value as? [String:AnyObject] else{
            return nil
        }
        self.isPrivate = false
        self.liveWorkout = false
        self.fromDiscover = snap["fromDiscover"] as? Bool ?? false
        self.completed = false
        self.workoutID = snapshot.key
        self.title = snap["title"] as? String
        self.createdBy = snap["createdBy"] as? String
        self.creatorID = snap["creatorID"] as? String
        self.views = snap["Views"] as? Int
        self.completes = snap["NumberOfCompletes"] as? Int
        self.downloads = snap["NumberOfDownloads"] as? Int
        self.totalTime = snap["TotalTime"] as? Int
        self.totalScore = snap["TotalScore"] as? Int
        if let data = snap["exercises"] as? [[String:AnyObject]]{
            self.exercises = data.map { (exercise(exercises: $0)!)}
        }
    }
    
    
    func toObject() -> [String:AnyObject]{
        
        var object = ["title" : title!,
                      "createdBy" : createdBy!,
                      "completed": false,
                      "liveWorkout": false,
                      "fromDiscover": fromDiscover!,
                      "savedID" : workoutID!,
                      "creatorID" : creatorID!,
                      "isPrivate": false,
                      "NumberOfCompletes": completes!,
                      "NumberOfDownloads": downloads!,
                      "TotalTime": totalTime!,
                      "TotalScore": totalScore!,
                      "Views": views!] as [String:AnyObject]
        
        if let data = exercises{
            object["exercises"] = data.map { ($0.toObject())} as AnyObject
        }
        
        
        return object
    }
    
    
    
}

struct privateSavedWorkout : savedWorkoutDelegate {
    
    var title: String!
    var creatorID: String!
    var completed: Bool
    var liveWorkout: Bool!
    var fromDiscover: Bool!
    var workoutID: String?
    var savedID:String!
    var exercises: [WorkoutType]?
    var createdBy: String!
    var isPrivate: Bool?
    var completes: Int?
    var totalTime: Int?
    var totalScore: Int?
    var assigned: Bool!
    
    
    
    init?( snapshot: DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return nil
        }
        self.isPrivate = true
        self.liveWorkout = false
        self.fromDiscover = snap["fromDiscover"] as? Bool ?? false
        self.completed = false
        self.workoutID = snapshot.key
        self.title = snap["title"] as? String
        self.createdBy = snap["createdBy"] as? String
        self.creatorID = snap["creatorID"] as? String
        self.completes = snap["NumberOfCompletes"] as? Int
        self.totalTime = snap["TotalTime"] as? Int
        self.totalScore = snap["TotalScore"] as? Int
        if let data = snap["exercises"] as? [[String:AnyObject]]{
            self.exercises = data.map { (exercise(exercises: $0)!)}
        }
    }
    
    func toObject() -> [String:AnyObject]{
        
        var object = ["title" : title!,
                      "createdBy" : createdBy!,
                      "completed": false,
                      "liveWorkout": false,
                      "fromDiscover": fromDiscover!,
                      "savedID" : workoutID!,
                      "creatorID" : creatorID!,
                      "isPrivate": true] as [String:AnyObject]
        
        if let data = exercises{
            object["exercises"] = data.map { ($0.toObject())} as AnyObject
        }
        
        
        return object
    }
    
}

struct SavedWorkoutReferenceModel{
    var creatorID:String!
    var workoutID:String!
    
    init?(snapshot:DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return
        }
        self.creatorID = snap["creatorID"] as? String
        self.workoutID = snap["workoutID"] as? String
    }
}
