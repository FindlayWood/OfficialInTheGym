//
//  TestData.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 28/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
@testable import InTheGym

class TestData: NSObject{
    
    
    
    static var exampleWorkout =  ["title": "Friday Leg Day",
                                  "createdBy": "The Rock",
                                  "score":8,
                                  "exercises": [["exercise":"Bench Press",
                                                 "sets":8,
                                                 "reps":10,
                                                 "type":"UB",
                                                 "completedSets":[true,true,true]],
                                                ["exercise":"Bench Press",
                                                               "sets":8,
                                                               "reps":10,
                                                               "type":"UB"]]
                                  ] as [String:AnyObject]
    
    var answer : workout!
    var exercise1 : exercise!
    var exercise2 : exercise!
    
    override init() {
        super.init()
        exercise1 = exercise()
        exercise1.exercise = "Bench Press"
        exercise1.sets = 8
        exercise1.reps = 10
        exercise1.type = bodyType.UB
        exercise1.completedSets = [true,true,true]
        
        exercise2 = exercise()
        exercise2.exercise = "Bench Press"
        exercise2.sets = 8
        exercise2.reps = 10
        exercise2.type = bodyType.UB
        
        answer = workout()
        answer.title = "Friday Leg Day"
        answer.createdBy = "The Rock"
        answer.score = 8
        answer.exercises = [exercise1,exercise2]
        
        
    }
    
}
