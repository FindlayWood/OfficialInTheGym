//
//  LiveWorkout.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class liveWorkout: Completeable {
    
    var title: String!
    var creatorID: String!
    var savedID:String!
    var exercises: [WorkoutType]?
    var completed: Bool!
    var liveWorkout : Bool!
    var createdBy: String!
    var score: Int?
    var startTime: TimeInterval?
    var timeToComplete: String?
    var workload: Int?
    var fromDiscover:Bool!
    var workoutID: String?
    var assigned: Bool!
    var clipData: [clipDataModel]?
    
    init?(snapshot: DataSnapshot) {
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return
        }
        self.title = snap["title"] as? String
        self.creatorID = snap["creatorID"] as? String
        self.liveWorkout = true
        self.fromDiscover = snap["fromDiscover"] as? Bool ?? false
        self.workoutID = snapshot.key
        self.createdBy = snap["createdBy"] as? String
        self.completed = snap["completed"] as? Bool ?? false
        self.score = snap["score"] as? Int
        self.startTime = snap["startTime"] as? TimeInterval
        self.workload = snap["workload"] as? Int
        self.assigned = false
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
        }
        if let clipData = snap["clipData"] as? [String: AnyObject] {
            var tempClips: [clipDataModel] = []
            for item in clipData {
                let clip = item.value as! [String: AnyObject]
                tempClips.insert(clipDataModel(data: clip)!, at: 0)
            }
            self.clipData = tempClips
        }
    }
    
    init?(data: [String:AnyObject]){
        self.title = data["title"] as? String
        self.creatorID = data["creatorID"] as? String
        self.workoutID = data["workoutID"] as? String
        self.completed = data["completed"] as? Bool ?? false
        self.liveWorkout = true
        self.createdBy = data["createdBy"] as? String
        self.startTime = data["startTime"] as? TimeInterval
        self.fromDiscover = false
        self.assigned = false
        self.exercises = [WorkoutType]()
        if let clipData = data["clipData"] as? [String: AnyObject] {
            var tempClips: [clipDataModel] = []
            for item in clipData {
                let clip = item.value as! [String: AnyObject]
                tempClips.insert(clipDataModel(data: clip)!, at: 0)
            }
            self.clipData = tempClips
        }
    }
    
    func toObject() -> [String : AnyObject] {
        var object = ["title":title!,
                      "creatorID":creatorID!,
                      "createdBy":createdBy!,
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
        if let clips = clipData {
            object["clipData"] = clips.map { ($0.toObject())} as AnyObject
        }
        return object
    } 
}
