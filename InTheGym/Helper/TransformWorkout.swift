//
//  TransformWorkout.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class TransformWorkout: NSObject {
    // class to transform workout to workout type/ [string:anyobject]
    
    static func toWorkoutType(from data:[String:AnyObject]) -> workout{
        let workoutType = workout(object: data)
//        workoutType.title = data["title"] as? String
//        workoutType.createdBy = data["createdBy"] as? String
//        workoutType.completed = data["completed"] as? Bool
//        workoutType.liveWorkout = data["liveWorkout"] as? Bool
//        workoutType.workload = data["workload"] as? Int
//        workoutType.startTime = data["startTime"] as? TimeInterval
//        workoutType.timeToComplete = data["timeToComplete"] as? String
//        workoutType.score = data["score"] as? Int
//        workoutType.creatorID = data["creatorID"] as? String
//        workoutType.fromDicover = data["fromDiscover"] as? Bool
//        workoutType.numberOfCompletes = data["numberOfCompletes"] as? Int
//        workoutType.numberOfDownloads = data["numberOfDownloads"] as? Int
//        let exercises = TransformWorkout.dataToExercises(from: data["exercises"] as? [[String : AnyObject]] ?? [])
//        workoutType.exercises = exercises
        
        return workoutType!
        
        
    }
    
    static func dataToExercises(from data:[[String:AnyObject]]) -> [exercise]{
        var exercises = [exercise]()
        
        
        for item in data{
            let thisExercise = exercise(exercises: item)
            exercises.append(thisExercise!)
        }
        
        
        
        return exercises
    }
    
    static func stringToBodyType(from string:String) -> bodyType{
        
        switch string {
        case "UB":
            return bodyType.UB
        case "LB":
            return bodyType.LB
        case "CO":
            return bodyType.CO
        case "CA":
            return bodyType.CA
        default:
            return bodyType.UB
        }
    }
    
    static func bodyTypeToString(from type:bodyType) -> String{
        switch type {
        case .UB:
            return "UB"
        case .LB:
            return "LB"
        case .CO:
            return "CO"
        case .CA:
            return "CA"
        }
        
    }
    
    
    
}
