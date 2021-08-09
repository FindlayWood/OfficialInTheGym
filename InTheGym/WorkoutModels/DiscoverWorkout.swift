//
//  DiscoverWorkout.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct discoverWorkout: WorkoutDelegate {
    
    var assigned: Bool?
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
    var clipData: [clipDataModel]?
    
    init?( snapshot: DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return
        }
        self.title = snap["title"] as? String
        self.creatorID = snap["creatorID"] as? String
        self.createdBy = snap["createdBy"] as? String
        self.savedID = snapshot.key
        self.timeToComplete = snap["timeToComplete"] as? String
        self.completed = snap["completed"] as? Bool ?? false
        self.liveWorkout = snap["liveWorkout"] as? Bool ?? false
        self.fromDiscover = true
        self.numberOfDownloads = snap["NumberOfDownloads"] as? Int
        self.numberOfCompletes = snap["NumberOfCompletes"] as? Int
        self.views = snap["Views"] as? Int
        self.totalTime = snap["TotalTime"] as? Int
        self.totalScore = snap["TotalScore"] as? Int
        if let data = snap["exercises"] as? [[String:AnyObject]]{
            var tempEx : [WorkoutType] = []
            for item in data{
                if let _ = item["circuit"] as? Bool{
                    tempEx.append(circuit(item: item)!)
                } else if let _ = item["amrap"] as? Bool {
                    tempEx.append(AMRAP(data: item)!)
                } else {
                    tempEx.append(exercise(exercises: item)!)
                }
            }
            self.exercises = tempEx
        }
        if let clipData = snap["clipData"] as? [[String: AnyObject]] {
            var tempClips: [clipDataModel] = []
            for item in clipData {
                tempClips.append(clipDataModel(data: item)!)
//                let clip = item.value as! [String: AnyObject]
//                tempClips.insert(clipDataModel(data: clip)!, at: 0)
            }
            self.clipData = tempClips
        }
    }
    
    init?(object: [String:AnyObject]){
        self.title = object["title"] as? String
        self.creatorID = object["creatorID"] as? String
        self.createdBy = object["createdBy"] as? String
        self.savedID = object["savedID"] as? String
        self.timeToComplete = object["timeToComplete"] as? String
        self.completed = object["completed"] as? Bool ?? false
        self.liveWorkout = object["liveWorkout"] as? Bool ?? false
        self.fromDiscover = true
        self.numberOfDownloads = object["NumberOfDownloads"] as? Int
        self.numberOfCompletes = object["NumberOfCompletes"] as? Int
        self.views = object["Views"] as? Int
        self.totalTime = object["TotalTime"] as? Int
        self.totalScore = object["TotalScore"] as? Int
        if let data = object["exercises"] as? [[String:AnyObject]]{
            var tempEx : [WorkoutType] = []
            for item in data{
                if let _ = item["circuit"] as? Bool{
                    tempEx.append(circuit(item: item)!)
                } else if let _ = item["amrap"] as? Bool {
                    tempEx.append(AMRAP(data: item)!)
                } else {
                    tempEx.append(exercise(exercises: item)!)
                }
            }
            self.exercises = tempEx
        }
        if let clipData = object["clipData"] as? [[String: AnyObject]] {
            var tempClips: [clipDataModel] = []
            for item in clipData {
                tempClips.append(clipDataModel(data: item)!)
//                let clip = item.value as! [String: AnyObject]
//                tempClips.insert(clipDataModel(data: clip)!, at: 0)
            }
            self.clipData = tempClips
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
        if let clips = clipData {
            object["clipData"] = clips.map { ($0.toObject())} as AnyObject
        }
        return object
    }
    
}
