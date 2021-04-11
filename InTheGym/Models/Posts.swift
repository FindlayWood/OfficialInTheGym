//
//  Posts.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/12/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//
// post model

import Foundation
import UIKit

struct Post {
    var postType : postType!
    var time : TimeInterval?
    var username : String?
    var posterID : String?
    var postID : String?
    var message : String?
    var workoutID : String?
    var workoutData : workout?
    var isPrivate : Bool?
}


enum postType{
    case writtenPost
    case createdWorkout
    case completedWorkout
    case activity
    case NewCoach
    case NewPlayer
    case SetWorkout
    case NewGroup
    case RequestSent
    case RequestDeclined
    case UpdatePBs
    case AccountCreated
    case CompletedWorkout
    case invalidPost
    
    
}

