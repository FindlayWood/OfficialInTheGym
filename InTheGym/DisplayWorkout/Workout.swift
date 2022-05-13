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

struct circuitExercise {
    var exercise: String?
    var reps: Int?
    var sets: Int?
    var type: bodyType?
    var weight: Double?
    var completedSets: [Bool]?
    
    init?(){}
    
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


class Observable<T: Codable> {
    var value : T? {
        didSet {
            if let value = value{
                DispatchQueue.main.async {
                    self.valueChanged?(value)
                }
            }
        }
    }
    var valueChanged: ((T) -> Void)?
}

struct CircuitTableModel {
    var exerciseName:String
    var reps:Int
    var weight:String
    var set:Int
    var overallSet:Int
    var completed:Bool
    var exerciseOrder:Int
}

protocol WorkoutType {
    var exercise: String? {get set}
    func toObject() -> [String:AnyObject]
}

protocol WorkoutAddable {
    var exercise: String? {get set}
    var reps: Int? {get set}
    var repArray: [Int]? {get set}
    var sets: Int? {get set}
    var type: bodyType? {get set}
    var completedSets: [Bool]? {get set}
    func toObject() -> [String:AnyObject]
}


enum bodyType: String, Codable, Hashable {
        case UB = "UB"
        case LB = "LB"
        case CO = "CO"
        case CA = "CA"
        case CU = "CU"
    }


