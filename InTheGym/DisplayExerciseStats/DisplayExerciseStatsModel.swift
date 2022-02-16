//
//  DisplayExerciseStatsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct DisplayExerciseStatsModel {
    var exerciseName: String = ""
    var maxWeight: Double = 0
    var maxWeightDate: TimeInterval = 0.0
    var numberOfReps: Int = 0
    var numberOfSets: Int = 0
    var totalWeight: Double = 0
    var averageWeight: Double = 0
    var numberOfCompletions: Int = 0
    var totalRPEScore: Int = 0
    var averageRPEScore: Double = 0
    
    var sectionState: sectionState = .collapsed
    
    init?(snapshot: DataSnapshot) {
        guard let snap = snapshot.value as? [String:AnyObject] else {return}
        self.exerciseName = snapshot.key
        self.maxWeight = snap["maxWeight"] as? Double ?? 0
        self.maxWeightDate = snap["maxWeightDate"] as? TimeInterval ?? 0
        self.numberOfReps = snap["numberOfRepsCompleted"] as? Int ?? 0
        self.numberOfSets = snap["numberOfSetsCompleted"] as? Int ?? 0
        self.totalWeight = snap["totalWeight"] as? Double ?? 0
        self.numberOfCompletions = snap["numberOfCompletions"] as? Int ?? 0
        self.totalRPEScore = snap["totalRPE"] as? Int ?? 0
        if totalWeight != 0 && numberOfSets != 0 {
            self.averageWeight = totalWeight / Double(numberOfSets)
        }
        if totalRPEScore != 0 && numberOfCompletions != 0 {
            self.averageRPEScore = Double(totalRPEScore / numberOfCompletions)
        }
    }
    func toObject() -> [String:AnyObject] {
        var object = [String:AnyObject]()
        object["exerciseName"] = exerciseName as AnyObject
        object["maxWeight"] = maxWeight as AnyObject
        if maxWeightDate != 0 {
            object["maxWeightDate"] = maxWeightDate as AnyObject
        }
        object["numberOfCompletions"] = numberOfCompletions as AnyObject
        object["numberOfRepsCompleted"] = numberOfReps as AnyObject
        object["numberOfSetsCompleted"] = numberOfSets as AnyObject
        object["totalRPE"] = totalRPEScore as AnyObject
        object["totalWeight"] = totalWeight as AnyObject
        return object
    }
}



enum sectionState {
    case collapsed
    case expanded
}
