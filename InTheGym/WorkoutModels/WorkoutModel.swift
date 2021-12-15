//
//  WorkoutModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class workout: Completeable {
    
    var title: String!
    var creatorID: String!
    var liveWorkout: Bool!
    var fromDiscover: Bool!
    var workoutID: String?
    var savedID: String!
    var createdBy: String!
    var completed: Bool!
    var exercises: [WorkoutType]?
    var numberOfDownloads: Int?
    var numberOfCompletes: Int?
    var score: Int?
    var startTime: TimeInterval?
    var timeToComplete: String?
    var workload: Int?
    var assigned: Bool!
    var clipData: [clipDataModel]?
    
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
        self.completed = snap["completed"] as? Bool ?? false
        self.score = snap["score"] as? Int
        self.startTime = snap["startTime"] as? TimeInterval
        self.workload = snap["workload"] as? Int
        self.assigned = snap["assigned"] as? Bool ?? false
        if let data = snap["exercises"] as? [[String:AnyObject]]{
            var tempEx : [WorkoutType] = []
            for item in data{
                if let _ = item["circuit"] as? Bool{
                    tempEx.append(circuit(item: item)!)
                } else if let _ = item["amrap"] as? Bool {
                    tempEx.append(AMRAP(data: item)!)
                } else if let _ = item["emom"] as? Bool {
                    tempEx.append(EMOM(data: item)!)
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
    
    init?(object:[String:AnyObject]){
        self.createdBy = object["createdBy"] as? String
        self.completed = object["completed"] as? Bool ?? false
        if let data = object["exercises"] as? [[String:AnyObject]]{
            var tempEx : [WorkoutType] = []
            for item in data{
                if let _ = item["circuit"] as? Bool{
                    tempEx.append(circuit(item: item)!)
                } else if let _ = item["amrap"] as? Bool {
                    tempEx.append(AMRAP(data: item)!)
                } else if let _ = item["emom"] as? Bool {
                    tempEx.append(EMOM(data: item)!)
                } else {
                    tempEx.append(exercise(exercises: item)!)
                }
            }
            self.exercises = tempEx
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
        
        if let data = exercises {
            objectToReturn["exercises"] = data.map { ($0.toObject())} as AnyObject
        }
        if let clips = clipData {
            objectToReturn["clipData"] = clips.map { ($0.toObject())} as AnyObject
        }
        return objectToReturn
    }
    
}

struct WorkoutModel: Codable, Hashable {
    var title: String
    var workoutID: String?
    var creatorID: String
    var createdBy: String
    var completed: Bool
    var score: String?
    var startTime: TimeInterval?
    var timeToComplete: Int?
    var workload: Int?
    var exercises: [ExerciseModel]
    var liveWorkout: Bool?
    
    static func == (lhs: WorkoutModel, rhs: WorkoutModel) -> Bool {
        lhs.workoutID == rhs.workoutID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(workoutID)
    }
}

extension WorkoutModel: FirebaseResource {
    static var path: String {
        return "Workouts/\(FirebaseAuthManager.currentlyLoggedInUser.uid)"
    }
    var internalPath: String {
        return "Workouts/\(workoutID)"
    }
}

/// A type that can be loaded and uploaded to and from Firebase
/// A Firebase Resource REQUIRES Codable
protocol FirebaseResource: Codable {
    
    /// The String that holds the path to the correct database reference in Firebase
    /// Must be static to allow access without creating instance
    static var path: String { get }
    
    /// The path to an instance of the model
    /// This will usually include an id to point to specific database reference or specific list
    var internalPath: String { get }
}

