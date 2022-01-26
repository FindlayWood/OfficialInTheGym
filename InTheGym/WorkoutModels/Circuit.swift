//
//  Circuit.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class circuit: WorkoutType {
    
    var exercise:String?
    var exercises:[exercise]?
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
            self.exercises = data.map {(InTheGym.exercise(exercises: $0)!)}
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
    
    func integrate() -> [CircuitTableModel] {
        var reps: [Int] = []
        var weights: [String] = []
        var sets: [Int] = []
        var originalSets: [Int] = []
        var exerciseNames:[String] = []
        var circuitTableModels: [CircuitTableModel] = []
        var exerciseCompletions : [[Bool]] = []
        for (index, exercise) in exercises!.enumerated(){
            if let repArray = exercise.repArray {
                reps.append(repArray[index])
            } else {
                reps.append(exercise.reps!)
            }
            if let weightArray = exercise.weightArray {
                weights.append(weightArray[index])
            }
            sets.append(exercise.sets!)
            originalSets.append(exercise.sets!)
            exerciseNames.append(exercise.exercise!)
            exerciseCompletions.append(exercise.completedSets!)
        }
        
        while sets.reduce(0,+) != 0 {
            for i in 0..<sets.count{
                if sets[i] != 0 {
                    let set = originalSets[i] - sets[i]
                    circuitTableModels.append(CircuitTableModel(exerciseName: exerciseNames[i],
                                                                reps: reps[i],
                                                                weight: weights[i],
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

struct CircuitModel: ExerciseType, Codable, Hashable {
    var circuitPosition: Int
    var workoutPosition: Int
    var exercises: [ExerciseModel]
    var completed: Bool
    var circuitName: String
    var createdBy: String
    var creatorID: String
    var savedID: String?
    var integrated: Bool
    var startTime: TimeInterval?
    var rpe: Int?
    
    func intergrate() -> [CircuitTableModel] {
        var circuitModels = [CircuitTableModel]()
        let originalSets = exercises.map { $0.sets }
        var sets = exercises.map { $0.sets }
        while sets.reduce(0, +) > 0 {
            for i in 0..<sets.count {
                let set = originalSets[i] - sets[i]
                circuitModels.append(CircuitTableModel(exerciseName: exercises[i].exercise,
                                                     reps: exercises[i].reps[set],
                                                     weight: exercises[i].weight[set],
                                                     set: set + 1,
                                                     overallSet: circuitModels.count + 1,
                                                     completed: exercises[i].completedSets[set],
                                                     exerciseOrder: i))
                sets[i] -= 1
            }
        }
        return circuitModels
    }
}
