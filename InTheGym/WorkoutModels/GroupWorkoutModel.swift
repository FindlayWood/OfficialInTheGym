//
//  GroupWorkoutModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

protocol GroupWorkoutDelegate: WorkoutDelegate {
    var addedBy: [String]? {get set}
    var completedBy: [String]? {get set}
    var groupID: String! {get}
    var groupWorkout: Bool! {get}
}


class GroupWorkoutModel: GroupWorkoutDelegate {
    var addedBy: [String]?
    var completedBy: [String]?
    var groupID: String!
    var groupWorkout: Bool!
    var title: String!
    var creatorID: String!
    var createdBy: String!
    var savedID: String!
    var workoutID: String?
    var exercises: [WorkoutType]?
    var liveWorkout: Bool!
    var fromDiscover: Bool!
    var clipData: [clipDataModel]?

    init?(snapshot: DataSnapshot) {
        guard let snap = snapshot.value as? [String: AnyObject] else {return}
        self.title = snap["title"] as? String
        self.creatorID = snap["creatorID"] as? String
        self.createdBy = snap["createdBy"] as? String
        self.savedID = snap["savedID"] as? String
        self.groupID = snap["groupID"] as? String
        self.groupWorkout = true
        self.workoutID = snapshot.key
        self.liveWorkout = false
        self.fromDiscover = false
        self.addedBy = snap["addedBy"] as? [String]
        self.completedBy = snap["completedBy"] as? [String]
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
    }
    
    func toObject() -> [String : AnyObject] {
        var object = ["title": title!,
                      "workoutID": workoutID!,
                      "creatorID": creatorID!,
                      "createdBy": createdBy!,
                      "savedID": savedID!,
                      "groupID": groupID!,
                      "groupWorkout": true,
                      "liveWorkout": false,
                      "fromDiscover": false] as [String:AnyObject]
        
        if let added = addedBy {
            object["addedBy"] = added as AnyObject
        }
        if let completed = completedBy {
            object["completedBy"] = completed as AnyObject
        }

        if let data = exercises{
            object["exercises"] = data.map { ($0.toObject())} as AnyObject
        }

        return object
    }
    
    
}
