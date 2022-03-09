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

// MARK: - Workout Model
/// Model representing a single workout
/// Important Variables
/// -----> assignedTo = the id of the user assigned this workout - could be self id or ither user id
/// -----> savedID = the ID of where the workout is saved - all workouts are stored in the savedWorkouts ref - EXCEPT Live Workouts 
/// -----> workoutID = the ID of this specific workout - different from savedID as you may do the same saved workout more than once
class WorkoutModel: Codable, Hashable {
    var title: String
    var id: String
    var savedID: String?
    var creatorID: String
    var createdBy: String
    var assignedTo: String
    var isPrivate: Bool
    var completed: Bool
    var clipData: [WorkoutClipModel]?
    var score: Int?
    var startTime: TimeInterval?
    var timeToComplete: Int?
    var workload: Int?
    var summary: String?
    var exercises: [ExerciseModel]?
    var circuits: [CircuitModel]?
    var emoms: [EMOMModel]?
    var amraps: [AMRAPModel]?
    var liveWorkout: Bool?
//    var id: String {
//        return workoutID
//    }
    
    init(newSavedModel: NewSavedWorkoutModel, assignTo: String) {
        title = newSavedModel.title
        id = UUID().uuidString
        savedID = newSavedModel.savedID
        creatorID = newSavedModel.creatorID
        createdBy = newSavedModel.createdBy
        assignedTo = assignTo
        isPrivate = newSavedModel.isPrivate
        completed = false
        exercises = newSavedModel.exercises
        circuits = newSavedModel.circuits
        emoms = newSavedModel.emoms
        amraps = newSavedModel.amraps
    }
    init(savedModel: SavedWorkoutModel, assignTo: String) {
        title = savedModel.title
        id = UUID().uuidString
        savedID = savedModel.id
        creatorID = savedModel.creatorID
        createdBy = savedModel.createdBy
        assignedTo = assignTo
        isPrivate = savedModel.isPrivate
        completed = false
        exercises = savedModel.exercises
        circuits = savedModel.circuits
        emoms = savedModel.emoms
        amraps = savedModel.amraps
    }
    
    static func == (lhs: WorkoutModel, rhs: WorkoutModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension WorkoutModel {
    func totalExerciseCount() -> Int {
        var totalExerciseCount = 0
        totalExerciseCount += exercises?.count ?? 0
        totalExerciseCount += circuits?.count ?? 0
        totalExerciseCount += emoms?.count ?? 0
        totalExerciseCount += amraps?.count ?? 0
        return totalExerciseCount
    }
    func averageRPE() -> Double {
        guard let exercises = exercises else {return 0.0}
        let scores = exercises.map( { $0.rpe ?? 0 })
        let totalScore = scores.reduce(0, +)
        let averageRPE = Double(totalScore) / Double(exercises.count)
        return averageRPE.rounded(toPlaces: 1)
    }
    func getWorkload() -> Int {
        guard let timeToComplete = timeToComplete,
              let rpe = score
        else {return 0}
        let minutes = timeToComplete / 60
        return minutes * rpe
    }
}
extension WorkoutModel: FirebaseModel {
    static var path: String {
        return "Workouts/\(UserDefaults.currentUser.uid)"
    }
}
extension WorkoutModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Workouts/\(assignedTo)"
    }
}
extension WorkoutModel {
    func getTimeUpdatePoint() -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: startTime, path: "Workouts/\(UserDefaults.currentUser.uid)/\(id)/startTime")
    }
    func getRPEUploadPoint(_ exercise: ExerciseModel) -> FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: exercise.rpe, path: "Workouts/\(UserDefaults.currentUser.uid)/\(id)/exercises/\(exercise.workoutPosition)/rpe")
    }
    func getSetUploadPoint(_ exercise: ExerciseModel, setNumber: Int) -> FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: true, path: "Workouts/\(UserDefaults.currentUser.uid)/\(id)/exercises/\(exercise.workoutPosition)/completedSets/\(setNumber)")
    }
}
