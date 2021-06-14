//
//  Exercise.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation


class exercise: WorkoutType{
    
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
        return object
    }
}
