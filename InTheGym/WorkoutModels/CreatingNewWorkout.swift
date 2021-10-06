//
//  CreatingNewWorkout.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

/// this object is for creating a brand new workout - this object does not exist on firebase until it is completed and uploaded
class CreatingNewWorkout: WorkoutDelegate {
    
    var title: String!
    var creatorID: String!
    var createdBy: String!
    var savedID: String!
    var workoutID: String?
    var exercises: [WorkoutType]?
    var liveWorkout: Bool!
    var fromDiscover: Bool!
    var clipData: [clipDataModel]?
    func toObject() -> [String : AnyObject] {
        return [:]
    }
    
    
}
